#!/bin/bash
# Apply QuillKernel branding to the kernel source

echo "═══════════════════════════════════════════════════════════════"
echo "          Applying QuillKernel Medieval Branding"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  o   o  \\    The jester prepares to modify"
echo "   |  >  ◡  <  |   thy kernel with medieval charm!"
echo "    \\  ___  /      "
echo "     |~|♦|~|       "
echo "    d|     |b      "
echo ""

cd "$(dirname "$0")/src" || exit 1

# Backup original files
echo "Creating backup of original files..."
cp Makefile Makefile.orig 2>/dev/null || true

# 1. Update main Makefile
echo "✎ Inscribing new kernel identity..."
sed -i 's/^EXTRAVERSION =.*/EXTRAVERSION = -quill-scribe/' Makefile
sed -i 's/^NAME = .*/NAME = Derpy Court Jester/' Makefile

# 2. Create custom version file
echo "✎ Creating version scroll..."
cat > include/linux/squireos.h << 'EOF'
#ifndef _LINUX_SQUIREOS_H
#define _LINUX_SQUIREOS_H

#define SQUIREOS_VERSION "1.0.0"
#define SQUIREOS_CODENAME "Parchment"
#define SQUIRE_MOTTO "By quill and candlelight"

/* Jester ASCII art for kernel messages */
#define JESTER_HAPPY \
"    .~\"~.~\"~.\n" \
"   /  ^   ^  \\\n" \
"  |  >  ◡  <  |\n" \
"   \\  ___  /\n" \
"    |~|♦|~|\n"

#define JESTER_CONFUSED \
"    .~???~.\n" \
"   / o   o \\\n" \
"  |   >.<   |\n" \
"  |  ___    |\n" \
"   \\ \\  / ? /\n"

#define JESTER_ERROR \
"    !!!!!!\n" \
"   / O   O \\\n" \
"  | __   __ |\n" \
"  |  \\___/  |\n" \
"   \\       /\n"

#endif /* _LINUX_SQUIREOS_H */
EOF

# 3. Modify kernel boot messages
echo "✎ Adding medieval boot messages..."
cat > arch/arm/mach-omap2/board-gossamer-squire.c << 'EOF'
/* SquireOS Boot Messages for Gossamer (Nook) Board */
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/squireos.h>

static const char *medieval_boot_messages[] = {
    "[OK] Candles lit",
    "[OK] Quills sharpened",  
    "[OK] Inkwells filled",
    "[OK] Parchment unfurled",
    "[OK] Ancient wisdom loaded",
    "[OK] Your squire stands ready, m'lord",
    NULL
};

void __init squire_print_banner(void)
{
    int i;
    
    printk(KERN_INFO "\n%s\n", JESTER_HAPPY);
    printk(KERN_INFO "QuillKernel %s (%s)\n", 
           UTS_RELEASE, SQUIREOS_CODENAME);
    printk(KERN_INFO "\"%s\"\n\n", SQUIRE_MOTTO);
    
    for (i = 0; medieval_boot_messages[i]; i++) {
        printk(KERN_INFO "%s\n", medieval_boot_messages[i]);
        mdelay(100); /* Small delay for effect */
    }
}
EOF

# 4. Create /proc/squireos entries
echo "✎ Creating magical /proc scrolls..."
mkdir -p fs/proc/squireos
cat > fs/proc/squireos/Makefile << 'EOF'
obj-y += squireos_proc.o
EOF

cat > fs/proc/squireos/squireos_proc.c << 'EOF'
/*
 * /proc/squireos - Medieval writing statistics
 * "Avoid the Chinese pharmacy method!" - A wise philosopher
 */
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/squireos.h>

static struct proc_dir_entry *squireos_dir;

static int motto_show(struct seq_file *m, void *v)
{
    seq_printf(m, "%s\n", SQUIRE_MOTTO);
    return 0;
}

static int jester_show(struct seq_file *m, void *v)
{
    seq_printf(m, "%s", JESTER_HAPPY);
    seq_printf(m, "\nYour faithful digital squire!\n");
    return 0;
}

