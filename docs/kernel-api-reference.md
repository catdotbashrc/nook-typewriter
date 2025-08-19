# 🐧 Kernel API Reference

> **Type**: Reference Documentation  
> **Version**: 2.0.0 (JesterOS + SquireOS Merged)  
> **Kernel**: Linux 2.6.29 for ARM OMAP3  
> **Last Updated**: January 2025

## 📚 Overview

Comprehensive kernel API documentation for the Nook SimpleTouch kernel, including both JesterOS userspace integration and legacy SquireOS module interfaces.

## 📑 Table of Contents

### Core APIs
- [Kernel Configuration](#kernel-configuration)
- [SquireOS Kernel API](#squireos-kernel-api) (Legacy)
- [JesterOS Integration](#jesteros-integration) (Current)
- [NST Hardware Interface](#nst-hardware-interface)

### System Interfaces
- [Proc Filesystem Interface](#proc-filesystem-interface)
- [File System Interface](#file-system-interface)
- [System Calls](#system-calls)

### Hardware Drivers
- [Display Driver API](#display-driver-api)
- [USB Host API](#usb-host-api)
- [Power Management API](#power-management-api)
- [Memory Management](#memory-management)

### Development
- [Module Development Guide](#module-development-guide)
- [Boot Process](#boot-process)
- [Debugging Techniques](#debugging-techniques)

---

## ⚙️ Kernel Configuration

### Configuration Files

#### Primary Config
```bash
source/kernel/src/arch/arm/configs/omap3621_gossamer_evt1c_defconfig
```

#### Key Options
```kconfig
CONFIG_ARM=y
CONFIG_ARCH_OMAP3=y  
CONFIG_OMAP3621_GOSSAMER=y
CONFIG_AEABI=y
CONFIG_ZBOOT_ROM_TEXT=0x0
CONFIG_ZBOOT_ROM_BSS=0x0
CONFIG_CMDLINE="console=ttyS0,115200n8"
CONFIG_VFP=y
CONFIG_NEON=y
```

---

## 🎭 JesterOS Integration

!!! info "Architecture Change"
    JesterOS moved from kernel modules to userspace services for stability.
    The kernel remains clean with services accessed via `/var/jesteros/`.

### Userspace Interface
```bash
/var/jesteros/
├── jester              # ASCII art mood display
├── typewriter/
│   └── stats          # Writing statistics
├── wisdom             # Rotating quotes
└── .wisdom_pool       # Quote database
```

### Service Communication
- **Method**: File-based IPC via `/var/jesteros/`
- **Updates**: Polling or inotify watches
- **Format**: Plain text for easy parsing

---

## 🔧 SquireOS Kernel API (Legacy)

### Core Module Interface

#### squireos_core.c
```c
#include <linux/module.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>

/* Core SquireOS interface */
struct squireos_core {
    struct proc_dir_entry *proc_root;    /* /proc/squireos/ */
    char motto[256];                     /* Current motto */
    unsigned long boot_time;             /* Boot timestamp */
};

/* Module initialization */
static int __init squireos_core_init(void);
static void __exit squireos_core_exit(void);

/* Proc entry creation helpers */
struct proc_dir_entry *squireos_create_proc_entry(
    const char *name,
    umode_t mode,
    const struct file_operations *fops
);

/* Constants */
#define SQUIREOS_PROC_ROOT "squireos"
#define SQUIREOS_VERSION "1.0.0"
#define SQUIREOS_MOTTO_MAX 256
```

#### jester.c
```c
/* Jester mood system */
enum jester_mood {
    JESTER_HAPPY = 0,
    JESTER_THOUGHTFUL,
    JESTER_SLEEPY,
    JESTER_ENCOURAGING,
    JESTER_WISE,
    JESTER_PLAYFUL,
    JESTER_MAX_MOODS
};

struct jester_state {
    enum jester_mood current_mood;
    unsigned long last_update;
    unsigned int interaction_count;
    char ascii_art[2048];
};

/* API Functions */
void jester_update_mood(enum jester_mood new_mood);
const char *jester_get_ascii_art(void);
void jester_set_message(const char *message);

/* Proc interface */
static int jester_proc_show(struct seq_file *m, void *v);
static int jester_proc_open(struct inode *inode, struct file *file);
```

#### typewriter.c
```c
/* Writing statistics tracking */
struct typewriter_stats {
    unsigned long keystrokes;
    unsigned long words;
    unsigned long sessions;
    unsigned long total_time;        /* seconds */
    unsigned long current_session;   /* start time */
    char last_file[256];
    spinlock_t stats_lock;
};

/* Achievement levels */
enum writer_level {
    WRITER_APPRENTICE = 0,      /* 0-1000 words */
    WRITER_SCRIBE,              /* 1000-5000 words */
    WRITER_CHRONICLER,          /* 5000-20000 words */
    WRITER_AUTHOR,              /* 20000-50000 words */
    WRITER_GRAND_CHRONICLER,    /* 50000+ words */
    WRITER_MAX_LEVELS
};

/* API Functions */
void typewriter_record_keystroke(void);
void typewriter_record_word(void);
void typewriter_start_session(const char *filename);
void typewriter_end_session(void);
enum writer_level typewriter_get_level(void);
const char *typewriter_get_level_name(enum writer_level level);

/* Statistics access */
struct typewriter_stats *typewriter_get_stats(void);
```

#### wisdom.c
```c
/* Writing wisdom quotes system */
struct wisdom_quote {
    const char *text;
    const char *author;
    unsigned int weight;    /* Selection probability weight */
};

struct wisdom_state {
    unsigned int current_quote;
    unsigned long last_change;
    unsigned int total_quotes;
    const struct wisdom_quote *quotes;
};

/* API Functions */
const char *wisdom_get_current_quote(void);
const char *wisdom_get_current_author(void);
void wisdom_next_quote(void);
void wisdom_random_quote(void);

/* Quote categories */
#define WISDOM_CATEGORY_GENERAL     0
#define WISDOM_CATEGORY_INSPIRATION 1
#define WISDOM_CATEGORY_CRAFT       2
#define WISDOM_CATEGORY_MEDIEVAL    3
```

---

## NST Hardware Interface

### OMAP3 Platform API
```c
/* OMAP3 specific definitions */
#define OMAP3_NST_GPIO_BASE     0x48000000
#define OMAP3_NST_I2C_BASE      0x48070000
#define OMAP3_NST_SPI_BASE      0x48098000

/* Clock management */
struct omap3_nst_clocks {
    struct clk *sys_clk;
    struct clk *func_clk;
    struct clk *iface_clk;
};

/* Platform device registration */
int omap3_nst_register_device(struct platform_device *pdev);
void omap3_nst_unregister_device(struct platform_device *pdev);
```

### GPIO Interface
```c
/* NST GPIO definitions */
#define NST_GPIO_POWER_BTN      23
#define NST_GPIO_HOME_BTN       24
#define NST_GPIO_USB_ENABLE     25
#define NST_GPIO_WIFI_ENABLE    26
#define NST_GPIO_LED_POWER      27

/* GPIO control functions */
int nst_gpio_request(unsigned gpio, const char *label);
void nst_gpio_free(unsigned gpio);
int nst_gpio_direction_output(unsigned gpio, int value);
int nst_gpio_direction_input(unsigned gpio);
void nst_gpio_set_value(unsigned gpio, int value);
int nst_gpio_get_value(unsigned gpio);
```

---

## Proc Filesystem Interface

### SquireOS Proc Entries
```
/proc/squireos/
├── motto                    # Current system motto
├── version                  # SquireOS version info
├── jester                   # ASCII art jester with mood
├── typewriter/
│   ├── stats               # Writing statistics
│   ├── level               # Current writer level
│   └── session             # Current session info
└── wisdom                   # Current wisdom quote
```

### File Operations Structure
```c
/* Standard proc file operations */
static const struct file_operations squireos_proc_fops = {
    .open       = squireos_proc_open,
    .read       = seq_read,
    .llseek     = seq_lseek,
    .release    = single_release,
    .write      = squireos_proc_write,  /* Optional write support */
};

/* Seq_file interface for complex output */
static int squireos_proc_show(struct seq_file *m, void *v) {
    /* Use seq_printf() for formatted output */
    seq_printf(m, "Field: %s\n", value);
    return 0;
}
```

### Read/Write Examples
```bash
# Reading SquireOS information
cat /proc/squireos/motto
cat /proc/squireos/jester
cat /proc/squireos/typewriter/stats

# Writing to SquireOS (where supported)
echo "new_mood" > /proc/squireos/jester
echo "start_session filename.txt" > /proc/squireos/typewriter/session
```

---

## Display Driver API

### E-Ink Display Interface
```c
/* E-Ink display modes */
enum epd_display_mode {
    EPD_MODE_INIT = 0,
    EPD_MODE_DU,        /* Direct update - fast B&W */
    EPD_MODE_GC16,      /* 16 level grayscale */
    EPD_MODE_GC4,       /* 4 level grayscale */
    EPD_MODE_A2,        /* Animation mode */
    EPD_MODE_GL16,      /* GL16 mode */
    EPD_MODE_REAGL,     /* REAGL mode */
    EPD_MODE_REAGLD,    /* REAGLD mode */
};

/* Update regions */
struct epd_update_region {
    int x, y;           /* Top-left corner */
    int width, height;  /* Dimensions */
    enum epd_display_mode mode;
    unsigned int flags;
};

/* Display update functions */
int epd_full_refresh(void);
int epd_partial_refresh(struct epd_update_region *region);
int epd_set_default_mode(enum epd_display_mode mode);
```

### Framebuffer Integration
```c
/* NST framebuffer device */
#define NST_FB_WIDTH    800
#define NST_FB_HEIGHT   600
#define NST_FB_BPP      8       /* 8 bits per pixel, grayscale */

struct nst_fb_info {
    struct fb_info fb;
    void __iomem *screen_base;
    dma_addr_t screen_dma;
    size_t screen_size;
    struct device *dev;
};

/* FBInk integration for E-Ink optimized text rendering */
int fbink_init(void);
int fbink_print_text(const char *text, int x, int y);
int fbink_clear_screen(void);
int fbink_refresh_area(int x, int y, int w, int h);
```

---

## USB Host API

### Enhanced USB Host Interface
```c
/* NST USB host controller */
struct nst_usb_host {
    struct ehci_hcd *ehci;
    struct clk *usbhost_clk;
    struct clk *usbtll_clk;
    void __iomem *uhh_base;
    void __iomem *tll_base;
};

/* USB host initialization */
int nst_usb_host_init(struct platform_device *pdev);
void nst_usb_host_cleanup(struct platform_device *pdev);

/* Power management */
int nst_usb_host_suspend(struct device *dev);
int nst_usb_host_resume(struct device *dev);

/* Port management */
int nst_usb_host_enable_port(int port);
int nst_usb_host_disable_port(int port);
int nst_usb_host_reset_port(int port);
```

### USB Device Detection
```c
/* USB device callbacks */
struct nst_usb_callbacks {
    void (*device_connected)(struct usb_device *dev);
    void (*device_disconnected)(struct usb_device *dev);
    void (*enumeration_complete)(struct usb_device *dev);
};

/* Registration */
int nst_usb_register_callbacks(struct nst_usb_callbacks *callbacks);
void nst_usb_unregister_callbacks(void);
```

---

## Power Management API

### NST Power States
```c
/* Power management states */
enum nst_power_state {
    NST_POWER_ACTIVE = 0,
    NST_POWER_IDLE,
    NST_POWER_STANDBY,
    NST_POWER_SUSPEND,
    NST_POWER_OFF
};

/* Power management operations */
struct nst_pm_ops {
    int (*suspend)(struct device *dev);
    int (*resume)(struct device *dev);
    int (*poweroff)(struct device *dev);
    int (*restore)(struct device *dev);
};

/* Power state control */
int nst_pm_set_state(enum nst_power_state state);
enum nst_power_state nst_pm_get_state(void);
```

### Battery and Charging
```c
/* Battery status */
struct nst_battery_info {
    int capacity;           /* Percentage 0-100 */
    int voltage;            /* mV */
    int current;            /* mA */
    bool charging;
    bool ac_connected;
    bool usb_connected;
};

/* Battery API */
int nst_battery_get_info(struct nst_battery_info *info);
int nst_battery_register_notifier(struct notifier_block *nb);
void nst_battery_unregister_notifier(struct notifier_block *nb);
```

---

## Module Development Guide

### Module Template
```c
/* SquireOS module template */
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>

/* Module information */
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("SquireOS Custom Module");
MODULE_LICENSE("GPL");
MODULE_VERSION("1.0.0");

/* Module state */
static struct proc_dir_entry *proc_entry;

/* Proc file operations */
static int module_proc_show(struct seq_file *m, void *v) {
    seq_printf(m, "Module Status: Active\n");
    return 0;
}

static int module_proc_open(struct inode *inode, struct file *file) {
    return single_open(file, module_proc_show, NULL);
}

static const struct file_operations module_proc_fops = {
    .open    = module_proc_open,
    .read    = seq_read,
    .llseek  = seq_lseek,
    .release = single_release,
};

/* Module initialization */
static int __init module_init_func(void) {
    printk(KERN_INFO "SquireOS: Loading custom module\n");
    
    /* Create proc entry */
    proc_entry = proc_create("squireos/custom", 0444, NULL, &module_proc_fops);
    if (!proc_entry) {
        printk(KERN_ERR "SquireOS: Failed to create proc entry\n");
        return -ENOMEM;
    }
    
    return 0;
}

/* Module cleanup */
static void __exit module_exit_func(void) {
    printk(KERN_INFO "SquireOS: Unloading custom module\n");
    
    if (proc_entry) {
        remove_proc_entry("squireos/custom", NULL);
    }
}

module_init(module_init_func);
module_exit(module_exit_func);
```

### Makefile Integration
```makefile
# Add to drivers/Makefile
obj-$(CONFIG_SQUIREOS_CUSTOM) += squireos_custom.o

# Kconfig entry
config SQUIREOS_CUSTOM
    tristate "Custom SquireOS Module"
    depends on SQUIREOS
    help
      Enable custom SquireOS functionality.
```

### Debug and Testing
```c
/* Debug macros */
#define SQUIREOS_DEBUG 1

#if SQUIREOS_DEBUG
#define squireos_dbg(fmt, args...) \
    printk(KERN_DEBUG "SquireOS: " fmt, ##args)
#else
#define squireos_dbg(fmt, args...)
#endif

/* Error handling */
#define squireos_err(fmt, args...) \
    printk(KERN_ERR "SquireOS: " fmt, ##args)

#define squireos_info(fmt, args...) \
    printk(KERN_INFO "SquireOS: " fmt, ##args)
```

---

## Error Codes and Constants

### Return Values
```c
/* SquireOS specific error codes */
#define SQUIREOS_SUCCESS        0
#define SQUIREOS_ERROR         -1
#define SQUIREOS_INVALID_PARAM -2
#define SQUIREOS_NO_MEMORY     -3
#define SQUIREOS_NOT_FOUND     -4
#define SQUIREOS_BUSY          -5
#define SQUIREOS_TIMEOUT       -6
```

### Configuration Constants
```c
/* Memory limits */
#define SQUIREOS_MAX_MODULES    16
#define SQUIREOS_MAX_PROC_NAME  64
#define SQUIREOS_MAX_MESSAGE    1024

/* Timing constants */
#define SQUIREOS_JESTER_UPDATE_MS   30000   /* 30 seconds */
#define SQUIREOS_WISDOM_UPDATE_MS   300000  /* 5 minutes */
#define SQUIREOS_STATS_SAVE_MS      60000   /* 1 minute */
```

---

*API documentation for NST Kernel and SquireOS integration*
*Version: 1.0.0*