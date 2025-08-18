# 🔧 JesterOS Deep API Reference

*Version 1.0.0 | Updated: December 2024*

Complete API documentation for all JesterOS functions and utilities.

---

## 📋 API Categories

### 🎭 JesterOS Core Services

#### Service Management APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `jesteros_start_service()` | Start JesterOS service | `runtime/2-application/jesteros/manager.sh` | `service_name` |
| `jesteros_stop_service()` | Stop JesterOS service | `runtime/2-application/jesteros/manager.sh` | `service_name` |
| `jesteros_restart_service()` | Restart JesterOS service | `runtime/2-application/jesteros/manager.sh` | `service_name` |
| `jesteros_status()` | Get all services status | `runtime/2-application/jesteros/manager.sh` | None |
| `jesteros_health_check()` | System health validation | `runtime/2-application/jesteros/health-check.sh` | None |

#### Mood & Display APIs  
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `jester_mood_update()` | Update jester mood | `runtime/2-application/jesteros/mood.sh` | `mood_type` |
| `jester_display_art()` | Show ASCII art | `runtime/1-ui/themes/jester/mood-selector.sh` | `art_name` |
| `jester_random_quote()` | Get wisdom quote | `runtime/2-application/jesteros/wisdom.sh` | None |
| `jester_celebration()` | Celebration animation | `runtime/1-ui/display/jester-dance.sh` | `achievement` |

#### Writing Statistics APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `tracker_word_count()` | Count words written | `runtime/2-application/jesteros/tracker.sh` | `file_path` |
| `tracker_update_stats()` | Update writing stats | `runtime/2-application/jesteros/tracker.sh` | `words, time` |
| `tracker_daily_goal()` | Set daily writing goal | `runtime/2-application/jesteros/tracker.sh` | `word_count` |
| `tracker_achievements()` | Get achievements | `runtime/2-application/jesteros/tracker.sh` | None |

### 🖥️ Display & E-Ink Management

#### E-Ink Control APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `eink_refresh()` | Force full E-Ink refresh | `runtime/4-hardware/eink/display-control.sh` | None |
| `eink_partial_refresh()` | Partial display update | `runtime/4-hardware/eink/display-control.sh` | `x, y, w, h` |
| `eink_clear()` | Clear entire display | `runtime/4-hardware/eink/display-control.sh` | None |
| `eink_set_mode()` | Set refresh mode | `runtime/4-hardware/eink/display-control.sh` | `mode` |
| `display_message()` | Show themed message | `runtime/1-ui/display/message-display.sh` | `message, theme` |

#### Theme & UI APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `theme_load()` | Load UI theme | `runtime/1-ui/themes/theme-manager.sh` | `theme_name` |
| `theme_ascii_art()` | Load ASCII art | `runtime/1-ui/themes/ascii-loader.sh` | `art_category` |
| `menu_show()` | Display menu | `runtime/1-ui/menu/menu.sh` | `menu_type` |
| `menu_selection()` | Handle menu input | `runtime/1-ui/menu/menu.sh` | `choice` |

### 💾 Memory Management

#### Memory Control APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `memory_check()` | Check available memory | `runtime/3-system/memory/memory-guardian.sh` | None |
| `memory_guard()` | Enforce memory limits | `runtime/3-system/memory/memory-guardian.sh` | `process_name` |
| `memory_optimize()` | Optimize memory usage | `runtime/3-system/memory/memory-guardian.sh` | None |
| `memory_sacred_check()` | Protect writing space | `runtime/3-system/memory/memory-guardian.sh` | None |
| `memory_alert()` | Memory warning system | `runtime/3-system/memory/memory-guardian.sh` | `threshold` |

#### Resource Management APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `resource_monitor()` | Monitor system resources | `runtime/3-system/services/unified-monitor.sh` | None |
| `resource_cleanup()` | Clean temporary files | `runtime/3-system/common/cleanup-functions.sh` | None |
| `resource_limit()` | Set resource limits | `runtime/3-system/common/resource-limits.sh` | `type, limit` |

### 🔌 Hardware Abstraction

#### Power Management APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `power_sleep()` | Enter power saving mode | `runtime/4-hardware/power/power-manager.sh` | `duration` |
| `power_status()` | Get battery status | `runtime/4-hardware/power/power-manager.sh` | None |
| `power_low_battery()` | Handle low battery | `runtime/4-hardware/power/power-manager.sh` | None |
| `power_optimize()` | Optimize power usage | `runtime/4-hardware/power/power-manager.sh` | None |

#### Sensor APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `temperature_monitor()` | Monitor system temp | `runtime/4-hardware/sensors/temperature-monitor.sh` | None |
| `temperature_alert()` | Temperature warning | `runtime/4-hardware/sensors/temperature-monitor.sh` | `threshold` |
| `button_handler()` | Handle button input | `runtime/4-hardware/input/button-handler.sh` | `button_id` |
| `usb_detect()` | Detect USB connection | `runtime/4-hardware/input/usb-handler.sh` | None |

### 🛠️ System Utilities

