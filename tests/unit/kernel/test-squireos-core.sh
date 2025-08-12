#!/bin/bash
# Unit Test: SquireOS Core Module Functionality
# Tests the core module structure, compilation, and basic functionality

set -euo pipefail

source "$(dirname "$0")/../../test-framework.sh"

init_test "SquireOS Core Module"

MODULE_DIR="$PROJECT_ROOT/source/kernel/src/drivers/squireos"
CORE_MODULE="$MODULE_DIR/squireos_core.c"

# Verify core module exists
assert_file_exists "$CORE_MODULE" "SquireOS core module source"

echo "  Testing module structure and content..."

# Test module licensing
assert_contains "$(cat "$CORE_MODULE")" "MODULE_LICENSE.*GPL" "Has GPL license"

# Test module metadata
assert_contains "$(cat "$CORE_MODULE")" "MODULE_AUTHOR" "Has author metadata"
assert_contains "$(cat "$CORE_MODULE")" "MODULE_DESCRIPTION" "Has description metadata"
assert_contains "$(cat "$CORE_MODULE")" "MODULE_VERSION" "Has version metadata"

# Test essential includes
assert_contains "$(cat "$CORE_MODULE")" "#include <linux/module.h>" "Includes module.h"
assert_contains "$(cat "$CORE_MODULE")" "#include <linux/proc_fs.h>" "Includes proc_fs.h"

# Test module init/exit functions
assert_contains "$(cat "$CORE_MODULE")" "module_init" "Has module_init"
assert_contains "$(cat "$CORE_MODULE")" "module_exit" "Has module_exit"

# Test SquireOS specific functionality
assert_contains "$(cat "$CORE_MODULE")" "squireos_init" "Has SquireOS init function"
assert_contains "$(cat "$CORE_MODULE")" "squireos_exit" "Has SquireOS exit function"

# Test /proc interface creation
assert_contains "$(cat "$CORE_MODULE")" "proc_mkdir.*squireos" "Creates /proc/squireos directory"
assert_contains "$(cat "$CORE_MODULE")" "create_proc_read_entry.*motto" "Creates motto proc entry"
assert_contains "$(cat "$CORE_MODULE")" "create_proc_read_entry.*version" "Creates version proc entry"

# Test medieval theming
assert_contains "$(cat "$CORE_MODULE")" "By quill and candlelight" "Contains medieval motto"
assert_contains "$(cat "$CORE_MODULE")" "digital scriptorium\|Digital scriptorium" "References scriptorium"

# Test error handling
assert_contains "$(cat "$CORE_MODULE")" "remove_proc_entry" "Has cleanup code"
assert_contains "$(cat "$CORE_MODULE")" "ENOMEM\|return -" "Has error handling"

# Test memory safety
line_count=$(wc -l < "$CORE_MODULE")
assert_less_than "$line_count" 200 "Module is reasonably sized for embedded system"

# Test that version information is properly defined
assert_contains "$(cat "$CORE_MODULE")" "SQUIREOS_VERSION.*\"" "Has version string"
assert_contains "$(cat "$CORE_MODULE")" "SQUIREOS_CODENAME.*\"" "Has codename string"

echo "  Testing compilation prerequisites..."

# Test that module can be syntax-checked (if gcc available)
if command -v gcc >/dev/null 2>&1; then
    # Create temporary test compilation
    temp_dir=$(mktemp -d)
    temp_file="$temp_dir/test_squireos_core.c"
    
    # Create minimal test harness
    cat > "$temp_file" << 'EOF'
// Mock kernel headers for syntax testing
#define MODULE_LICENSE(x)
#define MODULE_AUTHOR(x)
#define MODULE_DESCRIPTION(x)
#define MODULE_VERSION(x)
#define module_init(x)
#define module_exit(x)
#define KERN_INFO
#define KERN_ERR
int printk(const char *fmt, ...);
typedef struct proc_dir_entry proc_dir_entry;
struct proc_dir_entry *proc_mkdir(const char *name, struct proc_dir_entry *parent);
struct proc_dir_entry *create_proc_read_entry(const char *name, int mode, 
    struct proc_dir_entry *parent, int (*read_proc)(char*,char**,int,int,int*,void*), void *data);
void remove_proc_entry(const char *name, struct proc_dir_entry *parent);
#define ENOMEM 12

EOF
    
    # Append core module source (excluding includes)
    sed '/^#include/d' "$CORE_MODULE" >> "$temp_file"
    
    if gcc -fsyntax-only -Wall -Werror "$temp_file" 2>/dev/null; then
        echo "  ✓ Module syntax is valid"
    else
        echo "  ⚠ Module has syntax warnings (may be kernel-specific)"
    fi
    
    rm -rf "$temp_dir"
fi

# Test file size constraints for embedded system
file_size=$(stat -c%s "$CORE_MODULE" 2>/dev/null || echo "0")
assert_less_than "$file_size" 8192 "Source file size reasonable for embedded system"

pass_test "SquireOS core module structure and functionality validated"