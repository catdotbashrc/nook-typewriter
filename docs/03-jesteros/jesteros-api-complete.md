# 🎭 JesterOS Complete API Documentation

*Generated: August 15, 2025*

## Overview

This document provides comprehensive API documentation for the JesterOS userspace services system. JesterOS has migrated from kernel modules to userspace services for better stability, development velocity, and resource management.

---

## 🏗️ Architecture Overview

### System Design

```
┌─────────────────────────────────────────────────────────┐
│                   User Interface                        │
│  ┌─────────────────┐  ┌─────────────────────────────────┐ │
│  │  nook-menu.sh   │  │     squire-menu.sh             │ │
│  └─────────────────┘  └─────────────────────────────────┘ │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────┴───────────────────────────────────────┐
│                JesterOS Services                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐ │
│  │   Jester    │ │   Tracker   │ │      Health         │ │
│  │  (ASCII)    │ │  (Writing)  │ │    (Monitor)        │ │
│  └─────────────┘ └─────────────┘ └─────────────────────┘ │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────┴───────────────────────────────────────┐
│            Service Management Layer                     │
│  ┌─────────────────────────────────────────────────────┐ │
│  │       jesteros-service-manager.sh                   │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────┬───────────────────────────────────────┘
                  │
┌─────────────────┴───────────────────────────────────────┐
│              System Interface                           │
│  /var/jesteros/ - Service interface files               │
│  /etc/jesteros/services/ - Configuration files          │
│  /var/run/jesteros/ - Runtime PID files                │
└─────────────────────────────────────────────────────────┘
```

### Core Components

1. **Service Manager**: Central orchestration of all JesterOS services
2. **Jester Service**: ASCII art companion with mood system
3. **Tracker Service**: Writing statistics and achievement tracking  
4. **Health Service**: System monitoring and resource management
5. **Interface Layer**: `/var/jesteros/` filesystem interface

---

## 🎪 Service Management API

### jesteros-service-manager.sh

**Purpose**: Central service management for all JesterOS components

#### Command Line Interface

```bash
jesteros-service-manager.sh {command} [target]

Commands:
  start     - Awaken service(s)
  stop      - Send service(s) to rest
  restart   - Refresh service vigor
  status    - Check service well-being
  health    - Perform health examination
  monitor   - Continuous monitoring daemon
  init      - Initialize service system

Targets:
  jester    - The Court Jester (ASCII art)
  tracker   - The Royal Scribe (writing stats)
  health    - The Court Physician (monitoring)
  all       - All services of the realm
```

#### Core Functions

##### start_service()
```bash
start_service(service_name)
```
**Purpose**: Start a JesterOS service with dependency resolution
- **Parameters**: `$1` - Service name (jester|tracker|health)
- **Returns**: 0 on success, 1 on failure
- **Features**: 
  - Automatic dependency resolution
  - PID file management
  - Service health verification
  - Resource limit enforcement

**Example**:
```bash
start_service "jester"
# Output: 🎭 The Jester awakens with bells jingling!
```

##### stop_service()
```bash
stop_service(service_name)
```
**Purpose**: Gracefully stop a JesterOS service
- **Parameters**: `$1` - Service name
- **Returns**: 0 on success, 1 on failure
- **Features**:
  - Graceful shutdown (SIGTERM first)
  - Force kill after timeout (SIGKILL)
  - PID file cleanup
  - Dependency awareness

##### service_status()
```bash
service_status(service_name)
```
**Purpose**: Check service operational status
- **Parameters**: `$1` - Service name
- **Returns**: 0 if running, 1 if stopped
- **Output**: Service name, PID, memory usage
- **Format**: "⚔️ [Service Name] is valiantly serving (PID: [pid])"

##### health_check_all()
```bash
health_check_all()
```
**Purpose**: Comprehensive health assessment of all services
- **Parameters**: None
- **Returns**: 0 if all healthy, 1 if issues found
- **Features**:
  - Individual service health checks
  - Memory usage validation (< 1MB total)
  - Auto-restart of failed services
  - Health report generation

##### monitor_services()
```bash
monitor_services()
```
**Purpose**: Continuous monitoring daemon with auto-restart
- **Parameters**: None
- **Returns**: Runs until interrupted (Ctrl+C)
- **Features**:
  - 30-second health check intervals
  - Automatic service recovery
  - Health event logging
  - Memory threshold monitoring

#### Service Configuration

Services are configured via files in `/etc/jesteros/services/`:

**Configuration Format**:
```ini
SERVICE_NAME="Human-readable service name"
SERVICE_DESC="Service description"
SERVICE_EXEC="/path/to/service/executable"
SERVICE_PIDFILE="/var/run/jesteros/service.pid"
SERVICE_ARGS="--daemon --config /etc/service.conf"
SERVICE_DEPS="space separated dependency list"
SERVICE_START_MSG="🎭 Service startup message"
SERVICE_STOP_MSG="🎭 Service shutdown message"  
SERVICE_HEALTH_CHECK="command to verify service health"
```

