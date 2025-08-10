/*
 * QuillKernel Typewriter Module
 * 
 * Tracks writing statistics and provides typewriter-specific features
 * "Writers are engineers of human souls" - A mustachioed Georgian poet
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/input.h>
#include <linux/time.h>
#include <linux/rtc.h>
#include <linux/squireos.h>

#define TYPEWRITER_VERSION "1.0"
#define WORDS_PER_PAGE 250

/* Writing statistics */
static struct {
    unsigned long keystrokes_total;
    unsigned long keystrokes_today;
    unsigned long words_total;
    unsigned long words_today;
    unsigned long sessions_total;
    unsigned long writing_time_seconds;
    struct timespec session_start;
    struct timespec last_keystroke;
    int session_active;
    int streak_days;
    unsigned long last_save_jiffies;
} writing_stats;

/* Procfs directory */
static struct proc_dir_entry *typewriter_dir;

/* Calculate words from keystrokes (rough estimate) */
static unsigned long keystrokes_to_words(unsigned long keystrokes)
{
    /* Average 5 characters per word + space */
    return keystrokes / 6;
}

/* Check if we're in a new day */
static int is_new_day(void)
{
    static int last_day = -1;
    struct rtc_time tm;
    struct timespec now;
    
    getnstimeofday(&now);
    rtc_time_to_tm(now.tv_sec, &tm);
    
    if (tm.tm_mday != last_day) {
        last_day = tm.tm_mday;
        return 1;
    }
    return 0;
}

/* Input event handler for keystroke tracking */
static void typewriter_input_event(struct input_handle *handle, 
                                  unsigned int type, unsigned int code, int value)
{
    struct timespec now;
    
    if (type != EV_KEY || value != 1) /* Only count key presses */
        return;
        
    getnstimeofday(&now);
    
    /* Check for new day */
    if (is_new_day()) {
        writing_stats.keystrokes_today = 0;
        writing_stats.words_today = 0;
        writing_stats.streak_days++;
    }
    
    /* Start new session if idle for >30 minutes */
    if (!writing_stats.session_active || 
        (now.tv_sec - writing_stats.last_keystroke.tv_sec) > 1800) {
        writing_stats.session_active = 1;
        writing_stats.session_start = now;
        writing_stats.sessions_total++;
        printk(KERN_INFO "[Jester] A new writing session begins! Quill at the ready!\n");
    }
    
    /* Update statistics */
    writing_stats.keystrokes_total++;
    writing_stats.keystrokes_today++;
    writing_stats.last_keystroke = now;
    
    /* Update word counts */
    writing_stats.words_total = keystrokes_to_words(writing_stats.keystrokes_total);
    writing_stats.words_today = keystrokes_to_words(writing_stats.keystrokes_today);
    
    /* Milestone messages */
    if (writing_stats.words_today > 0 && writing_stats.words_today % 100 == 0) {
        printk(KERN_INFO "[Jester] Huzzah! %lu words today! Keep thy quill moving!\n",
               writing_stats.words_today);
    }
    
    if (writing_stats.words_today == 1000) {
        printk(KERN_INFO "    \\o/~.~\\o/\n");
        printk(KERN_INFO "     | ^ ^ |    ACHIEVEMENT UNLOCKED!\n");
        printk(KERN_INFO "     | > < |    Thousand Word Scribe!\n");
        printk(KERN_INFO "     \\ ‿‿‿ /    Thy dedication is admirable!\n");
        printk(KERN_INFO "      |♦|♦|     \n");
    }
}

/* Input device connect */
static int typewriter_input_connect(struct input_handler *handler,
                                   struct input_dev *dev,
                                   const struct input_device_id *id)
{
    struct input_handle *handle;
    int error;
    
    handle = kzalloc(sizeof(struct input_handle), GFP_KERNEL);
    if (!handle)
        return -ENOMEM;
        
    handle->dev = dev;
    handle->handler = handler;
    handle->name = "typewriter";
    
    error = input_register_handle(handle);
    if (error)
        goto err_free_handle;
        
    error = input_open_device(handle);
    if (error)
        goto err_unregister_handle;
        
    printk(KERN_INFO "[Jester] New writing instrument connected: %s\n", dev->name);
    return 0;
    
err_unregister_handle:
    input_unregister_handle(handle);
err_free_handle:
    kfree(handle);
    return error;
}

/* Input device disconnect */
static void typewriter_input_disconnect(struct input_handle *handle)
{
    printk(KERN_INFO "[Jester] Writing instrument disconnected: %s\n", 
           handle->dev->name);
    input_close_device(handle);
    input_unregister_handle(handle);
    kfree(handle);
}

/* Input device IDs we're interested in */
static const struct input_device_id typewriter_ids[] = {
    {
        .flags = INPUT_DEVICE_ID_MATCH_EVBIT,
        .evbit = { BIT_MASK(EV_KEY) },
    },
    { },
};

/* Input handler */
static struct input_handler typewriter_input_handler = {
    .event      = typewriter_input_event,
    .connect    = typewriter_input_connect,
    .disconnect = typewriter_input_disconnect,
    .name       = "typewriter",
    .id_table   = typewriter_ids,
};

