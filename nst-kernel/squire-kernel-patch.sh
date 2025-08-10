#!/bin/bash
# Apply SquireOS branding patches to kernel source
# "The method borrowed from the Chinese pharmacy is most crude" - A wise philosopher

echo "═══════════════════════════════════════════════════════════════"
echo "     Applying QuillKernel Medieval Patches"
echo "═══════════════════════════════════════════════════════════════"

cd "$(dirname "$0")/src" || exit 1

# 1. Patch the main Makefile
echo "✎ Updating kernel identity..."
cat > squire-makefile.patch << 'EOF'
--- Makefile.orig
+++ Makefile
@@ -2,8 +2,8 @@
 PATCHLEVEL = 6
 SUBLEVEL = 29
-EXTRAVERSION =
-NAME = Temporary Tasmanian Devil
+EXTRAVERSION = -quill-scribe
+NAME = Derpy Court Jester
 
 # *DOCUMENTATION*
EOF
patch -p0 < squire-makefile.patch || echo "Makefile already patched"

# 2. Add SquireOS header file
echo "✎ Creating SquireOS definitions..."
mkdir -p include/linux
cat > include/linux/squireos.h << 'EOF'
#ifndef _LINUX_SQUIREOS_H
#define _LINUX_SQUIREOS_H

#define SQUIREOS_VERSION "1.0.0"
#define SQUIREOS_CODENAME "Parchment"
#define SQUIRE_MOTTO "By quill and candlelight"

/* Jester states for kernel messages */
#define JESTER_HAPPY    0x01
#define JESTER_CONFUSED 0x02  
#define JESTER_SLEEPY   0x03
#define JESTER_ERROR    0x04
#define JESTER_WRITING  0x05

/* Writing wisdom from mysterious sages */
static const char *squire_wisdoms[] = {
    "Do not force yourself to write when you have nothing to say.",
    "Writers are engineers of human souls.",
    "The method borrowed from the Chinese pharmacy is most crude.",
    "Pay close attention to all manner of things; observe more.",
    "Read it over twice and strike out non-essential words.",
    "Literature must become a cog in one great mechanism.",
    "Avoid the Chinese pharmacy method!",
    NULL
};

/* Get a random wisdom */
static inline const char *squire_get_wisdom(void)
{
    static int wisdom_idx = 0;
    if (squire_wisdoms[wisdom_idx] == NULL)
        wisdom_idx = 0;
    return squire_wisdoms[wisdom_idx++];
}

#endif /* _LINUX_SQUIREOS_H */
EOF

# 3. Patch kernel version display
echo "✎ Modifying version strings..."
cat > init/version-squire.patch << 'EOF'
--- init/version.c.orig
+++ init/version.c
@@ -37,7 +37,11 @@
 /* FIXED STRINGS! Don't touch! */
 const char linux_banner[] =
 	"Linux version " UTS_RELEASE " (" LINUX_COMPILE_BY "@"
-	LINUX_COMPILE_HOST ") (" LINUX_COMPILER ") " UTS_VERSION "\n";
+	LINUX_COMPILE_HOST ") (" LINUX_COMPILER ") " UTS_VERSION "\n"
+	"    .~\"~.~\"~.\n"
+	"   /  o   o  \\    QuillKernel - Your faithful digital squire\n"
+	"  |  >  ◡  <  |   \"By quill and candlelight\"\n"
+	"   \\  ___  /      \n"
+	"    |~|♦|~|       \n";
 
 const char linux_proc_banner[] =
 	"%s version %s"
EOF
patch -p0 < init/version-squire.patch || echo "Version already patched"

# 4. Add boot hooks to gossamer board file
echo "✎ Adding boot messages to board file..."
if [ -f arch/arm/mach-omap2/board-omap3621_gossamer.c ]; then
    # Add include at top of file
    sed -i '1s/^/#include <linux\/squireos.h>\n/' arch/arm/mach-omap2/board-omap3621_gossamer.c
    
    # Add boot banner call
    cat >> arch/arm/mach-omap2/board-omap3621_gossamer.c << 'EOF'

/* SquireOS Boot Hook */
static int __init squire_boot_init(void)
{
    extern void squire_print_boot_banner(void);
    squire_print_boot_banner();
    return 0;
}
arch_initcall(squire_boot_init);
EOF
fi

# 5. Create /proc/squireos module
echo "✎ Creating /proc/squireos entries..."
mkdir -p drivers/squireos
cat > drivers/squireos/Makefile << 'EOF'
obj-$(CONFIG_SQUIREOS_BRANDING) += squireos_proc.o
EOF

cat > drivers/squireos/squireos_proc.c << 'EOF'
/*
 * /proc/squireos - Your window into the medieval scriptorium
 */
#include <linux/module.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/squireos.h>

static struct proc_dir_entry *squireos_root;

static int motto_show(struct seq_file *m, void *v)
{
    seq_printf(m, "%s\n", SQUIRE_MOTTO);
    return 0;
}