**Example - jester.conf**:
```ini
SERVICE_NAME="Court Jester"
SERVICE_DESC="ASCII art and mood daemon"
SERVICE_EXEC="/usr/local/bin/jester-daemon.sh"
SERVICE_PIDFILE="/var/run/jesteros/jester.pid"
SERVICE_ARGS=""
SERVICE_DEPS=""
SERVICE_START_MSG="🎭 The Jester awakens with bells jingling!"
SERVICE_STOP_MSG="🎭 The Jester retires to chambers..."
SERVICE_HEALTH_CHECK="test -f /var/jesteros/jester"
```

---

## 🎭 Jester Service API

### jester-daemon.sh

**Purpose**: ASCII art companion with dynamic moods and system awareness

#### Jester Mood System

##### Mood States
```bash
MOOD_HAPPY="happy"         # Default state, system healthy
MOOD_WRITING="writing"     # Active vim/writing session
MOOD_THINKING="thinking"   # System processing/loading
MOOD_SLEEPING="sleeping"   # Idle/power saving mode
MOOD_ERROR="error"         # System error state
MOOD_CELEBRATING="celebrating"  # Achievement unlocked
```

##### set_jester_mood()
```bash
set_jester_mood(mood)
```
**Purpose**: Change jester's current mood and ASCII art
- **Parameters**: `$1` - Mood string (happy|writing|thinking|sleeping|error|celebrating)
- **Returns**: 0 on success, 1 on invalid mood
- **Side Effects**: Updates `/var/jesteros/jester` with new ASCII art
- **Validation**: Ensures mood is valid before applying

**Example**:
```bash
set_jester_mood "writing"
# Updates /var/jesteros/jester with writing-themed ASCII art
```

##### get_system_mood()
```bash
get_system_mood()
```
**Purpose**: Automatically determine appropriate mood based on system state
- **Parameters**: None
- **Returns**: String with recommended mood
- **Analysis Factors**:
  - CPU usage (high = thinking)
  - Active vim processes (writing)
  - System errors in logs (error)
  - Idle time > 5 minutes (sleeping)
  - Recent achievements (celebrating)

##### update_jester_display()
```bash
update_jester_display()
```
**Purpose**: Refresh jester ASCII art based on current conditions
- **Parameters**: None
- **Returns**: 0 on success
- **Frequency**: Called every 30 seconds by daemon
- **Features**:
  - Automatic mood detection
  - ASCII art generation
  - File system interface updates

#### ASCII Art Collection

The jester maintains a collection of ASCII art for different moods:

**Happy Mood**:
```
      .-""""""-.
     /          \
    |   ^    ^   |
    |     <>     |
     \    ___   /
      '-.____.-'
   Greetings, noble scribe!
```

**Writing Mood**:
```
      .-""""""-.
     /          \
    |   *    *   |
    |     <>     |
     \    ___   /
      '-.____.-'
   The quill flows with wisdom!
```

#### Interface Files

##### `/var/jesteros/jester`
**Content**: Current jester ASCII art with mood message
**Format**: Multi-line ASCII art followed by mood-appropriate message
**Update Frequency**: Every 30 seconds or on mood change

##### `/var/jesteros/jester/mood`
**Content**: Current mood state (string)
**Format**: Single line with mood name
**Access**: Read-only (updated by service)

##### `/var/jesteros/jester/stats`
**Content**: Jester activity statistics
**Format**: Key-value pairs
```
Mood Changes: 247
Uptime: 2d 14h 32m
Last Mood Change: 2025-08-15 14:30:15
Total Greetings: 1,429
```

---

## 📜 Tracker Service API

### jesteros-tracker.sh

**Purpose**: Writing activity monitoring, statistics tracking, and achievement system

#### Writing Statistics Tracking

##### update_writing_stats()
```bash
update_writing_stats()
```
**Purpose**: Monitor and update comprehensive writing statistics
- **Parameters**: None
- **Returns**: 0 on success
- **Monitoring**:
  - Total words written
  - Keystroke count estimation
  - Session duration tracking
  - Daily writing goals progress
  - Writing streak calculation

##### monitor_vim_activity()
```bash
monitor_vim_activity()
```
**Purpose**: Detect and respond to vim/writing activity
- **Parameters**: None
- **Returns**: 0 when active, 1 when idle
- **Detection Methods**:
  - Process monitoring (`ps aux | grep vim`)
  - File modification time tracking
  - Word count delta analysis
- **Triggers**:
  - Jester mood updates (writing mode)
  - Achievement checks
  - Statistics updates

##### count_words_in_file()
```bash
count_words_in_file(filepath)
```
**Purpose**: Accurate word counting for text files
- **Parameters**: `$1` - Path to file for analysis
- **Returns**: Word count (integer) via stdout
- **Method**: Uses `wc -w` with whitespace normalization
- **File Types**: .md, .txt, .tex (auto-detection)

