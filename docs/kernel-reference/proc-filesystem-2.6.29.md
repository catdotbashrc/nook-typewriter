# Proc Filesystem in Linux Kernel 2.6.29
## Detailed Reference for AI Understanding

### Overview
The `/proc` filesystem in kernel 2.6.29 uses a significantly different API than modern kernels. This document provides the CORRECT patterns for implementing proc entries in the Nook project.

---

## Core API Functions

### create_proc_entry()
```c
struct proc_dir_entry *create_proc_entry(const char *name, mode_t mode,
                                         struct proc_dir_entry *parent);
```

**Parameters:**
- `name`: Entry name (can include path like "squireos/jester")
- `mode`: File permissions (e.g., 0644 for rw-r--r--)
- `parent`: Parent directory or NULL for /proc root

**Returns:**
- Pointer to `proc_dir_entry` on success
- NULL on failure

**Important:** This function only creates the entry. You MUST set the callbacks after creation.

### remove_proc_entry()
```c
void remove_proc_entry(const char *name, struct proc_dir_entry *parent);
```

**Usage:** Called in module cleanup to remove proc entries.

---

## The proc_dir_entry Structure

```c
struct proc_dir_entry {
    unsigned int low_ino;
    unsigned short namelen;
    const char *name;
    mode_t mode;
    nlink_t nlink;
    uid_t uid;
    gid_t gid;
    loff_t size;
    const struct inode_operations *proc_iops;
    const struct file_operations *proc_fops;
    struct module *owner;
    struct proc_dir_entry *next, *parent, *subdir;
    void *data;                    // Private data for callbacks
    read_proc_t *read_proc;         // Read callback
    write_proc_t *write_proc;       // Write callback
    atomic_t count;
    int pde_users;
    spinlock_t pde_unload_lock;
    struct completion *pde_unload_completion;
    struct list_head pde_openers;
};
```

**Key fields for module development:**
- `read_proc`: Function called when user reads from proc file
- `write_proc`: Function called when user writes to proc file
- `data`: Private data passed to callbacks
- `owner`: Should be set to THIS_MODULE

---

## Callback Function Signatures

### read_proc callback
```c
typedef int (read_proc_t)(char *page, char **start, off_t off,
                         int count, int *eof, void *data);
```

**Parameters explained:**
- `page`: Buffer to write output to (PAGE_SIZE bytes, typically 4096)
- `start`: For handling reads at offset (advanced use)
- `off`: Offset in the virtual file
- `count`: Maximum bytes to read
- `eof`: MUST set to 1 when no more data
- `data`: Private data from proc_dir_entry

**Return value:** Number of bytes written to page buffer

**Critical pattern for simple reads:**
```c
static int my_read_proc(char *page, char **start, off_t off,
                        int count, int *eof, void *data)
{
    int len;
    
    // Handle offset for subsequent reads
    if (off > 0) {
        *eof = 1;
        return 0;
    }
    
    // Write data to page buffer
    len = sprintf(page, "Current status: %d\n", some_value);
    
    // Mark end of file
    *eof = 1;
    
    return len;
}
```

### write_proc callback
```c
typedef int (write_proc_t)(struct file *file, const char __user *buffer,
                           unsigned long count, void *data);
```

**Parameters:**
- `file`: File structure (usually ignored)
- `buffer`: User space buffer (MUST use copy_from_user)
- `count`: Number of bytes to write
- `data`: Private data from proc_dir_entry

**Return value:** Number of bytes processed (usually count)

**Safe pattern:**
```c
static int my_write_proc(struct file *file, const char __user *buffer,
                         unsigned long count, void *data)
{
    char local_buf[100];
    
    if (count > sizeof(local_buf) - 1)
        return -EINVAL;
    
    if (copy_from_user(local_buf, buffer, count))
        return -EFAULT;
    
    local_buf[count] = '\0';
    
    // Process the input
    // ...
    
    return count;
}
```

---

## Complete Working Example for SquireOS

