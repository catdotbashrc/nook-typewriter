# 📜 JesterOS Deep Scripts Catalog

*Version 1.0.0 | Updated: December 2024*

Complete catalog of all shell scripts in the JesterOS project with detailed descriptions and usage.

---

## 📊 Script Statistics

- **Total Scripts**: 82 files
- **Runtime Scripts**: 33 files (4-layer architecture)
- **Source Scripts**: 31 files (legacy/transition)
- **Test Scripts**: 18 files (validation suite)

## 🏗️ Runtime Architecture Scripts (33 files)

### Layer 1: User Interface (`runtime/1-ui/`) - 8 scripts

#### Menu Systems
| Script | Purpose | Key Functions | Memory Usage |
|--------|---------|---------------|--------------|
| `menu/menu.sh` | Main menu system | `show_main_menu()`, `handle_selection()` | < 1MB |
| `menu/jester-menu.sh` | JesterOS-specific menu | `jester_menu()`, `ascii_display()` | < 1MB |
| `menu/power-menu.sh` | Power management menu | `power_menu()`, `sleep_options()` | < 1MB |

#### Display Management
| Script | Purpose | Key Functions | Memory Usage |
|--------|---------|---------------|--------------|
| `display/message-display.sh` | Themed message display | `display_message()`, `eink_output()` | < 1MB |
| `display/boot-splash.sh` | Boot animation display | `show_boot_splash()`, `jester_intro()` | < 2MB |
| `display/status-display.sh` | System status display | `show_status()`, `health_display()` | < 1MB |

#### Theme Management
| Script | Purpose | Key Functions | Memory Usage |
|--------|---------|---------------|--------------|
| `themes/theme-manager.sh` | Theme loading system | `load_theme()`, `set_ascii_art()` | < 1MB |
| `themes/ascii-loader.sh` | ASCII art management | `load_art()`, `mood_selector()` | < 1MB |

### Layer 2: Application Services (`runtime/2-application/`) - 12 scripts

#### JesterOS Core Services
| Script | Purpose | Key Functions | Memory Usage |
|--------|---------|---------------|--------------|
| `jesteros/daemon.sh` | Main JesterOS daemon | `daemon_start()`, `service_orchestrator()` | < 3MB |
| `jesteros/mood.sh` | Jester mood system | `update_mood()`, `mood_tracker()` | < 1MB |
| `jesteros/tracker.sh` | Writing statistics | `track_words()`, `update_stats()` | < 1MB |
| `jesteros/manager.sh` | Service manager | `start_service()`, `stop_service()` | < 1MB |
| `jesteros/health-check.sh` | System health monitor | `health_check()`, `system_status()` | < 1MB |
| `jesteros/wisdom.sh` | Inspirational quotes | `random_quote()`, `wisdom_display()` | < 1MB |

#### Writing Tools
| Script | Purpose | Key Functions | Memory Usage |
|--------|---------|---------------|--------------|
| `writing/vim-config.sh` | Vim writing configuration | `vim_writer_mode()`, `distraction_free()` | < 2MB |
| `writing/document-manager.sh` | Document management | `new_document()`, `auto_save()` | < 1MB |
| `writing/session-manager.sh` | Writing session control | `save_session()`, `restore_session()` | < 1MB |
| `writing/backup-manager.sh` | Manuscript backup | `backup_manuscripts()`, `sync_files()` | < 1MB |
| `writing/spell-check.sh` | Spell checking integration | `spell_check_enable()`, `dictionary_load()` | < 2MB |
| `writing/export-manager.sh` | Document export | `export_document()`, `format_convert()` | < 1MB |

### Layer 3: System Services (`runtime/3-system/`) - 8 scripts

#### Common Libraries
| Script | Purpose | Key Functions | Memory Usage |
|--------|---------|---------------|--------------|
| `common/common.sh` | Core utility library | `log_message()`, `validate_path()` | < 1MB |
| `common/service-functions.sh` | Service utilities | `start_service()`, `service_status()` | < 1MB |
| `common/security-functions.sh` | Security utilities | `secure_file_ops()`, `input_validation()` | < 1MB |
| `common/error-handling.sh` | Error management | `error_handler()`, `trace_execution()` | < 1MB |