**Example**:
```bash
word_count=$(count_words_in_file "/root/notes/manuscript.md")
echo "Document contains $word_count words"
```

##### count_characters_in_file()
```bash
count_characters_in_file(filepath)
```
**Purpose**: Character count including spaces
- **Parameters**: `$1` - File path
- **Returns**: Character count (integer)
- **Excludes**: Line breaks (counts content characters only)

#### Achievement System

##### update_achievements()
```bash
update_achievements()
```
**Purpose**: Check and unlock writing achievements
- **Parameters**: None
- **Returns**: 0 if no new achievements, 1 if achievements unlocked
- **Side Effects**: Updates achievement files, triggers jester celebration

**Achievement Levels**:
```bash
APPRENTICE_SCRIBE=100      # 100 words total
JOURNEYMAN_WRITER=1000     # 1,000 words total
MASTER_WORDSMITH=10000     # 10,000 words total
GRAND_CHRONICLER=100000    # 100,000 words total
DAILY_DEDICATION=500       # 500 words in one day
STREAK_KEEPER=7           # 7 consecutive writing days
MARATHON_WRITER=2000      # 2,000 words in one session
```

##### check_daily_goals()
```bash
check_daily_goals()
```
**Purpose**: Monitor daily writing goal progress
- **Parameters**: None
- **Returns**: 0 if goal met, 1 if not yet achieved
- **Default Goal**: 500 words per day (configurable)
- **Features**:
  - Progress tracking
  - Streak calculation
  - Motivational messages

#### Statistics Data Structure

##### Main Statistics File: `/var/jesteros/typewriter/stats`
```
Words: 12,847
Characters: 67,234
Keystrokes: 89,156
Sessions: 47
Total Time: 23h 18m
Streak: 12 days
Last Write: 2025-08-15 14:30:22
Today: 347 words
Goal Progress: 69% (347/500)
Achievement: Master Wordsmith
```

##### Daily Progress: `/var/jesteros/typewriter/daily`
```
Date: 2025-08-15
Words Today: 347
Goal: 500
Progress: 69%
Session Count: 3
First Write: 09:15:30
Last Write: 14:30:22
Session Length: 1h 23m
```

##### Achievements: `/var/jesteros/typewriter/achievements`
```
UNLOCKED ACHIEVEMENTS:
- Apprentice Scribe (100 words) ✓ 2025-08-01
- Journeyman Writer (1,000 words) ✓ 2025-08-05
- Master Wordsmith (10,000 words) ✓ 2025-08-12
- Daily Dedication (500 words/day) ✓ 2025-08-10
- Streak Keeper (7 days) ✓ 2025-08-14

PROGRESS TOWARDS:
- Grand Chronicler: 12,847/100,000 words (12%)
- Marathon Writer: Best session: 1,247 words (62%)
```

#### Monitoring Configuration

**Update Intervals**:
- Statistics update: Every 60 seconds
- File monitoring: Every 30 seconds  
- Achievement check: After each writing session
- Daily reset: At midnight (00:00)

**File Monitoring Paths**:
- `/root/notes/` - Zettelkasten notes
- `/root/drafts/` - Work in progress
- `/root/scrolls/` - Finished works

---

## 🏥 Health Service API

### health-check.sh

**Purpose**: Comprehensive system monitoring and resource management

#### System Health Monitoring

##### perform_health_check()
```bash
perform_health_check()
```
**Purpose**: Complete system health assessment
- **Parameters**: None
- **Returns**: 0 if healthy, 1 if issues detected
- **Checks**:
  - Memory usage (< 96MB OS limit)
  - Disk space availability
  - CPU load average
  - Service status verification
  - File system integrity

##### check_memory_usage()
```bash
check_memory_usage()
```
**Purpose**: Monitor memory consumption against sacred limits
- **Parameters**: None
- **Returns**: 0 if within limits, 1 if exceeded
- **Thresholds**:
  - Warning: >80% of 96MB (76.8MB)
  - Critical: >90% of 96MB (86.4MB)
  - Emergency: >95% of 96MB (91.2MB)
- **Sacred Rule**: NEVER exceed 96MB total OS memory

**Example Output**:
```
Memory Status: OK
Total OS Usage: 67.2MB / 96MB (70%)
Available for Writing: 188.8MB
Status: ✓ Within sacred limits
```

##### check_disk_space()
```bash
check_disk_space()
```
**Purpose**: Monitor disk space for writing directories
- **Parameters**: None  
- **Returns**: 0 if adequate, 1 if low space
- **Monitored Paths**:
  - `/` (root partition)
  - `/root/notes/` (notes storage)
  - `/root/drafts/` (drafts storage)
  - `/root/scrolls/` (completed works)
- **Thresholds**:
  - Warning: <500MB free
  - Critical: <100MB free

