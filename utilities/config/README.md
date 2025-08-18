# Centralized Path Configuration

## Overview

This directory contains the centralized path configuration for the JesterOS/Nook project, eliminating relative path issues and providing consistent, absolute paths across all scripts.

## Philosophy

Based on best practices for bash scripting:
- **Absolute paths over relative paths**: Prevents issues when scripts are called from different directories
- **Single source of truth**: All paths defined in one place
- **Cross-shell compatibility**: Works with both bash and zsh
- **Automatic validation**: Built-in functions to verify paths exist

## Usage

### In Bash Scripts

```bash
#!/bin/bash

# Source the centralized path configuration
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/config/paths.sh"

# Use the configured paths
source "$JESTEROS_COMMON_LIB"
source "$JESTEROS_TEST_FRAMEWORK"

# Access any configured path
echo "Project root: $JESTEROS_PROJECT_ROOT"
echo "Test directory: $JESTEROS_TEST"
```

### Available Variables

#### Core Paths
- `$JESTEROS_PROJECT_ROOT` - Project root directory
- `$JESTEROS_UTILITIES` - Utilities root directory
- `$JESTEROS_CONFIG` - This config directory

#### Utility Subdirectories
- `$JESTEROS_LIB` - Common libraries
- `$JESTEROS_BUILD` - Build scripts
- `$JESTEROS_DEPLOY` - Deployment tools
- `$JESTEROS_MAINTAIN` - Maintenance scripts
- `$JESTEROS_SETUP` - Setup and configuration
- `$JESTEROS_MIGRATE` - Migration tools
- `$JESTEROS_TEST` - Test framework
- `$JESTEROS_TEST_TESTS` - Test scripts
- `$JESTEROS_PLATFORM` - Platform-specific tools
- `$JESTEROS_EXTRAS` - Additional tools

#### Key Files
- `$JESTEROS_COMMON_LIB` - Common library file
- `$JESTEROS_TEST_FRAMEWORK` - Test framework file
- `$JESTEROS_TEST_RUNNER` - Test runner script

### Utility Functions

The configuration provides several utility functions (available in bash only):

```bash
# Verify a path exists
if verify_path "$some_path" "file"; then
    echo "File exists"
fi

# Get absolute path (resolves symlinks)
abs_path=$(get_absolute_path "$relative_path")

# Ensure directory exists (creates if needed)
ensure_directory "$JESTEROS_BACKUPS/today"

# Print all configured paths (for debugging)
print_paths
```

## Benefits

1. **No More Relative Path Issues**: Scripts work regardless of where they're called from
2. **Easier Refactoring**: Change paths in one place
3. **Better Testing**: Tests can reliably find the files they need to test
4. **Cross-Shell Support**: Works in both bash and zsh environments
5. **Self-Documenting**: Variable names clearly indicate what they point to

## Migration Guide

### Old Approach (Relative Paths)
```bash
# Fragile - breaks if called from different directory
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "../../setup/some-script.sh"
```

### New Approach (Centralized Config)
```bash
# Robust - always works
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config/paths.sh"
source "$JESTEROS_COMMON_LIB"
source "$JESTEROS_SETUP/some-script.sh"
```

## Testing

To verify the configuration is working:

```bash
# Source the config
source /home/jyeary/projects/personal/nook/utilities/config/paths.sh

# Print all paths
print_paths

# Validate critical paths exist
validate_paths
```

## Compatibility Notes

- **Bash**: Full support including exported functions
- **Zsh**: Full support for variables, functions available but not exported
- **POSIX sh**: Variables work, advanced functions may not be available

## Best Practices

1. **Always source at the beginning** of your script
2. **Use the variables** instead of hardcoding paths
3. **Validate paths** when dealing with user input or optional files
4. **Update the config** when adding new directories or key files
5. **Test your scripts** from different directories to ensure they work

## Troubleshooting

### "Command not found" errors
- Ensure you're sourcing the config file correctly
- Check that the path to paths.sh is correct

### Variables are empty
- Verify the config file is being sourced
- Check for typos in variable names
- Run `print_paths` to see all available variables

### Functions not available in zsh
- This is expected - zsh doesn't support `export -f`
- Functions are still available in the current shell, just not exported

---

*This centralized configuration approach follows bash scripting best practices and eliminates the fragility of relative paths.*