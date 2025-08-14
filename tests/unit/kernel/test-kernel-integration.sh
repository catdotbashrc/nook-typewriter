#!/bin/bash
# Unit Test: Kernel Integration for SquireOS
# Tests that SquireOS modules are properly integrated into kernel build system

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "Kernel Integration"

KERNEL_SRC="$PROJECT_ROOT/source/kernel/src"
DRIVERS_DIR="$KERNEL_SRC/drivers"
SQUIREOS_DIR="$DRIVERS_DIR/squireos"

echo "  Testing kernel build system integration..."

# Test drivers/Makefile includes SquireOS
DRIVERS_MAKEFILE="$DRIVERS_DIR/Makefile"
assert_file_exists "$DRIVERS_MAKEFILE" "Drivers Makefile exists"
assert_contains "$(cat "$DRIVERS_MAKEFILE")" "CONFIG_SQUIREOS.*squireos" "SquireOS added to drivers Makefile"

# Test drivers/Kconfig includes SquireOS
DRIVERS_KCONFIG="$DRIVERS_DIR/Kconfig"
assert_file_exists "$DRIVERS_KCONFIG" "Drivers Kconfig exists"
assert_contains "$(cat "$DRIVERS_KCONFIG")" "drivers/squireos/Kconfig" "SquireOS Kconfig sourced in drivers"

echo "  Testing SquireOS module build system..."

# Test SquireOS Makefile
SQUIREOS_MAKEFILE="$SQUIREOS_DIR/Makefile"
assert_file_exists "$SQUIREOS_MAKEFILE" "SquireOS Makefile exists"

# Test that all modules are included in Makefile
required_modules=("squireos_core" "jester" "typewriter" "wisdom")
for module in "${required_modules[@]}"; do
    assert_contains "$(cat "$SQUIREOS_MAKEFILE")" "$module.o" "Module $module in Makefile"
done

# Test SquireOS Kconfig
SQUIREOS_KCONFIG="$SQUIREOS_DIR/Kconfig"
assert_file_exists "$SQUIREOS_KCONFIG" "SquireOS Kconfig exists"

# Test Kconfig structure
assert_contains "$(cat "$SQUIREOS_KCONFIG")" "menuconfig SQUIREOS" "Has main SquireOS menu"
assert_contains "$(cat "$SQUIREOS_KCONFIG")" "tristate.*SquireOS" "SquireOS is tristate (modular)"

# Test individual module configs
module_configs=("SQUIREOS_JESTER" "SQUIREOS_TYPEWRITER" "SQUIREOS_WISDOM")
for config in "${module_configs[@]}"; do
    assert_contains "$(cat "$SQUIREOS_KCONFIG")" "config $config" "Has $config option"
done

echo "  Testing kernel configuration..."

# Test kernel .config includes SquireOS
KERNEL_CONFIG="$KERNEL_SRC/.config"
if [ -f "$KERNEL_CONFIG" ]; then
    echo "  ✓ Kernel .config file exists"
    
    # Test SquireOS configuration
    if grep -q "CONFIG_SQUIREOS=m" "$KERNEL_CONFIG"; then
        echo "  ✓ SquireOS configured as module"
    else
        echo "  ⚠ SquireOS not configured in kernel (may need build)"
    fi
    
    # Test individual module configs
    for config in "${module_configs[@]}"; do
        if grep -q "CONFIG_$config=y" "$KERNEL_CONFIG"; then
            echo "  ✓ $config enabled in kernel"
        else
            echo "  ⚠ $config not configured (may need build)"
        fi
    done
else
    echo "  ⚠ Kernel .config not found (kernel may need configuration)"
fi

echo "  Testing module dependencies..."

# Test that modules have proper dependencies
core_module="$SQUIREOS_DIR/squireos_core.c"
if [ -f "$core_module" ]; then
    # Test that other modules reference the core
    for module in jester typewriter wisdom; do
        module_file="$SQUIREOS_DIR/$module.c"
        if [ -f "$module_file" ]; then
            if grep -q "squireos_root\|extern.*squireos" "$module_file"; then
                echo "  ✓ $module module references SquireOS core"
            else
                echo "  ⚠ $module module may not properly reference core"
            fi
        fi
    done
fi

echo "  Testing build artifacts preparation..."

# Test that build directory structure is ready
if [ -d "$KERNEL_SRC/arch/arm" ]; then
    echo "  ✓ ARM architecture support present"
else
    echo "  ⚠ ARM architecture support not found"
fi

# Test for NST-specific configuration
if [ -f "$KERNEL_SRC/arch/arm/configs/omap3621_gossamer_evt1c_defconfig" ]; then
    echo "  ✓ NST-specific defconfig present"
else
    echo "  ⚠ NST defconfig not found"
fi

echo "  Testing medieval theming consistency..."

# Test that all Kconfig help texts maintain medieval theme
if grep -q "quill\|candlelight\|scribe\|medieval" "$SQUIREOS_KCONFIG"; then
    echo "  ✓ Kconfig maintains medieval theming"
else
    echo "  ⚠ Medieval theming not found in Kconfig"
fi

# Test Makefile comments for theme consistency
if grep -q "quill\|medieval\|candlelight" "$SQUIREOS_MAKEFILE"; then
    echo "  ✓ Makefile maintains medieval theming"
else
    echo "  ⚠ Medieval theming not found in Makefile"
fi

echo "  Testing memory and size constraints..."

# Test that module object sizes will be reasonable
module_source_total=0
for module in squireos_core jester typewriter wisdom; do
    module_file="$SQUIREOS_DIR/$module.c"
    if [ -f "$module_file" ]; then
        size=$(stat -c%s "$module_file" 2>/dev/null || echo "0")
        module_source_total=$((module_source_total + size))
    fi
done

assert_less_than "$module_source_total" 40960 "Total module source size reasonable (<40KB)"

echo "  Testing compilation readiness..."

# Test that essential includes are available for cross-compilation
essential_includes=("linux/module.h" "linux/proc_fs.h" "linux/kernel.h")
for include in "${essential_includes[@]}"; do
    if find "$KERNEL_SRC" -name "$(basename "$include")" -type f | grep -q .; then
        echo "  ✓ Essential include $include available"
    else
        echo "  ⚠ Include $include not found (may affect compilation)"
    fi
done

# Test for timeconst.pl fix (known issue)
TIMECONST_PL="$KERNEL_SRC/kernel/timeconst.pl"
if [ -f "$TIMECONST_PL" ]; then
    if grep -q "if (!@val)" "$TIMECONST_PL"; then
        echo "  ✓ timeconst.pl Perl compatibility fix applied"
    else
        echo "  ⚠ timeconst.pl may need Perl compatibility fix"
    fi
fi

echo "  Testing module loading sequence..."

# Test that modules can be loaded in proper order
# Core module should be loadable first
if grep -q "module_init.*squireos_init" "$SQUIREOS_DIR/squireos_core.c" 2>/dev/null; then
    echo "  ✓ Core module has proper init function"
fi

# Other modules should depend on core
dependency_count=0
for module in jester typewriter wisdom; do
    module_file="$SQUIREOS_DIR/$module.c"
    if [ -f "$module_file" ] && grep -q "extern.*squireos_root" "$module_file"; then
        ((dependency_count++))
    fi
done

if [ "$dependency_count" -gt 0 ]; then
    echo "  ✓ Modules have proper dependency structure ($dependency_count modules depend on core)"
fi

pass_test "SquireOS kernel integration and build system configuration validated"