##### monitor_services_health()
```bash
monitor_services_health()
```
**Purpose**: Verify health of all JesterOS services
- **Parameters**: None
- **Returns**: 0 if all healthy, 1 if issues found
- **Validation**:
  - PID file existence and validity
  - Process responsiveness
  - Resource consumption
  - Service-specific health checks
- **Auto-Recovery**: Restart failed services

#### Resource Management

##### get_memory_stats()
```bash
get_memory_stats()
```
**Purpose**: Detailed memory usage breakdown
- **Parameters**: None
- **Output**: Formatted memory statistics
- **Breakdown**:
  - OS base memory usage
  - Service memory consumption
  - Available memory for writing
  - Memory efficiency metrics

**Example Output**:
```
MEMORY USAGE BREAKDOWN:
OS Base: 52.1MB
Services: 15.1MB (Jester: 2.3MB, Tracker: 4.2MB, Health: 8.6MB)
Total Used: 67.2MB / 96MB (70%)
Available: 28.8MB
Writing Space: 188.8MB (SACRED - untouchable)
Efficiency: Good (within limits)
```

##### format_bytes()
```bash
format_bytes(bytes)
```
**Purpose**: Convert bytes to human-readable format
- **Parameters**: `$1` - Bytes (integer)
- **Returns**: Formatted string (KB/MB/GB)
- **Format**: Automatically selects appropriate unit

#### Health Reporting

##### Health Status File: `/var/jesteros/health/status`
```
=== COURT PHYSICIAN'S REPORT ===
Date: 2025-08-15 14:30:22
Overall Health: EXCELLENT

VITAL SIGNS:
Memory: 67.2MB/96MB (70%) - GOOD
Disk Space: 2.3GB free - EXCELLENT  
CPU Load: 0.23 (5min avg) - EXCELLENT
Services: 3/3 running - EXCELLENT

SERVICES STATUS:
✓ Court Jester: Healthy (PID 1247, 2.3MB)
✓ Royal Scribe: Healthy (PID 1251, 4.2MB)  
✓ Court Physician: Healthy (PID 1255, 8.6MB)

RECOMMENDATIONS:
- All systems operating within optimal parameters
- Memory budget maintained (30MB under limit)
- Continue current writing regimen

PROGNOSIS: Excellent health for continued writing
```

##### Memory Details: `/var/jesteros/health/memory`
```
MEMORY ANALYSIS:
Total System: 256MB
OS Reserved: 96MB (limit)
Currently Used: 67.2MB
Efficiency: 70% of budget

BREAKDOWN:
- Kernel: 31.4MB
- System Services: 20.7MB  
- JesterOS Services: 15.1MB
- Buffers/Cache: 12.3MB

WRITING SPACE (SACRED):
Reserved: 160MB
Status: PROTECTED
Usage: Available for vim and documents

RECOMMENDATION: Memory usage optimal
```

#### Health Daemon Mode

When run with `--daemon`, the health service:
- Monitors continuously every 60 seconds
- Logs health events to `/var/log/jesteros/health.log`
- Auto-adjusts service priorities based on resource usage
- Sends alerts for critical conditions
- Maintains rolling health history

---

## 🔧 Shared Library API

### common.sh

**Purpose**: Shared utilities with enhanced security and JesterOS integration

#### Input Validation & Security

##### validate_menu_choice()
```bash
validate_menu_choice(choice, max)
```
**Purpose**: Secure menu input validation with range checking
- **Parameters**: 
  - `$1` - User input string
  - `$2` - Maximum valid choice number
- **Returns**: 0 if valid (1-max), 1 if invalid
- **Security Features**:
  - Injection attack prevention
  - Numeric validation (regex: `^[0-9]+$`)
  - Range enforcement
  - Input sanitization

**Example**:
```bash
if validate_menu_choice "$user_input" 9; then
    echo "Valid choice: $user_input"
else
    echo "Invalid choice. Please enter 1-9."
fi
```

##### validate_path()
```bash
validate_path(path)
```
**Purpose**: Path traversal attack prevention and directory restriction
- **Parameters**: `$1` - File path to validate
- **Returns**: 0 if safe, 1 if unsafe
- **Security Features**:
  - Path traversal prevention (`../` detection)
  - Directory whitelist enforcement
  - Canonicalization checking
- **Allowed Directories**:
  - `/root/notes/` - Zettelkasten notes
  - `/root/drafts/` - Work in progress
  - `/root/scrolls/` - Completed works

**Example**:
```bash
if validate_path "$user_file_path"; then
    vim "$user_file_path"
else
    echo "Access denied: Invalid file path"
fi
```

##### sanitize_input()
```bash
sanitize_input(input)
```
**Purpose**: Input sanitization for security and safety
- **Parameters**: `$1` - Raw user input string
- **Returns**: Cleaned input string via stdout
- **Sanitization**:
  - Control character removal (`tr -cd '[:print:]'`)
  - Length limitation (100 characters max)
  - Special character handling

