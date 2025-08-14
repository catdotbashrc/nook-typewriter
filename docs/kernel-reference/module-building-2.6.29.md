# Building Kernel Modules for Linux 2.6.29
## Cross-Compilation for ARM with Android NDK

### Build Environment Setup

```bash
# Required tools
export ARCH=arm
export CROSS_COMPILE=arm-linux-androideabi-
export PATH=/path/to/android-ndk-r10e/toolchains/arm-linux-androideabi-4.8/prebuilt/linux-x86_64/bin:$PATH

# Kernel source location
export KERNEL_DIR=/home/jyeary/projects/personal/nook/source/kernel/src
```

---

## Module Makefile Structure

### Single Module Makefile
```makefile
# Makefile for single module
obj-m := squireos_core.o

# For module with multiple source files
obj-m := jester.o
jester-objs := jester_main.o jester_ascii.o jester_mood.o

KERNEL_DIR ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

all:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean
```

### In-Tree Module Makefile
```makefile
# drivers/squireos/Makefile
obj-$(CONFIG_SQUIREOS) += squireos_core.o
obj-$(CONFIG_SQUIREOS_JESTER) += jester.o
obj-$(CONFIG_SQUIREOS_TYPEWRITER) += typewriter.o
obj-$(CONFIG_SQUIREOS_WISDOM) += wisdom.o

# Module with multiple files
squireos_core-y := core_main.o core_proc.o core_init.o
```

---

## Kconfig Integration

### drivers/Kconfig
```kconfig
# Add to drivers/Kconfig
source "drivers/squireos/Kconfig"
```

### drivers/squireos/Kconfig
```kconfig
menuconfig SQUIREOS
    tristate "SquireOS Medieval Writing Interface"
    depends on PROC_FS && ARM && ARCH_OMAP3
    default m
    help
      Enableth the SquireOS medieval interface system,
      bringing joy and whimsy to thy writing experience.
      
      If unsure, say M to build as modules.

if SQUIREOS

config SQUIREOS_JESTER
    tristate "Court Jester ASCII Companion"
    default m
    help
      The court jester shall entertain with ASCII art
      and respond to thy writing progress.

config SQUIREOS_TYPEWRITER
    tristate "Typewriter Statistics Tracking"
    default m
    help
      Track thy words and keystrokes, celebrating
      achievements in the craft of writing.

config SQUIREOS_WISDOM
    tristate "Writing Wisdom Quotes"
    default m
    help
      Inspirational quotes to guide thy quill.

config SQUIREOS_DEBUG
    bool "Enable SquireOS Debug Messages"
    depends on SQUIREOS
    help
      Enable verbose debug output. Only for development.

endif # SQUIREOS
```

---

## Build Commands

### For Out-of-Tree Modules
```bash
# Build module against Nook kernel
cd /path/to/module
make ARCH=arm CROSS_COMPILE=arm-linux-androideabi- \
     KERNEL_DIR=/home/jyeary/projects/personal/nook/source/kernel/src

# Result: squireos_core.ko
```

### For In-Tree Modules
```bash
# Configure kernel
cd $KERNEL_DIR
make ARCH=arm omap3621_gossamer_evt1c_defconfig
make ARCH=arm menuconfig  # Enable SQUIREOS options

# Build only modules
make ARCH=arm CROSS_COMPILE=arm-linux-androideabi- modules

# Build specific module
make ARCH=arm CROSS_COMPILE=arm-linux-androideabi- \
     M=drivers/squireos modules
```

---

## Module Source Template

### Complete Module Example
```c
/*
 * squireos_core.c - SquireOS Core Module for Linux 2.6.29
 * 
 * This module creates the /proc/squireos infrastructure
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/proc_fs.h>
#include <linux/string.h>
#include <linux/uaccess.h>

#define MODULE_NAME "squireos_core"
#define PROC_DIR "squireos"

/* Module parameters */
static int debug = 0;
module_param(debug, int, 0644);
MODULE_PARM_DESC(debug, "Enable debug messages (0=off, 1=on)");

/* Global variables */
static struct proc_dir_entry *proc_dir;
static struct proc_dir_entry *motto_entry;

/* The system motto */
static char system_motto[256] = "By quill and candlelight!";

/* Debug macro */
#define SQUIREOS_DEBUG(fmt, args...) \
    do { \
        if (debug) \
            printk(KERN_DEBUG MODULE_NAME ": " fmt, ##args); \
    } while (0)

/*
 * Read callback for /proc/squireos/motto
 * Note: This is the 2.6.29 style, NOT modern proc_create!
 */
static int motto_read_proc(char *page, char **start, off_t off,
                          int count, int *eof, void *data)
{
    int len;
    
    SQUIREOS_DEBUG("motto_read_proc called, offset=%ld\n", off);
    
    if (off > 0) {
        *eof = 1;
        return 0;
    }
    
    len = sprintf(page, "%s\n", system_motto);
    *eof = 1;
    
    return len;
}

/*
 * Write callback for /proc/squireos/motto
 */
static int motto_write_proc(struct file *file, const char __user *buffer,
                            unsigned long count, void *data)
{
    if (count > sizeof(system_motto) - 1)
        count = sizeof(system_motto) - 1;
    
    if (copy_from_user(system_motto, buffer, count))
        return -EFAULT;
    
    system_motto[count] = '\0';
    
    /* Remove trailing newline if present */
    if (count > 0 && system_motto[count-1] == '\n')
        system_motto[count-1] = '\0';
    
    SQUIREOS_DEBUG("Motto updated to: %s\n", system_motto);
    
    return count;
}

/*
 * Module initialization
 */
static int __init squireos_init(void)
{
    printk(KERN_INFO MODULE_NAME ": Initializing SquireOS\n");
    
    /* Create /proc/squireos directory */
    proc_dir = create_proc_entry(PROC_DIR, 0755, NULL);
    if (!proc_dir) {
        printk(KERN_ERR MODULE_NAME ": Failed to create /proc/%s\n", 
               PROC_DIR);
        return -ENOMEM;
    }
    
    /* Create /proc/squireos/motto */
    motto_entry = create_proc_entry("motto", 0644, proc_dir);
    if (!motto_entry) {
        remove_proc_entry(PROC_DIR, NULL);
        printk(KERN_ERR MODULE_NAME ": Failed to create motto entry\n");
        return -ENOMEM;
    }
    
    /* Set up callbacks - CRITICAL for 2.6.29! */
    motto_entry->read_proc = motto_read_proc;
    motto_entry->write_proc = motto_write_proc;
    motto_entry->owner = THIS_MODULE;
    
    printk(KERN_INFO MODULE_NAME ": Successfully loaded\n");
    return 0;
}

/*
 * Module cleanup
 */
static void __exit squireos_exit(void)
{
    SQUIREOS_DEBUG("Cleaning up SquireOS\n");
    
    if (motto_entry)
        remove_proc_entry("motto", proc_dir);
    
    if (proc_dir)
        remove_proc_entry(PROC_DIR, NULL);
    
    printk(KERN_INFO MODULE_NAME ": Unloaded\n");
}

/* Register module init/exit */
module_init(squireos_init);
module_exit(squireos_exit);

/* Module metadata */
MODULE_LICENSE("GPL");
MODULE_AUTHOR("SquireOS Team");
MODULE_DESCRIPTION("SquireOS Core Module for Medieval Writing Interface");
MODULE_VERSION("1.0.0");

/* Export the proc directory for other modules */
EXPORT_SYMBOL(proc_dir);
```