static int wisdom_show(struct seq_file *m, void *v)
{
    seq_printf(m, "%s\n", squire_get_wisdom());
    seq_printf(m, "        - A mysterious sage\n");
    return 0;
}

static int jester_show(struct seq_file *m, void *v)
{
    seq_printf(m, "    .~\"~.~\"~.\n");
    seq_printf(m, "   /  o   o  \\    Your faithful squire\n");
    seq_printf(m, "  |  >  ◡  <  |   Version: %s\n", SQUIREOS_VERSION);
    seq_printf(m, "   \\  ___  /      Codename: %s\n", SQUIREOS_CODENAME);
    seq_printf(m, "    |~|♦|~|       \n");
    seq_printf(m, "   d|     |b      'I dropped the quill!'\n");
    return 0;
}

static int motto_open(struct inode *inode, struct file *file)
{
    return single_open(file, motto_show, NULL);
}

static int wisdom_open(struct inode *inode, struct file *file)
{
    return single_open(file, wisdom_show, NULL);
}

static int jester_open(struct inode *inode, struct file *file)
{
    return single_open(file, jester_show, NULL);
}

static const struct file_operations motto_fops = {
    .owner   = THIS_MODULE,
    .open    = motto_open,
    .read    = seq_read,
    .llseek  = seq_lseek,
    .release = single_release,
};

static const struct file_operations wisdom_fops = {
    .owner   = THIS_MODULE,
    .open    = wisdom_open,
    .read    = seq_read,
    .llseek  = seq_lseek,
    .release = single_release,
};

static const struct file_operations jester_fops = {
    .owner   = THIS_MODULE,
    .open    = jester_open,
    .read    = seq_read,
    .llseek  = seq_lseek,
    .release = single_release,
};

static int __init squireos_proc_init(void)
{
    squireos_root = proc_mkdir("squireos", NULL);
    if (!squireos_root)
        return -ENOMEM;
        
    proc_create("motto", 0444, squireos_root, &motto_fops);
    proc_create("wisdom", 0444, squireos_root, &wisdom_fops);
    proc_create("jester", 0444, squireos_root, &jester_fops);
    
    printk(KERN_INFO "[Jester] /proc/squireos scrolls have been unfurled!\n");
    return 0;
}

static void __exit squireos_proc_exit(void)
{
    remove_proc_entry("jester", squireos_root);
    remove_proc_entry("wisdom", squireos_root);
    remove_proc_entry("motto", squireos_root);
    remove_proc_entry("squireos", NULL);
}

module_init(squireos_proc_init);
module_exit(squireos_proc_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("The Derpy Court Jester");
MODULE_DESCRIPTION("SquireOS /proc interface");
EOF

# 6. Add to drivers/Makefile
echo "obj-\$(CONFIG_SQUIREOS_BRANDING) += squireos/" >> drivers/Makefile

# 7. Add Kconfig entries
echo "✎ Adding configuration scrolls..."
cat >> drivers/Kconfig << 'EOF'

source "drivers/squireos/Kconfig"
EOF

cat > drivers/squireos/Kconfig << 'EOF'
menu "SquireOS Medieval Features"

config SQUIREOS_BRANDING
	bool "Enable SquireOS Medieval Branding"
	default y
	help
	  This option enables SquireOS medieval theming throughout
	  the kernel, including custom boot messages, /proc entries,
	  and your faithful court jester mascot.
	  
	  Features include:
	  - Medieval boot messages
	  - /proc/squireos interface  
	  - Jester ASCII art
	  - Writing wisdom from mysterious sages
	  
	  If unsure, say Y - your squire insists!

config QUILL_MODE
	bool "QuillKernel Writing Optimizations"
	depends on SQUIREOS_BRANDING
	default y
	help
	  Optimizes the kernel for digital writing:
	  - Better USB keyboard handling
	  - Power management for long sessions
	  - Avoids the Chinese pharmacy method
	  
	  Recommended by rural librarians everywhere.

config SQUIRE_DEBUG
	bool "Enable Jester Debug Messages"
	depends on SQUIREOS_BRANDING
	help
	  Enables additional debug messages from your
	  court jester. May include silly comments and
	  observations about kernel operations.

endmenu
EOF

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "          QuillKernel Patches Applied!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "     .~\"~.~\"~."
echo "    /  ^   ^  \\    Success! The kernel has been"
echo "   |  >  ◡  <  |   transformed into QuillKernel!"
echo "    \\  ___  /      "
echo "     |~|♦|~|       "
echo "    d|     |b      "
echo ""
echo "Next steps:"
echo "1. cd src/"
echo "2. make quill_typewriter_defconfig"
echo "3. make uImage"
echo ""
echo "New features:"
echo "  • Medieval boot banner"
echo "  • /proc/squireos/motto"
echo "  • /proc/squireos/wisdom"
echo "  • /proc/squireos/jester"
echo "  • Easter eggs in dmesg"
echo ""