#### Boot & Initialization APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `boot_jesteros()` | Initialize JesterOS | `runtime/3-system/boot/boot-jester.sh` | None |
| `boot_check_deps()` | Validate dependencies | `runtime/3-system/boot/boot-validator.sh` | None |
| `boot_mount_services()` | Mount service interfaces | `runtime/3-system/boot/service-mounter.sh` | None |
| `boot_splash()` | Show boot animation | `runtime/1-ui/display/boot-splash.sh` | None |

#### File Management APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `secure_file_ops()` | Safe file operations | `runtime/3-system/common/file-operations.sh` | `operation, path` |
| `validate_path()` | Path traversal protection | `runtime/3-system/common/security-functions.sh` | `path` |
| `backup_manuscripts()` | Backup writing files | `runtime/2-application/writing/backup-manager.sh` | `source_dir` |
| `file_permissions()` | Set secure permissions | `runtime/3-system/common/security-functions.sh` | `file, perms` |

#### Logging & Debugging APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `log_message()` | Write to system log | `runtime/3-system/common/logging.sh` | `level, message` |
| `debug_info()` | Collect debug info | `runtime/3-system/common/debug-functions.sh` | `component` |
| `error_handler()` | Handle system errors | `runtime/3-system/common/error-handling.sh` | `error_code` |
| `trace_execution()` | Trace script execution | `runtime/3-system/common/debug-functions.sh` | `script_name` |

### ✍️ Writing Tools Integration

#### Vim Integration APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `vim_writer_mode()` | Configure Vim for writing | `runtime/2-application/writing/vim-config.sh` | None |
| `vim_spell_check()` | Enable spell checking | `runtime/2-application/writing/vim-config.sh` | `language` |
| `vim_distraction_free()` | Minimal Vim setup | `runtime/2-application/writing/vim-config.sh` | None |
| `vim_save_session()` | Save writing session | `runtime/2-application/writing/session-manager.sh` | `session_name` |

#### Document Management APIs
| Function | Purpose | Location | Parameters |
|----------|---------|----------|------------|
| `document_new()` | Create new document | `runtime/2-application/writing/document-manager.sh` | `title, type` |
| `document_autosave()` | Auto-save documents | `runtime/2-application/writing/autosave.sh` | `interval` |
| `document_export()` | Export documents | `runtime/2-application/writing/export-manager.sh` | `format` |
| `document_sync()` | Sync to external storage | `runtime/2-application/writing/sync-manager.sh` | `destination` |

---

## 📚 API Usage Examples

### Starting JesterOS Services
```bash
#!/bin/bash
source "$(dirname "$0")/../../3-system/common/common.sh"

# Start all JesterOS services
jesteros_start_service "daemon"
jesteros_start_service "mood"
jesteros_start_service "tracker"

# Check status
if jesteros_health_check; then
    log_message "INFO" "JesterOS started successfully"
else
    log_message "ERROR" "JesterOS startup failed"
fi
```

### Memory-Aware Operations
```bash
#!/bin/bash
source "$(dirname "$0")/../../3-system/common/common.sh"

# Check memory before operation
if memory_check; then
    # Safe to proceed
    memory_guard "vim"
    vim_writer_mode
    memory_sacred_check  # Protect writing space
else
    memory_alert "critical"
    power_optimize
fi
```

### E-Ink Display Control
```bash
#!/bin/bash
source "$(dirname "$0")/../../4-hardware/eink/display-functions.sh"

# Show message with full refresh
eink_clear
display_message "Welcome to JesterOS" "medieval"
eink_refresh

# Partial update for status
eink_partial_refresh 0 0 400 50
```

### Error Handling Pattern
```bash
#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

function main() {
    trap 'error_handler $LINENO' ERR
    
    validate_path "$1" || {
        log_message "ERROR" "Invalid path: $1"
        return 1
    }
    
    # Safe operation
    secure_file_ops "read" "$1"
}

main "$@"
```

---

## 🔍 API Reference Quick Search

### By Category
- **[JesterOS Services](#-jesteros-core-services)**: Core system services
- **[Display Control](#-display--e-ink-management)**: E-Ink and UI management  
- **[Memory Management](#-memory-management)**: Resource control
- **[Hardware](#-hardware-abstraction)**: Power, sensors, input
- **[System Utils](#-system-utilities)**: Boot, file ops, logging
- **[Writing Tools](#-writing-tools-integration)**: Vim, documents

### By Function Prefix
- **`jesteros_*`**: Core service functions
- **`eink_*`**: E-Ink display functions
- **`memory_*`**: Memory management functions
- **`power_*`**: Power management functions  
- **`boot_*`**: Boot and initialization functions
- **`vim_*`**: Vim integration functions

### Common Patterns
- **Error Handling**: All functions return status codes
- **Logging**: Use `log_message()` for consistent logging
- **Validation**: Use `validate_*()` functions for input safety
- **Memory Awareness**: Check memory before heavy operations

---

*"Every function documented, every API explained - for the writers who depend on them"* 🕯️📜

*API Reference v1.0.0 - Complete coverage of 60+ JesterOS functions*