**Example**:
```bash
clean_input=$(sanitize_input "$raw_user_input")
echo "Sanitized: $clean_input"
```

#### Display Abstraction Layer

##### display_text()
```bash
display_text(text, refresh)
```
**Purpose**: Universal display method with E-Ink optimization
- **Parameters**:
  - `$1` - Text to display
  - `$2` - Force refresh flag (0=no refresh, 1=refresh)
- **Auto-Detection**: FBInk for E-Ink displays, terminal fallback
- **E-Ink Optimization**: Reduces unnecessary screen updates

**Example**:
```bash
display_text "Welcome to JesterOS!" 1  # With refresh
display_text "Menu option selected" 0  # No refresh
```

##### clear_display()
```bash
clear_display()
```
**Purpose**: Clear display with proper E-Ink handling
- **Parameters**: None
- **E-Ink**: Uses `fbink -c` for proper clearing
- **Terminal**: Uses `clear` command
- **Error Handling**: Graceful fallback on failure

##### display_banner()
```bash
display_banner(title)
```
**Purpose**: Formatted banner display with consistent styling
- **Parameters**: `$1` - Banner title text
- **Format**: Bordered banner with fixed width (40 characters)
- **Style**: Medieval theme with equal signs border

**Example Output**:
```
========================================
  JesterOS Writing Environment
========================================
```

##### has_eink()
```bash
has_eink()
```
**Purpose**: E-Ink display capability detection
- **Parameters**: None
- **Returns**: 0 if FBInk available, 1 if terminal only
- **Detection**: Checks for `fbink` command availability

#### Error Handling System

##### error_handler()
```bash
error_handler(line_no, exit_code)
```
**Purpose**: Unified error handling with context preservation
- **Parameters**:
  - `$1` - Line number where error occurred
  - `$2` - Exit code from failed command
- **Features**:
  - Writer-friendly error messages
  - System logging integration
  - Context preservation for debugging
  - Medieval-themed error presentation

**Example Output**:
```
Alas! The digital parchment has encountered an error!
Script: nook-menu.sh
Line: 127
Exit code: 1
```

##### log_message()
```bash
log_message(level, message)
```
**Purpose**: Structured logging with timestamps
- **Parameters**:
  - `$1` - Log level (INFO|WARNING|ERROR|DEBUG)
  - `$2` - Log message text
- **Output**: `/var/log/squireos.log` with ISO timestamps
- **Format**: `[YYYY-MM-DD HH:MM:SS] [LEVEL] message`

##### debug_log()
```bash
debug_log(message)
```
**Purpose**: Conditional debug logging
- **Parameters**: `$1` - Debug message
- **Condition**: Only logs when `DEBUG=1` environment variable set
- **Usage**: Development and troubleshooting

#### JesterOS Integration Constants

```bash
# JesterOS Directories
JESTER_DIR="/var/lib/jester"           # Jester data storage
NOTES_DIR="/root/notes"                 # Zettelkasten notes
DRAFTS_DIR="/root/drafts"               # Work in progress
SCROLLS_DIR="/root/scrolls"             # Finished works
SQUIREOS_PROC="/proc/squireos"          # Legacy kernel interface

# Timing Constants (E-Ink Optimized)
BOOT_DELAY=2                           # Boot sequence delay
MENU_TIMEOUT=3                         # Menu input timeout  
JESTER_UPDATE_INTERVAL=30              # Jester mood update frequency
QUICK_DELAY=0.3                        # Fast operations
MEDIUM_DELAY=0.8                       # Medium operations
LONG_DELAY=2                           # Slow operations

# System Information
SQUIREOS_VERSION="1.0.0"               # Version identifier
SQUIREOS_COMMON_LOADED=1               # Library load indicator
```

---

## 🔗 Integration & Interface Specifications

### JesterOS Filesystem Interface

#### Directory Structure
```
/var/jesteros/                         # Root interface directory
├── jester                            # Current jester ASCII art
├── jester/
│   ├── mood                          # Current mood state
│   ├── stats                         # Activity statistics
│   └── history                       # Mood change history
├── typewriter/
│   ├── stats                         # Writing statistics
│   ├── achievements                  # Unlocked achievements  
│   ├── daily                         # Daily progress
│   └── goals                         # Writing goals config
├── health/
│   ├── status                        # Overall health status
│   ├── memory                        # Memory usage details
│   ├── disk                          # Disk space information
│   ├── services                      # Service health status
│   └── alerts                        # Active alerts/warnings
├── wisdom                            # Current wisdom quote
└── services/
    ├── status                        # Global service status
    ├── jester.status                 # Individual service status
    ├── tracker.status                # files for each service
    └── health.status
```

#### File Formats

**Text Files**: Human-readable, one value per line
**Status Files**: Key-value pairs, colon-separated
**Statistics Files**: Formatted for direct display
**Configuration Files**: Shell variable format

#### Access Patterns