#### System Management
| Script | Purpose | Key Functions | Memory Usage |
|--------|---------|---------------|--------------|
| `boot/boot-jester.sh` | JesterOS boot sequence | `boot_jesteros()`, `init_services()` | < 2MB |
| `memory/memory-guardian.sh` | Memory protection | `memory_guard()`, `sacred_check()` | < 1MB |
| `services/unified-monitor.sh` | System monitoring | `resource_monitor()`, `health_check()` | < 1MB |
| `services/service-orchestrator.sh` | Service coordination | `orchestrate_services()`, `dependency_check()` | < 1MB |

### Layer 4: Hardware Abstraction (`runtime/4-hardware/`) - 5 scripts

#### Hardware Control
| Script | Purpose | Key Functions | Memory Usage |
|--------|---------|---------------|--------------|
| `eink/display-control.sh` | E-Ink display driver | `eink_refresh()`, `partial_update()` | < 1MB |
| `power/power-manager.sh` | Power management | `power_sleep()`, `battery_status()` | < 1MB |
| `sensors/temperature-monitor.sh` | Temperature monitoring | `temp_monitor()`, `thermal_alert()` | < 1MB |
| `input/button-handler.sh` | Button input handling | `button_handler()`, `input_process()` | < 1MB |
| `input/usb-handler.sh` | USB connection management | `usb_detect()`, `mount_usb()` | < 1MB |

## 🧪 Test Scripts (`tests/`) - 18 scripts

### Core Test Suite
| Script | Purpose | Test Coverage | Runtime |
|--------|---------|---------------|---------|
| `run-tests.sh` | Main test runner | All test categories | 5-10 min |
| `01-safety-check.sh` | Critical safety validation | Kernel, memory, boot | 2 min |
| `02-boot-test.sh` | Boot sequence testing | Startup, services | 3 min |
| `03-functionality.sh` | Feature testing | Core features, APIs | 4 min |
| `04-docker-smoke.sh` | Build system testing | Docker, compilation | 5 min |
| `05-consistency-check.sh` | Configuration consistency | Configs, references | 2 min |
| `06-memory-guard.sh` | Memory usage validation | Memory limits, leaks | 3 min |
| `07-writer-experience.sh` | Writer workflow testing | Vim, writing tools | 4 min |

### Specialized Tests
| Script | Purpose | Test Coverage | Runtime |
|--------|---------|---------------|---------|
| `phase1-validation.sh` | Pre-build validation | Dependencies, tools | 2 min |
| `phase2-validation.sh` | Post-build validation | Build artifacts | 3 min |
| `phase3-validation.sh` | Deployment validation | SD card, installation | 5 min |
| `test-bootloader-setup.sh` | Bootloader testing | MLO, u-boot validation | 2 min |
| `quick-integration-test.sh` | Fast integration check | Essential functions | 3 min |
| `validate-jesteros.sh` | JesterOS service testing | Service functionality | 4 min |
| `run-production-test.sh` | Production readiness | Full system test | 10 min |
| `run-lenny-test.sh` | Debian Lenny testing | Rootfs compatibility | 5 min |
| `run-authentic-lenny.sh` | Authentic Debian test | Original Debian test | 5 min |
| `jesteros-integration-test.dockerfile` | Container integration | Docker test env | N/A |

## 🔧 Build & Deployment Scripts (`build/`) - 15 scripts

### Core Build Scripts
| Script | Purpose | Key Functions | Dependencies |
|--------|---------|---------------|--------------|
| `scripts/build_kernel.sh` | Main kernel build | `build_kernel()`, `configure_modules()` | Docker, NDK |
| `scripts/build-all.sh` | Complete system build | `build_all()`, `package_system()` | All tools |
| `scripts/create-image.sh` | SD card image creation | `create_sd_image()`, `partition_disk()` | dd, mkfs |
| `scripts/deploy_to_nook.sh` | Device deployment | `deploy_system()`, `flash_device()` | adb, fastboot |

### Specialized Build Scripts
| Script | Purpose | Key Functions | Dependencies |
|--------|---------|---------------|--------------|
| `scripts/extract-bootloaders.sh` | Bootloader extraction | `extract_mlo()`, `extract_uboot()` | loop, mount |
| `scripts/extract-bootloaders-dd.sh` | DD-based extraction | `dd_extract()`, `offset_calc()` | dd, hexdump |
| `scripts/create-mvp-sd.sh` | MVP SD card creation | `create_mvp()`, `minimal_system()` | Basic tools |
| `scripts/create_deployment.sh` | Deployment package | `package_deploy()`, `validate_package()` | tar, gzip |
| `scripts/create_cwm.sh` | ClockworkMod package | `create_cwm()`, `update_binary()` | zip, signing |
| `scripts/build-lenny-rootfs.sh` | Debian Lenny rootfs | `build_rootfs()`, `debootstrap_lenny()` | debootstrap |
| `scripts/fix-docker-permissions.sh` | Docker permission fix | `fix_perms()`, `chown_recursive()` | chown, chmod |

