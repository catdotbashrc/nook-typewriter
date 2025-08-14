# ARM Memory Management in Linux Kernel 2.6.29
## Critical Reference for 256MB Constrained System

### Memory Layout on ARM (OMAP3621)

```
Physical Memory Map (256MB Total):
0x80000000 - 0x8FFFFFFF  (256MB RAM)

Kernel Virtual Memory Layout:
0xC0000000 - 0xCFFFFFFF  (256MB) - Direct mapped RAM
0xBF000000 - 0xBFFFFFFF  (16MB)  - Modules space
0x00000000 - 0xBEFFFFFF  (3GB-)  - User space

Actual Usage for Nook:
0-96MB:   Kernel + OS (MAXIMUM!)
96-256MB: User space for writing (SACRED!)
```

---

## Memory Allocation APIs (2.6.29 Specific)

### kmalloc() - General Purpose Allocation
```c
#include <linux/slab.h>

void *kmalloc(size_t size, gfp_t flags);
```

**Size limits:**
- Maximum single allocation: ~128KB (PAGE_SIZE * 32)
- For larger: Use vmalloc() but it's slower

**Critical GFP Flags for 2.6.29:**
```c
GFP_KERNEL   // Can sleep, use in process context
GFP_ATOMIC   // Cannot sleep, use in interrupt/spinlock
GFP_DMA      // DMA-capable memory (lower 16MB)
GFP_NOIO     // No I/O operations
GFP_NOFS     // No filesystem operations
```

### kzalloc() - Zeroed Memory
```c
void *kzalloc(size_t size, gfp_t flags);
// Equivalent to: kmalloc(size, flags) + memset(0)
```

### kfree() - Free Memory
```c
void kfree(const void *ptr);
// Safe to call with NULL
```

---

## Memory Allocation Patterns for SquireOS

### Pattern 1: Small, Frequent Allocations
```c
// For jester ASCII art (< 2KB)
struct jester_art {
    char ascii[1024];
    int mood;
};

static struct jester_art *create_jester(void)
{
    struct jester_art *art;
    
    art = kzalloc(sizeof(*art), GFP_KERNEL);
    if (!art) {
        printk(KERN_ERR "SquireOS: Out of memory!\n");
        return NULL;
    }
    
    // Initialize...
    return art;
}

static void destroy_jester(struct jester_art *art)
{
    kfree(art);  // NULL-safe
}
```

### Pattern 2: Page-Aligned Buffers
```c
// For proc file buffers
static char *alloc_proc_buffer(void)
{
    // get_zeroed_page returns page-aligned memory
    return (char *)get_zeroed_page(GFP_KERNEL);
}

static void free_proc_buffer(char *buffer)
{
    free_page((unsigned long)buffer);
}
```

### Pattern 3: Memory Pool for Statistics
```c
// Pre-allocate to avoid runtime allocation
struct typewriter_stats {
    u32 words;
    u32 keystrokes;
    u32 sessions;
    spinlock_t lock;
};

// Static allocation - no runtime overhead!
static struct typewriter_stats global_stats = {
    .lock = __SPIN_LOCK_UNLOCKED(global_stats.lock),
};
```

---

## ARM-Specific Considerations

### Cache Management
```c
#include <asm/cacheflush.h>

// Flush data cache for DMA operations
void *buffer = kmalloc(size, GFP_KERNEL | GFP_DMA);
// ... fill buffer ...
flush_dcache_range((unsigned long)buffer, 
                   (unsigned long)buffer + size);
```

### Memory Barriers (ARM)
```c
#include <asm/system.h>

// Ensure memory operations complete
mb();   // Full memory barrier
rmb();  // Read memory barrier
wmb();  // Write memory barrier

// ARM-specific
dmb();  // Data memory barrier
dsb();  // Data synchronization barrier
isb();  // Instruction synchronization barrier
```

### Alignment Requirements
```c
// ARM requires word alignment for many operations
struct aligned_struct {
    u32 value1;
    u32 value2;
} __attribute__((aligned(4)));

// For DMA operations - cache line alignment
#define L1_CACHE_BYTES 32  // OMAP3
struct dma_buffer {
    u8 data[1024];
} __attribute__((aligned(L1_CACHE_BYTES)));
```

---

## Memory Constraints for Nook Project

### Critical Limits
```c
// ABSOLUTE MAXIMUM for kernel + modules
#define MAX_KERNEL_MEMORY  (96 * 1024 * 1024)  // 96MB

// Per-module recommendations
#define MAX_MODULE_MEMORY  (100 * 1024)        // 100KB per module

// Monitoring pattern
static atomic_t module_memory_usage = ATOMIC_INIT(0);

void *squireos_kmalloc(size_t size, gfp_t flags)
{
    void *ptr;
    
    // Check if we're within budget
    if (atomic_read(&module_memory_usage) + size > MAX_MODULE_MEMORY) {
        printk(KERN_WARNING "SquireOS: Memory budget exceeded!\n");
        return NULL;
    }
    
    ptr = kmalloc(size, flags);
    if (ptr)
        atomic_add(size, &module_memory_usage);
    
    return ptr;
}

void squireos_kfree(void *ptr, size_t size)
{
    kfree(ptr);
    atomic_sub(size, &module_memory_usage);
}
```

