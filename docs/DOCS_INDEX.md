# JesterOS Documentation Index
*Complete guide to all project documentation*

## 📚 Documentation Overview

The `/docs` directory contains comprehensive documentation for JesterOS, organized by category and purpose. This index provides navigation and context for all documentation resources.

**Last Updated**: January 2025  
**Total Documents**: 28 files across 4 categories  
**Documentation Standard**: Markdown with cross-references

---

## 🗂️ Documentation Categories

### 1. [Project Architecture](#project-architecture)
Core system design and structure documentation

### 2. [Hardware Reference](#hardware-reference)
Device-specific hardware documentation and guides

### 3. [Kernel Documentation](#kernel-documentation)
Linux 2.6.29 kernel reference and APIs

### 4. [Community Resources](#community-resources)
XDA forums research and Phoenix Project findings

### 5. [Archives](#archives)
Historical documentation and migration records

---

## 📐 Project Architecture

### Core Documentation

| Document | Purpose | Status |
|----------|---------|--------|
| [`ARCHITECTURE_ANALYSIS_REPORT.md`](ARCHITECTURE_ANALYSIS_REPORT.md) | Complete system architecture analysis | ✅ Current |
| [`STANDARDIZED_PROJECT_STRUCTURE.md`](STANDARDIZED_PROJECT_STRUCTURE.md) | Post-migration project organization | ✅ Current |
| [`CURRENT_STATE_ANALYSIS.md`](CURRENT_STATE_ANALYSIS.md) | Current system state and metrics | ✅ Current |
| [`SRC_INDEX.md`](SRC_INDEX.md) | Source code structure documentation | ✅ NEW |

### Boot System Documentation

| Document | Purpose | Migration Status |
|----------|---------|-----------------|
| [`JESTEROS_BOOT_MASTER.md`](JESTEROS_BOOT_MASTER.md) | Master boot process documentation | ✅ Updated |
| [`BOOT_MIGRATION_NOTES.md`](BOOT_MIGRATION_NOTES.md) | Migration from 4-layer to standard | ✅ Complete |

### API Documentation

| Document | Purpose | Version |
|----------|---------|---------|
| [`KERNEL_API.md`](KERNEL_API.md) | JesterOS kernel API reference | v1.0 |

### Build System

| Document | Purpose | Tools |
|----------|---------|-------|
| [`build-system-documentation.md`](build-system-documentation.md) | Complete build system guide | Docker, Make |

---

## 🔧 Hardware Reference

### Display & Input

| Document | Hardware Component | Key Topics |
|----------|-------------------|------------|
| [`EINK_DISPLAY_REFERENCE.md`](hardware/EINK_DISPLAY_REFERENCE.md) | E-Ink Pearl display | Refresh modes, waveforms, fbink |
| [`TOUCH_INPUT_REFERENCE.md`](hardware/TOUCH_INPUT_REFERENCE.md) | zForce IR touchscreen | Event handling, zones, recovery |
| [`BUTTON_NAVIGATION_GUIDE.md`](hardware/BUTTON_NAVIGATION_GUIDE.md) | Physical buttons | GPIO mapping, navigation |

### Power & Sensors

| Document | Hardware Component | Key Topics |
|----------|-------------------|------------|
| [`POWER_MANAGEMENT_GUIDE.md`](hardware/POWER_MANAGEMENT_GUIDE.md) | Battery & power | Profiles, optimization, 1.5% drain |
| [`SENSOR_SYSTEM_GUIDE.md`](hardware/SENSOR_SYSTEM_GUIDE.md) | Temperature sensors | Monitoring, thresholds |

### USB & Connectivity

| Document | Hardware Component | Key Topics |
|----------|-------------------|------------|
| [`USB_KEYBOARD.md`](hardware/USB_KEYBOARD.md) | USB keyboard support | Detection, layout, integration |
| [`USB_KEYBOARD_WIFI_ANALYSIS.md`](hardware/USB_KEYBOARD_WIFI_ANALYSIS.md) | USB vs WiFi trade-offs | Power analysis, recommendations |

