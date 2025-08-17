/*
 * button-daemon.c - Low-level button event daemon for JesterOS
 * Monitors physical buttons via Linux input subsystem
 * 
 * Compile: arm-linux-gnueabi-gcc -static -o button-daemon button-daemon.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <linux/input.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>

/* Input devices (from reverse engineering) */
#define INPUT_GPIO    "/dev/input/event0"  /* Power & Home buttons */
#define INPUT_TWL     "/dev/input/event1"  /* Page turn buttons */

/* Key codes (from input.h) */
#define KEY_HOME      102
#define KEY_PAGEUP    104
#define KEY_PAGEDOWN  109
#define KEY_POWER     116

/* JesterOS status files */
#define STATUS_DIR    "/var/jesteros/buttons/"
#define LOG_FILE      "/var/log/button-daemon.log"

/* Button states */
typedef struct {
    int power;
    int home;
    int page_left;
    int page_right;
    struct timeval power_press_time;
    struct timeval last_event;
} button_state_t;

static button_state_t buttons = {0};
static volatile int running = 1;
static FILE *logfile = NULL;

/* Signal handler for clean shutdown */
void signal_handler(int sig) {
    running = 0;
}

/* Initialize status directory */
int init_status_dir() {
    struct stat st = {0};
    
    if (stat("/var/jesteros", &st) == -1) {
        mkdir("/var/jesteros", 0755);
    }
    
    if (stat(STATUS_DIR, &st) == -1) {
        mkdir(STATUS_DIR, 0755);
    }
    
    return 0;
}

/* Write button status to file */
void update_status(const char *button, const char *status) {
    char path[256];
    FILE *f;
    
    snprintf(path, sizeof(path), "%s%s", STATUS_DIR, button);
    f = fopen(path, "w");
    if (f) {
        fprintf(f, "%s\n", status);
        fclose(f);
    }
}

/* Log button event */
void log_event(const char *msg) {
    struct timeval tv;
    struct tm *tm_info;
    char time_str[26];
    
    if (!logfile) return;
    
    gettimeofday(&tv, NULL);
    tm_info = localtime(&tv.tv_sec);
    strftime(time_str, 26, "%H:%M:%S", tm_info);
    
    fprintf(logfile, "[%s.%03ld] %s\n", time_str, tv.tv_usec / 1000, msg);
    fflush(logfile);
}

/* Calculate time difference in milliseconds */
long time_diff_ms(struct timeval *start, struct timeval *end) {
    return (end->tv_sec - start->tv_sec) * 1000 + 
           (end->tv_usec - start->tv_usec) / 1000;
}

/* Handle power button events */
void handle_power_button(int value) {
    static int long_press_triggered = 0;
    
    if (value == 1) { /* Press */
        buttons.power = 1;
        gettimeofday(&buttons.power_press_time, NULL);
        long_press_triggered = 0;
        update_status("power", "pressed");
        log_event("Power button pressed");
        
    } else if (value == 0) { /* Release */
        struct timeval now;
        gettimeofday(&now, NULL);
        long press_duration = time_diff_ms(&buttons.power_press_time, &now);
        
        buttons.power = 0;
        update_status("power", "released");
        
        if (press_duration > 2000 && !long_press_triggered) {
            /* Long press - trigger sleep/wake */
            log_event("Power button long press - sleep/wake");
            system("echo mem > /sys/power/state 2>/dev/null");
        } else if (press_duration < 500) {
            /* Short press - show power menu */
            log_event("Power button short press - menu");
            system("/runtime/1-ui/menu/power-menu.sh &");
        }
        
        log_event("Power button released");
    }
}

/* Handle home button events */
void handle_home_button(int value) {
    if (value == 1) { /* Press */
        buttons.home = 1;
        update_status("home", "pressed");
        log_event("Home button pressed");
        
        /* Return to main menu */
        system("pkill -f vim 2>/dev/null");
        system("/runtime/1-ui/menu/nook-menu.sh &");
        
    } else if (value == 0) { /* Release */
        buttons.home = 0;
        update_status("home", "released");
        log_event("Home button released");
    }
}

/* Handle page turn buttons */
void handle_page_left(int value) {
    if (value == 1) { /* Press */
        buttons.page_left = 1;
        update_status("page_left", "pressed");
        log_event("Left page button pressed");
        
        /* Send page up command */
        if (system("pgrep -x vim > /dev/null") == 0) {
            /* Vim is running - send Ctrl+B */
            system("echo -e '\\x02' > /proc/$(pgrep -x vim)/fd/0 2>/dev/null");
        }
        
    } else if (value == 0) { /* Release */
        buttons.page_left = 0;
        update_status("page_left", "released");
    }
}

