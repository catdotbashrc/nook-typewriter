# Linux Kernel 2.6.29 Quick Reference Card
## FOR AI USE - CRITICAL API DIFFERENCES

### ⚠️ CRITICAL: Your local docs have WRONG APIs!
The project documentation uses modern kernel APIs that DON'T EXIST in 2.6.29.
**ALWAYS USE THIS REFERENCE INSTEAD!**

---

## PROC FILESYSTEM - CORRECT 2.6.29 API

### Creating Proc Entries (THE RIGHT WAY)
```c
#include <linux/proc_fs.h>

// Function signatures from actual kernel headers:
struct proc_dir_entry *create_proc_entry(const char *name, mode_t mode,
                                         struct proc_dir_entry *parent);

// Callback typedefs (THESE ARE DIFFERENT FROM MODERN KERNELS!)
typedef int (read_proc_t)(char *page, char **start, off_t off,
                         int count, int *eof, void *data);
typedef int (write_proc_t)(struct file *file, const char __user *buffer,
                          unsigned long count, void *data);
```

### CORRECT Pattern for SquireOS Modules
```c
static struct proc_dir_entry *proc_entry;

// Read callback - NOTE THE SIGNATURE!
static int jester_read_proc(char *page, char **start, off_t off,
                            int count, int *eof, void *data)
{
    int len = 0;
    
    if (off > 0) {
        *eof = 1;
        return 0;
    }
    
    // Write to 'page' buffer, NOT seq_printf!
    len = sprintf(page, "ASCII art here\n");
    
    *eof = 1;
    return len;
}

// Write callback
static int jester_write_proc(struct file *file, const char __user *buffer,
                             unsigned long count, void *data)
{
    char cmd[32];
    
    if (count > sizeof(cmd) - 1)
        return -EINVAL;
    
    if (copy_from_user(cmd, buffer, count))
        return -EFAULT;
    
    cmd[count] = '\0';
    // Process command
    
    return count;
}

// Module init - THE 2.6.29 WAY
static int __init jester_init(void)
{
    // Create entry - NO proc_create() in 2.6.29!
    proc_entry = create_proc_entry("squireos/jester", 0644, NULL);
    if (!proc_entry) {
        printk(KERN_ERR "Failed to create proc entry\n");
        return -ENOMEM;
    }
    
    // Set callbacks - MUST use these fields!
    proc_entry->read_proc = jester_read_proc;
    proc_entry->write_proc = jester_write_proc;
    proc_entry->owner = THIS_MODULE;
    proc_entry->data = NULL;  // Optional private data
    
    return 0;
}

// Module exit
static void __exit jester_exit(void)
{
    remove_proc_entry("squireos/jester", NULL);
}
```

### DO NOT USE (These don't exist in 2.6.29):
- ❌ `proc_create()` - Added in 2.6.30
- ❌ `proc_create_data()` - Added in 2.6.30
- ❌ `single_open()` for proc - Use read_proc callback
- ❌ `seq_printf()` in proc - Use sprintf to page buffer
- ❌ `struct proc_ops` - Added in 5.6
- ❌ Modern file_operations for proc - Use read_proc/write_proc

---

## MODULE STRUCTURE

### Module Declaration
```c
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("SquireOS Module");
MODULE_VERSION("1.0");

// Parameters (2.6.29 style)
static int update_interval = 30;
module_param(update_interval, int, 0644);
MODULE_PARM_DESC(update_interval, "Update interval in seconds");
```

---

## MEMORY ALLOCATION

### Kernel Memory (2.6.29)
```c
#include <linux/slab.h>

// Allocation
void *ptr = kmalloc(size, GFP_KERNEL);  // May sleep
void *ptr = kmalloc(size, GFP_ATOMIC);  // Won't sleep (IRQ safe)
void *ptr = kzalloc(size, GFP_KERNEL);  // Zeroed memory

// Free
kfree(ptr);

// GFP flags in 2.6.29:
// GFP_KERNEL - Normal allocation, may sleep
// GFP_ATOMIC - High priority, won't sleep
// GFP_DMA    - DMA-capable memory
```

---

## SYNCHRONIZATION

### Spinlocks (2.6.29)
```c
#include <linux/spinlock.h>

static DEFINE_SPINLOCK(my_lock);
// or
static spinlock_t my_lock = SPIN_LOCK_UNLOCKED;

unsigned long flags;
spin_lock_irqsave(&my_lock, flags);
// Critical section
spin_unlock_irqrestore(&my_lock, flags);
```