```c
#include <linux/module.h>
#include <linux/proc_fs.h>
#include <linux/uaccess.h>

static struct proc_dir_entry *squireos_dir;
static struct proc_dir_entry *jester_entry;
static int jester_mood = 0;

static int jester_read_proc(char *page, char **start, off_t off,
                            int count, int *eof, void *data)
{
    int len = 0;
    
    if (off > 0) {
        *eof = 1;
        return 0;
    }
    
    // Generate ASCII art based on mood
    switch (jester_mood) {
    case 0:
        len = sprintf(page, 
            "   ___\n"
            "  /o o\\\n"
            " ( > < )\n"
            "  \\___/\n"
            "Jester is happy!\n");
        break;
    case 1:
        len = sprintf(page,
            "   ___\n"
            "  /-_-\\\n"
            " ( u u )\n"
            "  \\___/\n"
            "Jester is sleepy...\n");
        break;
    default:
        len = sprintf(page, "Jester mood: %d\n", jester_mood);
    }
    
    *eof = 1;
    return len;
}

static int jester_write_proc(struct file *file, const char __user *buffer,
                             unsigned long count, void *data)
{
    char cmd[32];
    
    if (count > sizeof(cmd) - 1)
        return -EINVAL;
    
    if (copy_from_user(cmd, buffer, count))
        return -EFAULT;
    
    cmd[count] = '\0';
    
    if (strncmp(cmd, "happy", 5) == 0)
        jester_mood = 0;
    else if (strncmp(cmd, "sleepy", 6) == 0)
        jester_mood = 1;
    
    return count;
}

static int __init jester_init(void)
{
    // Create /proc/squireos directory
    squireos_dir = create_proc_entry("squireos", 0755, NULL);
    if (!squireos_dir) {
        printk(KERN_ERR "Failed to create /proc/squireos\n");
        return -ENOMEM;
    }
    
    // Create /proc/squireos/jester
    jester_entry = create_proc_entry("jester", 0644, squireos_dir);
    if (!jester_entry) {
        remove_proc_entry("squireos", NULL);
        printk(KERN_ERR "Failed to create jester entry\n");
        return -ENOMEM;
    }
    
    // Set up the callbacks
    jester_entry->read_proc = jester_read_proc;
    jester_entry->write_proc = jester_write_proc;
    jester_entry->owner = THIS_MODULE;
    
    printk(KERN_INFO "Jester module loaded\n");
    return 0;
}

static void __exit jester_exit(void)
{
    remove_proc_entry("jester", squireos_dir);
    remove_proc_entry("squireos", NULL);
    printk(KERN_INFO "Jester module unloaded\n");
}

module_init(jester_init);
module_exit(jester_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("SquireOS Team");
MODULE_DESCRIPTION("Jester proc interface for 2.6.29");
```

---

## Common Patterns and Best Practices

### 1. Handling Large Output
When output might exceed PAGE_SIZE:

```c
static int large_read_proc(char *page, char **start, off_t off,
                           int count, int *eof, void *data)
{
    static char large_buffer[8192];
    static int buffer_len = 0;
    
    // First call - generate data
    if (off == 0) {
        buffer_len = generate_large_output(large_buffer);
    }
    
    // Handle offset
    if (off >= buffer_len) {
        *eof = 1;
        return 0;
    }
    
    // Copy the requested chunk
    int len = buffer_len - off;
    if (len > count)
        len = count;
    if (len > PAGE_SIZE)
        len = PAGE_SIZE;
    
    memcpy(page, large_buffer + off, len);
    
    // Set start for next read
    *start = page;
    
    // Check if we're done
    if (off + len >= buffer_len)
        *eof = 1;
    
    return len;
}
```

### 2. Creating Directory Hierarchies
```c
struct proc_dir_entry *root_dir, *sub_dir, *file_entry;

// Create /proc/squireos/
root_dir = create_proc_entry("squireos", 0755, NULL);

// Create /proc/squireos/typewriter/
sub_dir = create_proc_entry("typewriter", 0755, root_dir);

// Create /proc/squireos/typewriter/stats
file_entry = create_proc_entry("stats", 0444, sub_dir);
file_entry->read_proc = stats_read_proc;
file_entry->owner = THIS_MODULE;
```

### 3. Using Private Data
```c
struct my_private_data {
    int counter;
    char name[32];
};

static struct my_private_data priv_data = {
    .counter = 0,
    .name = "SquireOS"
};

// In init:
proc_entry->data = &priv_data;

// In callback:
static int my_read_proc(char *page, char **start, off_t off,
                       int count, int *eof, void *data)
{
    struct my_private_data *priv = (struct my_private_data *)data;
    int len = sprintf(page, "Counter: %d, Name: %s\n", 
                     priv->counter, priv->name);
    *eof = 1;
    return len;
}
```

---

## Error Handling

### Common Errors and Solutions

1. **Infinite read loop**: Forgot to set `*eof = 1`
2. **Crash on read**: Buffer overflow in sprintf
3. **Crash on write**: Didn't use copy_from_user
4. **Module won't unload**: Proc entry still in use

### Safe Cleanup Pattern
```c
static void cleanup_proc_entries(void)
{
    if (file_entry) {
        remove_proc_entry("file", sub_dir);
        file_entry = NULL;
    }
    if (sub_dir) {
        remove_proc_entry("subdir", root_dir);
        sub_dir = NULL;
    }
    if (root_dir) {
        remove_proc_entry("root", NULL);
        root_dir = NULL;
    }
}
```

---

## Testing Proc Entries

```bash
# Read test
cat /proc/squireos/jester

# Write test
echo "happy" > /proc/squireos/jester

# Check permissions
ls -la /proc/squireos/

# Monitor kernel messages
dmesg | tail

# Check if module loaded
lsmod | grep jester
```

---

## Performance Considerations

1. **read_proc is called multiple times**: For large output, might be called with different offsets
2. **Buffer size limit**: PAGE_SIZE (4096) per call
3. **No caching**: Data regenerated on each read
4. **Synchronization needed**: Use spinlocks if data can change

---

## Differences from Modern Kernels

| Feature | Kernel 2.6.29 | Modern Kernels |
|---------|---------------|----------------|
| Create function | `create_proc_entry()` | `proc_create()` |
| Callbacks | `read_proc`/`write_proc` | `file_operations` |
| Seq file | Not typically used | Standard approach |
| Buffer management | Manual with page buffer | seq_printf() |
| Error handling | Return negative errno | More standardized |

---

This reference is specifically for kernel 2.6.29 as used in the Nook project. Always verify against actual kernel source when in doubt.