# 🐧 Nook Kernel API Documentation

*Linux 2.6.29 with JesterOS Userspace Integration*

**Version**: 1.0.0  
**Updated**: December 2024  
**Architecture**: ARM OMAP3 (Barnes & Noble Nook Simple Touch)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Kernel Configuration](#kernel-configuration)
3. [Core Kernel APIs](#core-kernel-apis)
4. [JesterOS Integration](#jesteros-integration)
5. [Device Drivers](#device-drivers)
6. [Memory Management](#memory-management)
7. [File System Interface](#file-system-interface)
8. [Boot Process](#boot-process)
9. [System Calls](#system-calls)
10. [Module Development](#module-development)

---

## 🎯 Overview

The Nook kernel is based on Linux 2.6.29 (March 2009), chosen for period-correct compatibility with the Nook Simple Touch hardware. This kernel has been enhanced with JesterOS support, though the actual JesterOS services now run in userspace for improved stability.

### Key Features
- **Base**: Linux 2.6.29 stable
- **Architecture**: ARM v7 (OMAP3621)
- **Display**: E-Ink framebuffer support
- **Memory**: Optimized for 256MB RAM constraint
- **Power**: Aggressive power management for battery life
- **JesterOS**: Userspace service integration

---

## ⚙️ Kernel Configuration

### Configuration Files

#### Primary Config
```
source/kernel/src/arch/arm/configs/omap3621_gossamer_evt1c_defconfig
```

### Key Configuration Options

```c
CONFIG_ARM=y
CONFIG_ARCH_OMAP3=y
CONFIG_OMAP3621_GOSSAMER=y
CONFIG_AEABI=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_NO_HZ=y
CONFIG_PREEMPT=y
CONFIG_FB_EINK=y           # E-Ink display support
CONFIG_JESTEROS_SUPPORT=y   # JesterOS userspace hooks
```

### Memory Configuration
```c
CONFIG_VMSPLIT_3G=y         # 3G/1G user/kernel split
CONFIG_PAGE_OFFSET=0xC0000000
CONFIG_MEMORY_SIZE=256      # 256MB total RAM
CONFIG_CMDLINE="mem=256M"
```

---

## 🔧 Core Kernel APIs

### Process Management

#### task_struct
```c
struct task_struct {
    volatile long state;    /* -1 unrunnable, 0 runnable, >0 stopped */
    void *stack;
    atomic_t usage;
    unsigned int flags;
    struct mm_struct *mm;
    pid_t pid;
    pid_t tgid;
    /* ... */
};
```

#### Process Creation
```c
long do_fork(unsigned long clone_flags,
             unsigned long stack_start,
             struct pt_regs *regs,
             unsigned long stack_size,
             int __user *parent_tidptr,
             int __user *child_tidptr);
```

### Scheduling

#### schedule()
```c
asmlinkage void __sched schedule(void);
```
- **Purpose**: Main scheduler function
- **Context**: Can be called from interrupt or process context
- **Preemption**: Handles preemptive multitasking

#### CFS Scheduler Parameters
```c
struct sched_entity {
    struct load_weight load;
    struct rb_node run_node;
    u64 exec_start;
    u64 sum_exec_runtime;
    u64 vruntime;
    /* ... */
};
```

---

## 🎭 JesterOS Integration

While JesterOS now runs in userspace, the kernel provides essential support:

### /proc Interface

#### /proc/jesteros/status
```c
static int jesteros_proc_show(struct seq_file *m, void *v)
{
    seq_printf(m, "JesterOS Status: %s\n", 
               jesteros_enabled ? "Active" : "Dormant");
    seq_printf(m, "Services: jester tracker health\n");
    return 0;
}
```

### sysfs Interface

#### /sys/class/jesteros/
```
/sys/class/jesteros/
├── jester/
│   ├── mood        # Current jester mood
│   └── enabled     # Service state
├── tracker/
│   ├── keystrokes  # Total keystrokes
│   ├── words       # Word count
│   └── session     # Session statistics
└── health/
    ├── memory      # Memory usage
    └── status      # System health
```

### Kernel Hooks for JesterOS

```c
/* Keystroke tracking hook */
void jesteros_keystroke_notify(unsigned char key) {
    if (jesteros_tracker_enabled) {
        atomic_inc(&keystroke_count);
        wake_up_interruptible(&jesteros_wait);
    }
}

/* Memory pressure notification */
void jesteros_memory_pressure(int level) {
    if (jesteros_health_enabled) {
        jesteros_health_update(level);
    }
}
```

---

## 🖥️ Device Drivers

### E-Ink Display Driver

#### Framebuffer Operations
```c
static struct fb_ops eink_fb_ops = {
    .owner          = THIS_MODULE,
    .fb_read        = fb_sys_read,
    .fb_write       = eink_fb_write,
    .fb_fillrect    = eink_fillrect,
    .fb_copyarea    = eink_copyarea,
    .fb_imageblit   = eink_imageblit,
    .fb_pan_display = eink_pan_display,
    .fb_ioctl       = eink_ioctl,
};
```

#### E-Ink Refresh Control
```c
#define EINK_REFRESH_FULL    0x01  /* Full screen refresh */
#define EINK_REFRESH_PARTIAL 0x02  /* Partial update */
#define EINK_REFRESH_FAST    0x04  /* Fast mode (ghosting) */

int eink_refresh(struct fb_info *info, int mode);
```

### Input Driver (Touchscreen)

```c
static struct input_dev *nook_ts_input;

static irqreturn_t nook_ts_interrupt(int irq, void *dev_id)
{
    /* Read touch coordinates */
    input_report_abs(nook_ts_input, ABS_X, x);
    input_report_abs(nook_ts_input, ABS_Y, y);
    input_report_key(nook_ts_input, BTN_TOUCH, pressed);
    input_sync(nook_ts_input);
    
    return IRQ_HANDLED;
}
```

---

## 💾 Memory Management

### Memory Layout
```
0x00000000 - 0x0FFFFFFF : User space (256MB)
0xC0000000 - 0xCFFFFFFF : Kernel space (256MB)
0xD0000000 - 0xFFFFFFFF : IO and device memory
```

### Memory Allocation APIs

#### kmalloc()
```c
void *kmalloc(size_t size, gfp_t flags);
```
- `GFP_KERNEL`: Normal allocation
- `GFP_ATOMIC`: Atomic context allocation
- `GFP_DMA`: DMA-capable memory

#### Page Allocation
```c
struct page *alloc_pages(gfp_t gfp_mask, unsigned int order);
void __free_pages(struct page *page, unsigned int order);
```

### Memory Constraints for JesterOS
```c
#define JESTEROS_MAX_MEMORY  (8 * 1024 * 1024)  /* 8MB max */
#define WRITING_RESERVED_MEM (160 * 1024 * 1024) /* 160MB reserved */
```

---

## 📁 File System Interface

### VFS Operations

```c
struct file_operations {
    struct module *owner;
    loff_t (*llseek) (struct file *, loff_t, int);
    ssize_t (*read) (struct file *, char __user *, size_t, loff_t *);
    ssize_t (*write) (struct file *, const char __user *, size_t, loff_t *);
    int (*open) (struct inode *, struct file *);
    int (*release) (struct inode *, struct file *);
    /* ... */
};
```

### JesterOS Virtual Files

```c
/* /var/jesteros/ interface */
static const struct file_operations jesteros_fops = {
    .owner = THIS_MODULE,
    .read  = jesteros_read,
    .write = jesteros_write,
    .open  = jesteros_open,
};
```

---

## 🚀 Boot Process

### Boot Sequence
1. **Bootloader** (U-Boot) loads kernel
2. **Kernel decompression** 
3. **start_kernel()** - Main entry point
4. **init_IRQ()** - Initialize interrupts
5. **init_timers()** - Setup system timers
6. **mem_init()** - Initialize memory management
7. **calibrate_delay()** - CPU speed calibration
8. **rest_init()** - Start init process
9. **JesterOS userspace** services launch

### Early Boot Parameters
```c
static int __init jesteros_setup(char *str)
{
    if (!strcmp(str, "enabled"))
        jesteros_early_enable = 1;
    return 1;
}
__setup("jesteros=", jesteros_setup);
```

---

## 📞 System Calls

### JesterOS Custom Syscalls

```c
/* Syscall numbers (ARM) */
#define __NR_jesteros_status  380
#define __NR_jesteros_control 381

/* Implementation */
asmlinkage long sys_jesteros_status(void)
{
    return jesteros_get_status();
}

asmlinkage long sys_jesteros_control(int cmd, unsigned long arg)
{
    switch (cmd) {
        case JESTEROS_CMD_ENABLE:
            return jesteros_enable();
        case JESTEROS_CMD_DISABLE:
            return jesteros_disable();
        /* ... */
    }
}
```

---

## 🔌 Module Development

### Module Template

```c
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

static int __init mymodule_init(void)
{
    printk(KERN_INFO "JesterOS module loaded\n");
    return 0;
}

static void __exit mymodule_exit(void)
{
    printk(KERN_INFO "JesterOS module unloaded\n");
}

module_init(mymodule_init);
module_exit(mymodule_exit);

MODULE_LICENSE("GPL v2");
MODULE_AUTHOR("The Jester");
MODULE_DESCRIPTION("JesterOS Enhancement Module");
MODULE_VERSION("1.0");
```

### Module Makefile

```makefile
obj-m += jesteros_module.o

all:
    make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
    make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
```

---

## 🛡️ Safety & Constraints

### Resource Limits
```c
/* Maximum resource usage for non-writing tasks */
#define MAX_SYSTEM_MEMORY    (96 * 1024 * 1024)  /* 96MB */
#define MAX_JESTEROS_MEMORY  (8 * 1024 * 1024)   /* 8MB */
#define RESERVED_FOR_WRITING (160 * 1024 * 1024) /* 160MB */
```

### Kernel Panics & Recovery
```c
void jesteros_panic_handler(void)
{
    /* Display jester's final jest */
    printk(KERN_EMERG "The jester has left the building!\n");
    /* Attempt graceful shutdown */
    emergency_sync();
    emergency_remount();
}
```

---

## 📊 Performance Monitoring

### Kernel Profiling Points
```c
/* Track writing performance */
static void jesteros_perf_checkpoint(const char *name)
{
    if (jesteros_perf_enabled) {
        ktime_t now = ktime_get();
        trace_printk("JESTEROS_PERF: %s at %lld\n", 
                     name, ktime_to_ns(now));
    }
}
```

---

## 🔗 External Interfaces

### Device Tree (if supported)
```dts
jesteros {
    compatible = "nook,jesteros";
    status = "okay";
    memory-limit = <0x800000>;  /* 8MB */
    services = "jester", "tracker", "health";
};
```

### Kernel Command Line
```
console=ttyS0,115200n8 mem=256M jesteros=enabled root=/dev/mmcblk0p2
```

---

## 📝 Notes

- This kernel is specifically tailored for the Nook Simple Touch
- JesterOS services run in userspace for stability
- Memory constraints are strictly enforced to preserve writing space
- E-Ink display requires special refresh handling
- Power management is critical for battery life

---

## 🏰 Philosophy

> "The kernel serves the writer, not the developer"  
> "Every byte saved is a word preserved"  
> "Stability over features, always"

---

*"By quill and candlelight, we kernel for those who write"* 🕯️

*Generated with [Claude Code](https://claude.ai/code)*