## 🛠️ Utility & Maintenance Scripts - 20+ scripts

### Development Tools
| Script | Purpose | Key Functions | Usage |
|--------|---------|---------------|--------|
| `tools/migrate-to-embedded-structure.sh` | Structure migration | `migrate_files()`, `update_refs()` | One-time |
| `tools/wsl-mount-usb.sh` | WSL USB mounting | `mount_usb_wsl()`, `detect_devices()` | Development |
| `tools/test/test-improvements.sh` | Test validation | `validate_improvements()`, `safety_check()` | CI/CD |
| `tools/deploy/flash-sd.sh` | SD card flashing | `flash_device()`, `verify_flash()` | Deployment |

### Maintenance Scripts
| Script | Purpose | Key Functions | Usage |
|--------|---------|---------------|--------|
| `tools/maintenance/install-jesteros-userspace.sh` | Userspace install | `install_services()`, `configure_interface()` | Setup |
| `tools/maintenance/fix-boot-loop.sh` | Boot loop repair | `fix_boot()`, `repair_filesystem()` | Troubleshooting |
| `tools/maintenance/cleanup_nook_project.sh` | Project cleanup | `cleanup_artifacts()`, `remove_temp()` | Maintenance |

## 🔍 Script Dependencies & Relationships

### Core Dependencies
```
common.sh ← Most runtime scripts depend on this
├── logging functions
├── validation functions  
├── error handling
└── utility functions

service-functions.sh ← Service management scripts
├── service lifecycle
├── dependency checking
└── status monitoring

security-functions.sh ← All user-facing scripts
├── input validation
├── path protection
└── safe file operations
```

### Service Dependencies
```
jesteros/daemon.sh (main orchestrator)
├── jesteros/mood.sh (mood system)
├── jesteros/tracker.sh (statistics)
├── jesteros/health-check.sh (monitoring)
└── jesteros/wisdom.sh (quotes)

boot-jester.sh (initialization)
├── memory-guardian.sh (protection)
├── unified-monitor.sh (monitoring)
└── All Layer 4 hardware scripts
```

## 📋 Script Usage Patterns

### Standard Script Header
```bash
#!/bin/bash
# Script: script-name.sh
# Purpose: Brief description
# Layer: X (for runtime scripts)
# Memory: < XMB
# Dependencies: List of required scripts/tools

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

# Source common functions
source "$(dirname "$0")/../../3-system/common/common.sh"
```

### Memory-Aware Pattern
```bash
# Check memory before heavy operations
if ! memory_check; then
    log_message "WARNING" "Low memory detected"
    memory_optimize
fi

# Protect writing space
memory_sacred_check || {
    log_message "ERROR" "Writing space compromised"
    exit 1
}
```

### Error Handling Pattern
```bash
function main() {
    validate_inputs "$@" || {
        usage
        exit 1
    }
    
    # Safe operations with validation
    secure_file_ops "operation" "$file_path"
    
    log_message "INFO" "Operation completed successfully"
}

main "$@"
```

---

## 🎯 Quick Script Finder

### By Function
- **Service Management**: `jesteros/manager.sh`, `service-orchestrator.sh`
- **Display Control**: `display-control.sh`, `message-display.sh`
- **Memory Management**: `memory-guardian.sh`, `unified-monitor.sh`
- **Boot & Init**: `boot-jester.sh`, `jesteros-init.sh`
- **Testing**: `run-tests.sh`, `*-test.sh`, `validate-*.sh`

### By Layer
- **Layer 1 (UI)**: `runtime/1-ui/`
- **Layer 2 (Application)**: `runtime/2-application/`
- **Layer 3 (System)**: `runtime/3-system/`
- **Layer 4 (Hardware)**: `runtime/4-hardware/`

### By Purpose
- **Development**: `build/scripts/`, `tools/`
- **Testing**: `tests/`
- **Deployment**: `deploy-*.sh`, `create-*.sh`
- **Maintenance**: `tools/maintenance/`

---

*"Every script cataloged, every function mapped - for developers who build the future of writing"* 🕯️📜

*Scripts Catalog v1.0.0 - Complete coverage of 82 shell scripts*