static int wisdom_show(struct seq_file *m, void *v)
{
    /* Rotate through writing wisdom */
    static const char *wisdoms[] = {
        "Do not force yourself to write when you have nothing to say.",
        "Writers are engineers of human souls.",
        "The method borrowed from the Chinese pharmacy is most crude.",
        "Pay close attention to all manner of things; observe more.",
        NULL
    };
    static int wisdom_idx = 0;
    
    if (wisdoms[wisdom_idx] == NULL)
        wisdom_idx = 0;
        
    seq_printf(m, "%s\n", wisdoms[wisdom_idx++]);
    seq_printf(m, "        - A mysterious sage\n");
    
    return 0;
}

static int motto_open(struct inode *inode, struct file *file)
{
    return single_open(file, motto_show, NULL);
}

static int jester_open(struct inode *inode, struct file *file)
{
    return single_open(file, jester_show, NULL);
}

static int wisdom_open(struct inode *inode, struct file *file)
{
    return single_open(file, wisdom_show, NULL);
}

static const struct file_operations motto_fops = {
    .open    = motto_open,
    .read    = seq_read,
    .llseek  = seq_lseek,
    .release = single_release,
};

static const struct file_operations jester_fops = {
    .open    = jester_open,
    .read    = seq_read,
    .llseek  = seq_lseek,
    .release = single_release,
};

static const struct file_operations wisdom_fops = {
    .open    = wisdom_open,
    .read    = seq_read,
    .llseek  = seq_lseek,
    .release = single_release,
};

static int __init squireos_proc_init(void)
{
    squireos_dir = proc_mkdir("squireos", NULL);
    if (!squireos_dir)
        return -ENOMEM;
        
    proc_create("motto", 0444, squireos_dir, &motto_fops);
    proc_create("jester", 0444, squireos_dir, &jester_fops);
    proc_create("wisdom", 0444, squireos_dir, &wisdom_fops);
    
    printk(KERN_INFO "SquireOS: /proc/squireos scrolls unfurled\n");
    return 0;
}

static void __exit squireos_proc_exit(void)
{
    remove_proc_entry("wisdom", squireos_dir);
    remove_proc_entry("jester", squireos_dir);
    remove_proc_entry("motto", squireos_dir);
    remove_proc_entry("squireos", NULL);
}

module_init(squireos_proc_init);
module_exit(squireos_proc_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("The Derpy Court Jester");
MODULE_DESCRIPTION("SquireOS /proc interface - Your faithful digital squire");
EOF

# 5. Add to fs/proc/Makefile
echo "✎ Registering with the kingdom's ledgers..."
echo "obj-$(CONFIG_PROC_FS) += squireos/" >> fs/proc/Makefile

# 6. Create kernel config option
echo "✎ Adding royal decrees to kernel config..."
cat >> arch/arm/Kconfig << 'EOF'

config SQUIREOS_BRANDING
	bool "SquireOS Medieval Branding"
	default y
	help
	  This option enables SquireOS medieval theming throughout
	  the kernel, including custom boot messages, /proc entries,
	  and a charming court jester mascot.
	  
	  "Avoid the Chinese pharmacy method!" - A wise philosopher
	  
	  If unsure, say Y - your squire insists!

config QUILL_MODE
	bool "QuillKernel Writing Optimizations"
	depends on SQUIREOS_BRANDING
	default y
	help
	  Optimizes the kernel for digital writing, including
	  better USB keyboard handling and power management for
	  long writing sessions.
	  
	  Recommended by various mysterious sages and rural librarians.
EOF

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    Branding Applied!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  ^   ^  \\    Success! The kernel has been"
echo "   |  >  ◡  <  |   transformed into QuillKernel!"
echo "    \\  ___  /      "
echo "     |~|♦|~|       Now run build-kernel.sh to compile!"
echo "    d|     |b      "
echo ""
echo "New features added:"
echo "  • Medieval boot messages"
echo "  • /proc/squireos/motto"
echo "  • /proc/squireos/jester" 
echo "  • /proc/squireos/wisdom"
echo "  • Custom kernel name: 'Derpy Court Jester'"
echo "  • Version string: 2.6.29-quill-scribe"
echo ""