**Read Access**: All interface files are world-readable
**Write Access**: Only services can write to their interface files
**Atomicity**: Updates use temporary files with atomic moves
**Consistency**: Interface files always contain valid data

### Service Communication

#### Inter-Service Communication
Services communicate through:
1. **Interface Files**: Reading each other's `/var/jesteros/` entries
2. **Signal Handling**: SIGUSR1 for coordination signals
3. **Service Manager**: Centralized coordination through manager
4. **Shared State**: Common status files in `/var/jesteros/services/`

#### Event System
```bash
# Trigger jester mood update from tracker
echo "writing_started" > /var/jesteros/events/tracker

# Health service broadcasts alerts
echo "memory_warning" > /var/jesteros/events/health

# Services monitor events directory
inotifywait -m /var/jesteros/events/
```

### Integration with System Components

#### Boot Integration
1. **init-jesteros.sh** runs during system startup
2. Creates all necessary directories and interface files
3. Starts service manager in daemon mode
4. Initializes default states for all services
5. Launches interactive menu if running on TTY

#### Menu System Integration
```bash
# Menu reads current jester
jester_display=$(cat /var/jesteros/jester 2>/dev/null || echo "Jester unavailable")

# Menu displays writing stats
stats_line=$(grep "Words:" /var/jesteros/typewriter/stats 2>/dev/null)

# Menu shows system health
health_status=$(head -n1 /var/jesteros/health/status 2>/dev/null)
```

#### Editor Integration
- **File Monitoring**: Tracker monitors vim processes and file changes
- **Statistics Updates**: Word counts updated on file save
- **Mood Updates**: Jester switches to "writing" mode during editing
- **Achievement Checks**: Triggered after significant writing sessions

---

## 🚨 Error Handling & Recovery

### Error Classification

#### Service Errors
- **Start Failure**: Service fails to start (exit code 1)
- **Runtime Failure**: Service crashes during operation
- **Health Check Failure**: Service becomes unresponsive
- **Resource Exhaustion**: Service exceeds memory/CPU limits

#### System Errors
- **Memory Limit**: Approaching 96MB OS memory limit
- **Disk Full**: Insufficient disk space for operations
- **Interface Corruption**: JesterOS interface files corrupted
- **Permission Issues**: File access permission problems

### Recovery Strategies

#### Automatic Recovery
1. **Service Restart**: Failed services automatically restarted (3 attempts)
2. **Exponential Backoff**: Increasing delays between restart attempts
3. **Dependency Resolution**: Restart dependent services in correct order
4. **State Recovery**: Restore service state from last known good state

#### Manual Recovery
```bash
# Reset entire JesterOS system
sudo /usr/local/bin/jesteros-service-manager.sh stop all
sudo rm -rf /var/jesteros/* /var/run/jesteros/*
sudo /usr/local/bin/jesteros-service-manager.sh init
sudo /usr/local/bin/jesteros-service-manager.sh start all

# Reset specific service
sudo /usr/local/bin/jesteros-service-manager.sh restart jester

# Emergency memory cleanup
sudo sync && sudo echo 3 > /proc/sys/vm/drop_caches
```

### Monitoring & Alerting

#### Health Monitoring
- Continuous monitoring every 60 seconds
- Memory usage threshold alerts
- Service failure notifications
- Resource exhaustion warnings

#### Log Management
```bash
# Service logs
/var/log/jesteros/
├── service-manager.log    # Central management log
├── jester.log            # Jester service log
├── tracker.log           # Tracker service log
├── health.log            # Health monitoring log
└── system.log            # System-wide events
```

---

## 📊 Performance & Resource Management

### Memory Management

#### Memory Budget Enforcement
```bash
# Memory limits (SACRED - never exceed)
OS_MEMORY_LIMIT=96MB       # Total OS memory budget
WRITING_SPACE=160MB        # Reserved for writing (untouchable)
SERVICE_LIMIT=15MB         # Total for all JesterOS services
INDIVIDUAL_LIMIT=8MB       # Maximum per service
```

#### Memory Monitoring
- **Continuous Tracking**: Memory usage monitored every 60 seconds
- **Threshold Alerts**: Warnings at 80%, 90%, 95% of limits
- **Auto-Optimization**: Services shed cache/buffers when needed
- **Emergency Actions**: Service throttling/shutdown at 95%

### CPU Management

#### Resource Priorities
```bash
# Nice levels for services
JESTER_NICE=10             # Lower priority (cosmetic)
TRACKER_NICE=5             # Medium priority (important)
HEALTH_NICE=0              # High priority (critical)
SERVICE_MANAGER_NICE=-5    # Highest priority (essential)
```

#### Load Management
- **Load Monitoring**: 1, 5, 15 minute load averages
- **Adaptive Behavior**: Reduce update frequencies under high load
- **Background Tasks**: Defer non-critical operations
- **Emergency Throttling**: Suspend services if load > 2.0

### Storage Management