### System Information

| Document | Purpose | Content |
|----------|---------|---------|
| [`NOOK_HARDWARE_REFERENCE.md`](hardware/NOOK_HARDWARE_REFERENCE.md) | Complete hardware specs | CPU, RAM, peripherals |
| [`SYSTEM_INFORMATION.md`](hardware/SYSTEM_INFORMATION.md) | System details | Kernel, Android base, limits |

---

## 🐧 Kernel Documentation

### Reference Guides

| Document | Kernel Version | Topics |
|----------|---------------|--------|
| [`kernel-documentation.md`](kernel-reference/kernel-documentation.md) | 2.6.29 | General kernel docs |
| [`memory-management-arm-2.6.29.md`](kernel-reference/memory-management-arm-2.6.29.md) | 2.6.29 ARM | Memory subsystem |
| [`module-building-2.6.29.md`](kernel-reference/module-building-2.6.29.md) | 2.6.29 | Kernel modules |
| [`proc-filesystem-2.6.29.md`](kernel-reference/proc-filesystem-2.6.29.md) | 2.6.29 | /proc interface |
| [`quick-reference-2.6.29.md`](kernel-reference/quick-reference-2.6.29.md) | 2.6.29 | Quick reference |

---

## 🌐 Community Resources

### Phoenix Project (XDA Forums)

| Document | Purpose | Key Findings |
|----------|---------|--------------|
| [`PHOENIX_PROJECT_SUMMARY.md`](xda-forums/PHOENIX_PROJECT_SUMMARY.md) | Executive summary | Hardware realities |
| [`PHOENIX_PROJECT_CONSOLIDATED.md`](xda-forums/PHOENIX_PROJECT_CONSOLIDATED.md) | Complete findings | All optimizations |
| [`NST_G_Phoenix_Project.md`](xda-forums/NST_G_Phoenix_Project.md) | Original thread | Community wisdom |
| [`phoenix-project-analysis.json`](xda-forums/phoenix-project-analysis.json) | Structured data | Machine-readable |

**Critical Phoenix Findings**:
- 92.8MB actual memory limit (not 95MB)
- Touch screen hardware defect (ALL devices)
- 1.5% daily battery drain achievable
- SanDisk Class 10 SD cards required

---

## 📦 Archives

### Boot Documentation Archive (January 2025)

| Document | Original Purpose | Archive Reason |
|----------|-----------------|----------------|
| [`BOOT-INFRASTRUCTURE-COMPLETE.md`](archive/boot-docs-2025-01/BOOT-INFRASTRUCTURE-COMPLETE.md) | Pre-migration boot docs | Superseded by migration |
| [`JESTEROS_BOOT_PROCESS.md`](archive/boot-docs-2025-01/JESTEROS_BOOT_PROCESS.md) | Original boot process | Updated structure |
| [`URAM_IMAGE_ANALYSIS.md`](archive/boot-docs-2025-01/URAM_IMAGE_ANALYSIS.md) | uRamdisk analysis | Historical reference |

---

## 🔍 Quick Navigation

### By Topic

#### **System Design**
- Architecture → [`ARCHITECTURE_ANALYSIS_REPORT.md`](ARCHITECTURE_ANALYSIS_REPORT.md)
- Project Structure → [`STANDARDIZED_PROJECT_STRUCTURE.md`](STANDARDIZED_PROJECT_STRUCTURE.md)
- Source Code → [`SRC_INDEX.md`](SRC_INDEX.md)

#### **Hardware**
- E-Ink Display → [`EINK_DISPLAY_REFERENCE.md`](hardware/EINK_DISPLAY_REFERENCE.md)
- Touch Input → [`TOUCH_INPUT_REFERENCE.md`](hardware/TOUCH_INPUT_REFERENCE.md)
- Power Management → [`POWER_MANAGEMENT_GUIDE.md`](hardware/POWER_MANAGEMENT_GUIDE.md)