### Memory-Efficient Data Structures
```c
// BAD: Wastes memory with padding
struct wasteful {
    char flag;      // 1 byte
    // 3 bytes padding
    int value;      // 4 bytes
    char status;    // 1 byte
    // 3 bytes padding
};  // Total: 12 bytes

// GOOD: Packed efficiently
struct efficient {
    int value;      // 4 bytes
    char flag;      // 1 byte
    char status;    // 1 byte
    // 2 bytes padding
} __attribute__((packed));  // Total: 6 bytes

// BEST: Naturally aligned
struct optimal {
    u32 value;      // 4 bytes
    u16 flags;      // 2 bytes (combine flag + status)
    u16 reserved;   // 2 bytes
};  // Total: 8 bytes, no padding
```

---

## OMAP3-Specific Memory APIs

### DMA Memory Allocation
```c
#include <linux/dma-mapping.h>

// Allocate DMA-coherent memory
dma_addr_t dma_handle;
void *buffer = dma_alloc_coherent(dev, size, &dma_handle, GFP_KERNEL);

// Use buffer for DMA operations...

// Free DMA memory
dma_free_coherent(dev, size, buffer, dma_handle);
```

### OMAP3 Memory Power Management
```c
// Memory self-refresh for power saving
#include <mach/pm.h>

// Allow memory to enter self-refresh during idle
omap3_pm_set_memory_retention(OMAP3_MEM_RETENTION_ENABLE);
```

---

## Debugging Memory Issues

### Kernel Config Options (2.6.29)
```kconfig
CONFIG_DEBUG_SLAB=y        # Detect use-after-free
CONFIG_DEBUG_PAGEALLOC=y   # Detect invalid page access
CONFIG_DEBUG_KMEMLEAK=y    # Memory leak detection (if available)
```

### Runtime Monitoring
```c
// Check memory usage
void print_memory_stats(void)
{
    struct sysinfo si;
    
    si_meminfo(&si);
    
    printk(KERN_INFO "SquireOS Memory Stats:\n");
    printk(KERN_INFO "  Total RAM: %lu KB\n", si.totalram * 4);
    printk(KERN_INFO "  Free RAM:  %lu KB\n", si.freeram * 4);
    printk(KERN_INFO "  Buffer:    %lu KB\n", si.bufferram * 4);
    printk(KERN_INFO "  Module:    %d bytes\n", 
           atomic_read(&module_memory_usage));
}
```

### /proc/meminfo Monitoring
```bash
# On device
cat /proc/meminfo | head -10

# Key values to watch:
# MemTotal:     256MB (262144 KB)
# MemFree:      Should be > 160MB after boot
# Buffers:      File system buffers
# Cached:       Page cache
```

---

## Common Memory Bugs and Solutions

### 1. Memory Leak
```c
// BUG: Leak on error path
void *ptr = kmalloc(size, GFP_KERNEL);
if (!ptr)
    return -ENOMEM;

if (some_error) {
    return -EINVAL;  // LEAK! Forgot kfree(ptr)
}

// FIXED:
void *ptr = kmalloc(size, GFP_KERNEL);
if (!ptr)
    return -ENOMEM;

if (some_error) {
    kfree(ptr);
    return -EINVAL;
}
```

### 2. Use After Free
```c
// BUG:
kfree(buffer);
buffer[0] = 0;  // CRASH!

// FIXED:
kfree(buffer);
buffer = NULL;  // Defensive programming
```

### 3. Stack Overflow (Limited kernel stack!)
```c
// BUG: Large stack allocation
void bad_function(void)
{
    char huge_buffer[8192];  // CRASH! Kernel stack is only 8KB!
}

// FIXED: Use heap
void good_function(void)
{
    char *buffer = kmalloc(8192, GFP_KERNEL);
    if (!buffer)
        return;
    // use buffer
    kfree(buffer);
}
```

---

## Memory Optimization Strategies

### 1. Use Static When Possible
```c
// Instead of runtime allocation
static char jester_ascii[1024];  // One-time cost
```

### 2. Pool Allocations
```c
// Pre-allocate pool at module load
#define POOL_SIZE 10
static struct object pool[POOL_SIZE];
static unsigned long pool_bitmap;  // Track free slots

struct object *get_from_pool(void)
{
    int i = find_first_zero_bit(&pool_bitmap, POOL_SIZE);
    if (i < POOL_SIZE) {
        set_bit(i, &pool_bitmap);
        return &pool[i];
    }
    return NULL;
}
```

### 3. Minimize Fragmentation
```c
// Allocate in power-of-2 sizes
size = roundup_pow_of_two(requested_size);
ptr = kmalloc(size, GFP_KERNEL);
```

---

## Critical Rules for Nook Memory Management

1. **NEVER exceed 96MB total OS usage**
2. **Each module should use <100KB**
3. **Prefer static allocation over dynamic**
4. **Free memory immediately when done**
5. **Use GFP_ATOMIC sparingly (depletes emergency pool)**
6. **Monitor with /proc/meminfo regularly**
7. **Test with CONFIG_DEBUG_SLAB enabled**

---

This reference is specifically for ARM Linux 2.6.29 on OMAP3621 with 256MB RAM constraint.