#### Disk Space Monitoring
```bash
# Storage thresholds
CRITICAL_FREE=100MB        # Critical disk space threshold
WARNING_FREE=500MB         # Warning threshold
LOG_ROTATION=50MB          # Maximum log file size
```

#### Log Management
- **Automatic Rotation**: Logs rotated at 10MB per file
- **Compression**: Old logs compressed with gzip
- **Retention**: Keep 7 days of logs maximum
- **Cleanup**: Emergency cleanup at 90% disk usage

---

## 🧪 Testing & Validation

### Service Testing

#### Unit Tests
```bash
# Test service startup
test_service_start() {
    start_service "jester"
    assert_equals $? 0
    assert_file_exists "/var/run/jesteros/jester.pid"
    assert_file_exists "/var/jesteros/jester"
}

# Test health monitoring
test_health_check() {
    perform_health_check
    assert_equals $? 0
    assert_file_contains "/var/jesteros/health/status" "EXCELLENT"
}
```

#### Integration Tests
```bash
# Test full system startup
test_full_initialization() {
    /usr/local/bin/jesteros-service-manager.sh init
    /usr/local/bin/jesteros-service-manager.sh start all
    sleep 5
    
    assert_service_running "jester"
    assert_service_running "tracker" 
    assert_service_running "health"
    assert_interface_complete
}

# Test writing workflow
test_writing_workflow() {
    echo "Test content" > /root/notes/test.md
    sleep 2
    
    word_count=$(grep "Words:" /var/jesteros/typewriter/stats | cut -d: -f2)
    assert_greater_than "$word_count" 0
    assert_jester_mood "writing"
}
```

### Performance Testing

#### Memory Testing
```bash
# Memory leak detection
test_memory_stability() {
    start_all_services
    initial_memory=$(get_total_memory_usage)
    
    # Run for 24 hours
    sleep 86400
    
    final_memory=$(get_total_memory_usage)
    memory_growth=$((final_memory - initial_memory))
    
    assert_less_than "$memory_growth" 5  # Max 5MB growth
}

# Resource limit testing
test_resource_limits() {
    start_all_services
    
    for service in jester tracker health; do
        memory=$(get_service_memory "$service")
        assert_less_than "$memory" 8  # 8MB limit per service
    done
    
    total_memory=$(get_total_memory_usage)
    assert_less_than "$total_memory" 96  # Total OS limit
}
```

### Validation Framework

#### Health Validation
```bash
validate_system_health() {
    local errors=0
    
    # Check all services running
    for service in jester tracker health; do
        if ! is_service_running "/var/run/jesteros/${service}.pid"; then
            echo "ERROR: Service $service not running"
            errors=$((errors + 1))
        fi
    done
    
    # Check interface integrity
    for file in /var/jesteros/{jester,typewriter/stats,health/status}; do
        if [[ ! -f "$file" ]]; then
            echo "ERROR: Interface file missing: $file"
            errors=$((errors + 1))
        fi
    done
    
    # Check memory limits
    if ! check_memory_usage; then
        echo "ERROR: Memory limit exceeded"
        errors=$((errors + 1))
    fi
    
    return $errors
}
```

---

## 🔧 Development Guidelines

### Adding New Services

#### Service Development Checklist
1. **Create Service Script**: Implement in `/source/scripts/services/`
2. **Configuration File**: Define in `/etc/jesteros/services/`
3. **Interface Files**: Create entries in `/var/jesteros/`
4. **Health Checks**: Implement service-specific health validation
5. **Documentation**: Add API documentation
6. **Testing**: Create unit and integration tests
7. **Integration**: Update service manager

#### Service Template
```bash
#!/bin/bash
# New JesterOS Service Template
# "A new performer joins the court!"

set -euo pipefail

# Source common functions
SCRIPT_DIR=$(dirname "$0")
. "$SCRIPT_DIR/../lib/common.sh"

# Service configuration
SERVICE_NAME="New Service"
INTERFACE_DIR="/var/jesteros/newservice"
PID_FILE="/var/run/jesteros/newservice.pid"

# Initialize service
initialize_service() {
    mkdir -p "$INTERFACE_DIR"
    echo "Service initialized" > "$INTERFACE_DIR/status"
}

# Main service loop
run_service() {
    while true; do
        # Service logic here
        update_service_status
        sleep 30
    done
}

# Health check
check_service_health() {
    [[ -f "$INTERFACE_DIR/status" ]] && 
    grep -q "healthy" "$INTERFACE_DIR/status"
}

# Main execution
main() {
    case "${1:-}" in
        --daemon)
            initialize_service
            run_service
            ;;
        --health)
            check_service_health
            ;;
        *)
            echo "Usage: $0 --daemon|--health"
            exit 1
            ;;
    esac
}

main "$@"
```

### Code Quality Standards