void handle_page_right(int value) {
    if (value == 1) { /* Press */
        buttons.page_right = 1;
        update_status("page_right", "pressed");
        log_event("Right page button pressed");
        
        /* Send page down command */
        if (system("pgrep -x vim > /dev/null") == 0) {
            /* Vim is running - send Ctrl+F */
            system("echo -e '\\x06' > /proc/$(pgrep -x vim)/fd/0 2>/dev/null");
        }
        
    } else if (value == 0) { /* Release */
        buttons.page_right = 0;
        update_status("page_right", "released");
    }
}

/* Check for button combinations */
void check_combinations() {
    /* Power + Home = Screenshot */
    if (buttons.power && buttons.home) {
        log_event("Screenshot combination detected");
        system("fbgrab /sdcard/screenshot_$(date +%Y%m%d_%H%M%S).png 2>/dev/null");
        update_status("last_action", "screenshot");
    }
    
    /* Both page buttons = Toggle writing mode */
    if (buttons.page_left && buttons.page_right) {
        static int writing_mode = 0;
        writing_mode = !writing_mode;
        
        log_event(writing_mode ? "Writing mode ON" : "Writing mode OFF");
        update_status("writing_mode", writing_mode ? "on" : "off");
        
        if (writing_mode) {
            /* Apply writing optimizations */
            system("/runtime/4-hardware/power/power-optimizer.sh balanced");
        }
    }
}

/* Process input event */
void process_event(struct input_event *ev) {
    if (ev->type != EV_KEY) return;
    
    gettimeofday(&buttons.last_event, NULL);
    
    switch (ev->code) {
        case KEY_POWER:
            handle_power_button(ev->value);
            break;
            
        case KEY_HOME:
            handle_home_button(ev->value);
            break;
            
        case KEY_PAGEUP:
            handle_page_left(ev->value);
            break;
            
        case KEY_PAGEDOWN:
            handle_page_right(ev->value);
            break;
            
        default:
            /* Unknown key */
            break;
    }
    
    check_combinations();
}

/* Monitor input device */
void monitor_device(const char *device) {
    int fd;
    struct input_event ev;
    fd_set fds;
    struct timeval tv;
    int ret;
    
    fd = open(device, O_RDONLY);
    if (fd < 0) {
        fprintf(stderr, "Failed to open %s: %s\n", device, strerror(errno));
        return;
    }
    
    log_event("Monitoring device");
    
    while (running) {
        FD_ZERO(&fds);
        FD_SET(fd, &fds);
        
        /* 100ms timeout for periodic checks */
        tv.tv_sec = 0;
        tv.tv_usec = 100000;
        
        ret = select(fd + 1, &fds, NULL, NULL, &tv);
        
        if (ret > 0 && FD_ISSET(fd, &fds)) {
            if (read(fd, &ev, sizeof(ev)) == sizeof(ev)) {
                process_event(&ev);
            }
        }
        
        /* Check for long press timeout */
        if (buttons.power) {
            struct timeval now;
            gettimeofday(&now, NULL);
            if (time_diff_ms(&buttons.power_press_time, &now) > 2000) {
                log_event("Power button long press detected");
                handle_power_button(0); /* Simulate release */
            }
        }
    }
    
    close(fd);
}

/* Main daemon function */
int main(int argc, char *argv[]) {
    pid_t pid, sid;
    
    /* Fork to background */
    if (argc < 2 || strcmp(argv[1], "-f") != 0) {
        pid = fork();
        if (pid < 0) {
            exit(EXIT_FAILURE);
        }
        if (pid > 0) {
            printf("Button daemon started with PID %d\n", pid);
            exit(EXIT_SUCCESS);
        }
        
        /* Create new session */
        sid = setsid();
        if (sid < 0) {
            exit(EXIT_FAILURE);
        }
        
        /* Change to root directory */
        chdir("/");
        
        /* Close standard file descriptors */
        close(STDIN_FILENO);
        close(STDOUT_FILENO);
        close(STDERR_FILENO);
    }
    
    /* Initialize */
    init_status_dir();
    
    /* Open log file */
    logfile = fopen(LOG_FILE, "a");
    if (logfile) {
        log_event("Button daemon started");
    }
    
    /* Set up signal handlers */
    signal(SIGTERM, signal_handler);
    signal(SIGINT, signal_handler);
    
    /* Fork to monitor both devices */
    pid = fork();
    if (pid == 0) {
        /* Child process - monitor TWL4030 buttons */
        monitor_device(INPUT_TWL);
    } else {
        /* Parent process - monitor GPIO buttons */
        monitor_device(INPUT_GPIO);
        
        /* Wait for child */
        wait(NULL);
    }
    
    /* Cleanup */
    if (logfile) {
        log_event("Button daemon stopped");
        fclose(logfile);
    }
    
    return 0;
}