### Atomic Operations
```c
#include <asm/atomic.h>

atomic_t counter = ATOMIC_INIT(0);
atomic_inc(&counter);
atomic_dec(&counter);
int val = atomic_read(&counter);
```

---

## OMAP3 PLATFORM SPECIFICS

### No Device Tree! Use Board Files
```c
// Board file location: arch/arm/mach-omap2/board-*.c
// Platform devices registered in board init

static struct platform_device nook_device = {
    .name = "nook-squireos",
    .id = -1,
    .dev = {
        .platform_data = &nook_data,
    },
};

// In board init function:
platform_device_register(&nook_device);
```

### OMAP3 Memory Map
```c
// Key addresses for OMAP3621
#define OMAP34XX_GPIO1_BASE    0x48310000
#define OMAP34XX_GPIO2_BASE    0x49050000
#define OMAP34XX_GPIO3_BASE    0x49052000
#define OMAP34XX_GPIO4_BASE    0x49054000
#define OMAP34XX_GPIO5_BASE    0x49056000
#define OMAP34XX_GPIO6_BASE    0x49058000
```

---

## BUILD SYSTEM

### Makefile for Module
```makefile
# In drivers/Makefile or appropriate location
obj-$(CONFIG_SQUIREOS) += squireos/

# In drivers/squireos/Makefile
obj-$(CONFIG_SQUIREOS_CORE) += squireos_core.o
obj-$(CONFIG_SQUIREOS_JESTER) += jester.o
```

### Kconfig Entry
```kconfig
config SQUIREOS
    tristate "SquireOS Medieval Interface"
    depends on PROC_FS
    default m
    help
      Enable SquireOS modules

config SQUIREOS_JESTER
    tristate "Jester Module"
    depends on SQUIREOS
    help
      ASCII art jester companion
```

---

## KERNEL LOGGING (2.6.29)

```c
#include <linux/kernel.h>

// Log levels
printk(KERN_EMERG "System unusable\n");
printk(KERN_ALERT "Action must be taken\n");
printk(KERN_CRIT "Critical conditions\n");
printk(KERN_ERR "Error conditions\n");
printk(KERN_WARNING "Warning conditions\n");
printk(KERN_NOTICE "Normal but significant\n");
printk(KERN_INFO "Informational\n");
printk(KERN_DEBUG "Debug messages\n");

// Common pattern
#define DRIVER_NAME "squireos"
#define pr_fmt(fmt) DRIVER_NAME ": " fmt

printk(KERN_INFO pr_fmt("Module loaded\n"));
```

---

## COMMON PITFALLS TO AVOID

1. **Buffer Overflows in read_proc**:
   - Page buffer is PAGE_SIZE (4096 bytes)
   - ALWAYS check length before sprintf

2. **Forgetting *eof in read_proc**:
   - Must set *eof = 1 when done
   - Otherwise proc read loops forever

3. **Wrong GFP flags**:
   - Never use GFP_KERNEL in interrupt context
   - Use GFP_ATOMIC for non-sleeping alloc

4. **Module loading order**:
   - squireos_core MUST load before others
   - Check dependencies in Kconfig

---

## MEMORY CONSTRAINTS FOR NOOK

```c
// CRITICAL: Total OS must stay under 96MB!
// Each module should use <100KB

// Check current usage:
// cat /proc/meminfo

// Module memory tracking pattern:
static unsigned long module_mem_usage = 0;

void *my_kmalloc(size_t size)
{
    void *ptr = kmalloc(size, GFP_KERNEL);
    if (ptr)
        module_mem_usage += size;
    return ptr;
}

void my_kfree(void *ptr, size_t size)
{
    kfree(ptr);
    module_mem_usage -= size;
}
```

---

## QUICK COMMAND REFERENCE

```bash
# Build kernel with modules
make ARCH=arm CROSS_COMPILE=arm-linux-androideabi- modules

# Check module info
modinfo squireos_core.ko

# Load modules (on device)
insmod squireos_core.ko
insmod jester.ko
insmod typewriter.ko

# Check proc entries
ls /proc/squireos/
cat /proc/squireos/jester

# Unload modules
rmmod jester
rmmod squireos_core
```

---

**REMEMBER**: This is kernel 2.6.29 from 2009!
- No modern conveniences
- Different APIs than current kernels
- Must use board files, not device tree
- Limited debugging tools

Last updated: Based on actual kernel source examination