#### Shell Scripting Standards
```bash
# Always use strict mode
set -euo pipefail
IFS=$'\n\t'

# Error handling
trap 'error_handler $LINENO $?' ERR

# Input validation
validate_all_inputs() {
    local input="$1"
    [[ -n "$input" ]] || return 1
    sanitize_input "$input" >/dev/null
}

# Quote all variables
echo "$VARIABLE"          # Good
echo $VARIABLE           # Bad

# Use meaningful function names
update_jester_mood()     # Good  
update_mood()           # Bad

# Document all functions
# Purpose: Update jester's current mood
# Parameters: $1 - New mood state
# Returns: 0 on success, 1 on failure
update_jester_mood() {
    local new_mood="$1"
    # Implementation...
}
```

#### Security Requirements
- **Input Validation**: All user input must be validated
- **Path Checking**: All file paths must be validated against allowed directories
- **Injection Prevention**: No direct evaluation of user input
- **Privilege Separation**: Services run with minimal required privileges
- **Resource Limits**: All services must respect memory and CPU limits

### Testing Requirements

#### Mandatory Tests
1. **Service Start/Stop**: All services must start and stop cleanly
2. **Health Checks**: All services must implement health validation
3. **Resource Limits**: Memory and CPU usage must be within limits
4. **Error Handling**: All error conditions must be handled gracefully
5. **Interface Integrity**: All interface files must be valid and accessible

#### Test Coverage
- **Unit Tests**: Individual function testing (>80% coverage)
- **Integration Tests**: Service interaction testing  
- **System Tests**: Full system workflow testing
- **Performance Tests**: Memory and CPU usage validation
- **Stress Tests**: Resource exhaustion and recovery testing

---

## 📚 Reference & Resources

### Quick Reference

#### Essential Commands
```bash
# Service management
sudo jesteros-service-manager.sh start all
sudo jesteros-service-manager.sh status
sudo jesteros-service-manager.sh monitor

# View jester
cat /var/jesteros/jester

# Check writing stats
cat /var/jesteros/typewriter/stats

# System health
cat /var/jesteros/health/status

# Service logs
tail -f /var/log/jesteros/service-manager.log
```

#### Configuration Files
- `/etc/jesteros/services/` - Service configurations
- `/var/jesteros/` - Runtime interface files
- `/var/run/jesteros/` - PID files
- `/var/log/jesteros/` - Service logs

#### Key Directories
- `/usr/local/bin/` - JesterOS executables
- `/source/scripts/services/` - Service source code
- `/source/scripts/lib/` - Shared libraries
- `/source/scripts/boot/` - Boot scripts

### Troubleshooting Guide

#### Common Issues

**Services Won't Start**
```bash
# Check service configuration
cat /etc/jesteros/services/service.conf

# Check permissions
ls -la /usr/local/bin/service-daemon.sh

# Check dependencies
lsof /var/jesteros/

# Manual start for debugging
/usr/local/bin/service-daemon.sh --daemon
```

**Interface Files Missing**
```bash
# Reinitialize interface
sudo rm -rf /var/jesteros/*
sudo /usr/local/bin/jesteros-service-manager.sh init

# Check directory permissions
ls -la /var/jesteros/

# Recreate manually if needed
sudo mkdir -p /var/jesteros/{jester,typewriter,health,services}
```

**Memory Issues**
```bash
# Check current usage
cat /var/jesteros/health/memory

# Emergency cleanup
sudo sync && sudo echo 3 > /proc/sys/vm/drop_caches

# Check for memory leaks
ps aux --sort=-%mem | head -10
```

#### Debug Mode
```bash
# Enable debug logging
export DEBUG=1

# Run service in foreground
/usr/local/bin/jester-daemon.sh --daemon

# Monitor all logs
tail -f /var/log/jesteros/*.log
```

### Version History

**Version 2.0.0 (August 15, 2025)**
- Complete migration to userspace services
- Unified service management system
- Enhanced security and input validation
- Comprehensive health monitoring
- Achievement system implementation

**Version 1.x (Legacy)**
- Kernel module implementation
- Basic proc filesystem interface
- Simple shell script integration

---

## 📄 License & Contributing

**License**: GPL v2  
**Project**: Nook Typewriter JesterOS  
**Repository**: Personal project for e-reader transformation

### Contributing Guidelines

**Welcome Contributions**:
- Memory usage optimizations
- Writing workflow improvements
- Medieval theme enhancements  
- Security improvements
- Performance optimizations
- Additional achievement types
- Enhanced ASCII art collections

**Development Process**:
1. Fork the repository
2. Create feature branch
3. Implement changes with tests
4. Validate memory usage < limits
5. Submit pull request with documentation
6. Code review and testing
7. Integration and deployment

**Code Standards**:
- Follow shell scripting best practices
- Implement comprehensive error handling
- Add security validation for all inputs
- Include unit tests for new functions
- Document all public APIs
- Maintain memory efficiency focus

---

*"By quill and jest, we code for those who write!"* 🎭📜

**Generated**: August 15, 2025  
**API Version**: 2.0.0  
**Documentation Version**: 1.0.0