/* /proc/squireos/typewriter/stats */
static int stats_show(struct seq_file *m, void *v)
{
    unsigned long pages = writing_stats.words_total / WORDS_PER_PAGE;
    struct timespec now;
    unsigned long session_time = 0;
    
    getnstimeofday(&now);
    if (writing_stats.session_active) {
        session_time = now.tv_sec - writing_stats.session_start.tv_sec;
    }
    
    seq_printf(m, "═══════════════════════════════════════════\n");
    seq_printf(m, "         Thy Writing Chronicle\n");
    seq_printf(m, "═══════════════════════════════════════════\n");
    seq_printf(m, "\n");
    seq_printf(m, "Today's Progress:\n");
    seq_printf(m, "  Words: %lu\n", writing_stats.words_today);
    seq_printf(m, "  Keystrokes: %lu\n", writing_stats.keystrokes_today);
    seq_printf(m, "\n");
    seq_printf(m, "Lifetime Achievements:\n");
    seq_printf(m, "  Total Words: %lu\n", writing_stats.words_total);
    seq_printf(m, "  Total Pages: %lu\n", pages);
    seq_printf(m, "  Writing Sessions: %lu\n", writing_stats.sessions_total);
    seq_printf(m, "  Writing Streak: %d days\n", writing_stats.streak_days);
    seq_printf(m, "\n");
    if (writing_stats.session_active) {
        seq_printf(m, "Current Session: %lu minutes\n", session_time / 60);
    }
    seq_printf(m, "\n");
    seq_printf(m, "═══════════════════════════════════════════\n");
    
    return 0;
}

/* /proc/squireos/typewriter/milestone */
static int milestone_show(struct seq_file *m, void *v)
{
    unsigned long words = writing_stats.words_total;
    const char *title = "Apprentice Scribe";
    const char *next_goal = "1,000 words";
    unsigned long next_milestone = 1000;
    
    if (words >= 100000) {
        title = "Grand Chronicler";
        next_goal = "Glory eternal!";
        next_milestone = 0;
    } else if (words >= 50000) {
        title = "Master Illuminator";
        next_goal = "100,000 words";
        next_milestone = 100000;
    } else if (words >= 10000) {
        title = "Journeyman Wordsmith";
        next_goal = "50,000 words";
        next_milestone = 50000;
    } else if (words >= 1000) {
        title = "Apprentice Scribe";
        next_goal = "10,000 words";
        next_milestone = 10000;
    }
    
    seq_printf(m, "    .~\"~.~\"~.\n");
    seq_printf(m, "   /  o   o  \\    Current Title:\n");
    seq_printf(m, "  |  >  ◡  <  |   %s\n", title);
    seq_printf(m, "   \\  ___  /      \n");
    seq_printf(m, "    |~|♦|~|       Next Goal: %s\n", next_goal);
    seq_printf(m, "   d|     |b      \n");
    
    if (next_milestone > 0) {
        unsigned long remaining = next_milestone - words;
        seq_printf(m, "\n%lu words until thy next achievement!\n", remaining);
    }
    
    return 0;
}

static int stats_open(struct inode *inode, struct file *file)
{
    return single_open(file, stats_show, NULL);
}

static int milestone_open(struct inode *inode, struct file *file)
{
    return single_open(file, milestone_show, NULL);
}

static const struct file_operations stats_fops = {
    .owner   = THIS_MODULE,
    .open    = stats_open,
    .read    = seq_read,
    .llseek  = seq_lseek,
    .release = single_release,
};

static const struct file_operations milestone_fops = {
    .owner   = THIS_MODULE,
    .open    = milestone_open,
    .read    = seq_read,
    .llseek  = seq_lseek,
    .release = single_release,
};

/* Module initialization */
static int __init typewriter_init(void)
{
    int ret;
    
    /* Create /proc/squireos/typewriter directory */
    typewriter_dir = proc_mkdir("typewriter", NULL);
    if (!typewriter_dir) {
        /* Try under squireos if it exists */
        struct proc_dir_entry *squireos_dir = proc_mkdir("squireos", NULL);
        if (squireos_dir)
            typewriter_dir = proc_mkdir("typewriter", squireos_dir);
    }
    
    if (!typewriter_dir) {
        printk(KERN_ERR "[Jester] Failed to create typewriter scroll storage!\n");
        return -ENOMEM;
    }
    
    /* Create proc entries */
    proc_create("stats", 0444, typewriter_dir, &stats_fops);
    proc_create("milestone", 0444, typewriter_dir, &milestone_fops);
    
    /* Register input handler */
    ret = input_register_handler(&typewriter_input_handler);
    if (ret) {
        printk(KERN_ERR "[Jester] Failed to register quill tracker!\n");
        remove_proc_entry("milestone", typewriter_dir);
        remove_proc_entry("stats", typewriter_dir);
        remove_proc_entry("typewriter", NULL);
        return ret;
    }
    
    /* Initialize stats */
    memset(&writing_stats, 0, sizeof(writing_stats));
    writing_stats.streak_days = 1; /* Start with day 1 */
    
    printk(KERN_INFO "[Jester] QuillKernel Typewriter Module loaded!\n");
    printk(KERN_INFO "[Jester] Ready to track thy literary endeavors!\n");
    
    return 0;
}

/* Module cleanup */
static void __exit typewriter_exit(void)
{
    input_unregister_handler(&typewriter_input_handler);
    
    remove_proc_entry("milestone", typewriter_dir);
    remove_proc_entry("stats", typewriter_dir);
    remove_proc_entry("typewriter", NULL);
    
    printk(KERN_INFO "[Jester] Typewriter module unloaded. Write on!\n");
}

module_init(typewriter_init);
module_exit(typewriter_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("The Derpy Court Jester");
MODULE_DESCRIPTION("QuillKernel Typewriter - Tracks thy writing progress");
MODULE_VERSION(TYPEWRITER_VERSION);