---

## Module Dependencies

### Declaring Dependencies
```c
/* In dependent module */
extern struct proc_dir_entry *squireos_proc_dir;

/* In Kconfig */
config SQUIREOS_JESTER
    depends on SQUIREOS
```

### Load Order
```bash
# Must load in dependency order
insmod squireos_core.ko
insmod jester.ko         # Depends on core
insmod typewriter.ko     # Depends on core
insmod wisdom.ko         # Depends on core
```

---

## Cross-Compilation Issues and Solutions

### Issue 1: Wrong Architecture
```bash
# ERROR: "incompatible architecture"
# SOLUTION: Always set ARCH=arm
export ARCH=arm
```

### Issue 2: Missing Cross Compiler
```bash
# ERROR: "arm-linux-androideabi-gcc: command not found"
# SOLUTION: Add NDK to PATH
export PATH=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.8/prebuilt/linux-x86_64/bin:$PATH
```

### Issue 3: Kernel Version Mismatch
```bash
# ERROR: "disagrees about version of symbol"
# SOLUTION: Build against exact kernel source
make KERNEL_DIR=/exact/kernel/source
```

### Issue 4: Missing Module.symvers
```bash
# ERROR: "WARNING: Symbol version dump Module.symvers is missing"
# SOLUTION: Build kernel first
cd $KERNEL_DIR
make ARCH=arm CROSS_COMPILE=arm-linux-androideabi-
# Now Module.symvers exists
```

---

## Module Installation on Device

### Manual Installation
```bash
# Copy to device (via SD card)
cp *.ko /mnt/sdcard/modules/

# On device
cd /mnt/sdcard/modules
insmod squireos_core.ko debug=1
insmod jester.ko

# Verify
lsmod | grep squireos
cat /proc/squireos/motto
```

### Automatic Loading at Boot
```bash
# Add to /etc/init.d/squireos
#!/bin/sh
case "$1" in
start)
    insmod /lib/modules/2.6.29/squireos_core.ko
    insmod /lib/modules/2.6.29/jester.ko
    ;;
stop)
    rmmod jester
    rmmod squireos_core
    ;;
esac
```

---

## Debugging Module Build Issues

### Enable Verbose Build
```bash
make V=1 ARCH=arm CROSS_COMPILE=arm-linux-androideabi-
```

### Check Module Info
```bash
# On build system
arm-linux-androideabi-objdump -h squireos_core.ko
modinfo squireos_core.ko

# Check symbols
arm-linux-androideabi-nm squireos_core.ko
```

### Common Build Errors

1. **"implicit declaration of function"**
   - Missing #include
   - Function doesn't exist in 2.6.29

2. **"error: 'struct proc_dir_entry' has no member named 'proc_fops'"**
   - Using modern API instead of read_proc/write_proc

3. **"undefined reference to `proc_create'"**
   - proc_create doesn't exist in 2.6.29
   - Use create_proc_entry instead

---

## Module Binary Format

### Module Structure (2.6.29)
```
squireos_core.ko:
├── .text         (code)
├── .data         (initialized data)
├── .bss          (uninitialized data)
├── .modinfo      (module metadata)
├── .symtab       (symbol table)
├── __versions    (symbol versions)
└── .gnu.linkonce (singleton sections)
```

### Verify Module
```bash
# Check if module is valid
arm-linux-androideabi-objdump -h squireos_core.ko | grep -E "\.text|\.data"

# Check module magic
modinfo squireos_core.ko | grep vermagic
# Should show: vermagic: 2.6.29 mod_unload ARMv7
```

---

This reference covers building modules specifically for Linux 2.6.29 ARM target using Android NDK toolchain.