#### **Development**
- Build System → [`build-system-documentation.md`](build-system-documentation.md)
- Kernel API → [`KERNEL_API.md`](KERNEL_API.md)
- Boot Process → [`JESTEROS_BOOT_MASTER.md`](JESTEROS_BOOT_MASTER.md)

#### **Community**
- Phoenix Project → [`PHOENIX_PROJECT_SUMMARY.md`](xda-forums/PHOENIX_PROJECT_SUMMARY.md)
- Hardware Reality → [`phoenix-project-analysis.json`](xda-forums/phoenix-project-analysis.json)

---

## 📊 Documentation Statistics

### Coverage by Component

| Component | Documents | Coverage |
|-----------|-----------|----------|
| Hardware | 9 docs | ████████░░ 85% |
| Software | 7 docs | ███████░░░ 75% |
| Kernel | 5 docs | ██████░░░░ 65% |
| Community | 4 docs | █████████░ 95% |

### Documentation Health

| Metric | Status | Notes |
|--------|--------|-------|
| **Completeness** | ✅ Good | All major systems documented |
| **Currency** | ✅ Current | Updated January 2025 |
| **Accuracy** | ✅ Verified | Phoenix Project validated |
| **Accessibility** | ✅ Indexed | This document provides navigation |

---

## 🚀 Getting Started

### For New Contributors
1. Start with [`README.md`](README.md) - Project overview
2. Review [`STANDARDIZED_PROJECT_STRUCTURE.md`](STANDARDIZED_PROJECT_STRUCTURE.md) - Current organization
3. Study [`SRC_INDEX.md`](SRC_INDEX.md) - Source code guide

### For Hardware Work
1. Read [`NOOK_HARDWARE_REFERENCE.md`](hardware/NOOK_HARDWARE_REFERENCE.md) - Complete specs
2. Review [`PHOENIX_PROJECT_SUMMARY.md`](xda-forums/PHOENIX_PROJECT_SUMMARY.md) - Real-world findings
3. Check specific component guides in `/hardware/`

### For System Development
1. Understand [`ARCHITECTURE_ANALYSIS_REPORT.md`](ARCHITECTURE_ANALYSIS_REPORT.md) - System design
2. Reference [`KERNEL_API.md`](KERNEL_API.md) - Available APIs
3. Follow [`build-system-documentation.md`](build-system-documentation.md) - Build process

---

## 📝 Documentation Standards

### File Naming
- `UPPERCASE.md` - Major documentation
- `lowercase-with-dashes.md` - Reference guides
- `Component_Specific_Guide.md` - Hardware docs

### Structure
1. **Title** with description
2. **Quick Reference** table
3. **Detailed Content** with examples
4. **Cross-References** to related docs
5. **Summary** with key takeaways

### Maintenance
- Update `DOCS_INDEX.md` when adding new docs
- Archive outdated documentation
- Maintain cross-reference accuracy
- Version significant changes

---

## 🔄 Recent Updates

### January 2025
- ✅ Created `SRC_INDEX.md` for source documentation
- ✅ Migrated boot docs to archive
- ✅ Added Phoenix Project findings
- ✅ Updated for post-migration structure

### Pending Documentation
- [ ] Touch recovery implementation guide
- [ ] Power optimization cookbook
- [ ] Logging module design
- [ ] E-Ink refresh patterns guide

---

## 📚 Related Resources

### Internal
- Project root [`README.md`](../README.md)
- Claude's reflections [`CLAUDES_CORNER.md`](../CLAUDES_CORNER.md)
- Migration script [`BLOOD_PACT_MIGRATION.sh`](../scripts/BLOOD_PACT_MIGRATION.sh)

### External
- [XDA Forums NST Development](https://forum.xda-developers.com/f/nook-touch-development.1235/)
- [Linux 2.6.29 Kernel Docs](https://www.kernel.org/doc/html/v2.6.29/)
- [E-Ink Technology Guide](https://www.eink.com/technology.html)

---

*DOCS_INDEX.md - Your guide to JesterOS documentation*  
*Generated January 2025*  
*Part of the JesterOS Documentation Suite*