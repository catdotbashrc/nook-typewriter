#!/bin/bash
# Test Consolidation Script for JesterOS
# Consolidates test directories while preserving tests/ as primary
# Date: 2025-01-18

set -euo pipefail
trap 'echo "Error at line $LINENO"' ERR

# Configuration
DRY_RUN=${1:-}
BACKUP_DIR=".archives/tests-backup-$(date +%Y%m%d-%H%M%S)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +%H:%M:%S)]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check if in correct directory
if [[ ! -f "CLAUDE.md" || ! -d "tests" ]]; then
    error "Not in JesterOS root directory"
fi

if [[ "$DRY_RUN" == "--dry-run" ]]; then
    log "🔍 DRY RUN MODE - No changes will be made"
    EXEC="echo [DRY-RUN]"
else
    log "🚀 Consolidating test directories"
    EXEC=""
fi

# Create backup directory
log "📦 Creating backup directory..."
$EXEC mkdir -p "$BACKUP_DIR"

# Phase 1: Backup existing test directories
log "💾 Backing up test directories..."
for dir in tools/test scripts/test utilities/test; do
    if [[ -d "$dir" ]]; then
        log "  Backing up $dir"
        $EXEC cp -r "$dir" "$BACKUP_DIR/$(echo $dir | tr '/' '_')"
    fi
done

# Phase 2: Create new structure in tests/
log "📁 Creating organized structure in tests/..."
$EXEC mkdir -p tests/unit
$EXEC mkdir -p tests/lib
$EXEC mkdir -p tests/tools

# Phase 3: Move unit tests (prefer newer utilities versions)
log "🔄 Consolidating unit tests..."

# These test files will go to tests/unit/
for file in test_apply_metadata.sh test_common.sh test_framework.sh test_secure_chmod.sh; do
    # Check utilities/test/tests/ first (newer versions)
    if [[ -f "utilities/test/tests/$file" ]]; then
        log "  Moving $file from utilities/test/tests/"
        $EXEC cp "utilities/test/tests/$file" "tests/unit/"
    elif [[ -f "scripts/test/$file" ]]; then
        log "  Moving $file from scripts/test/"
        $EXEC cp "scripts/test/$file" "tests/unit/"
    fi
done

# Phase 4: Move unique valuable files
log "✨ Adding unique test tools..."

# Move test-improvements.sh from tools/test/
if [[ -f "tools/test/test-improvements.sh" ]]; then
    log "  Adding test-improvements.sh to tests/tools/"
    $EXEC cp "tools/test/test-improvements.sh" "tests/tools/"
fi

# Move framework files to lib if they add value
if [[ -f "utilities/test/framework.sh" ]]; then
    # Check if it's different from test-lib.sh
    if ! cmp -s "utilities/test/framework.sh" "tests/test-lib.sh" 2>/dev/null; then
        log "  Adding framework.sh to tests/lib/ for review"
        $EXEC cp "utilities/test/framework.sh" "tests/lib/framework-utilities.sh"
    fi
fi

# Phase 5: Clean up old directories
log "🧹 Removing old test directories..."
if [[ "$DRY_RUN" != "--dry-run" ]]; then
    for dir in tools/test scripts/test utilities/test; do
        if [[ -d "$dir" ]]; then
            log "  Removing $dir"
            rm -rf "$dir"
        fi
    done
else
    log "  [DRY-RUN] Would remove tools/test scripts/test utilities/test"
fi

# Phase 6: Update test runner to include new paths
log "📝 Updating test runner configuration..."
if [[ "$DRY_RUN" != "--dry-run" ]]; then
    # Add unit test directory to test-runner.sh if not already there
    if ! grep -q "tests/unit" tests/test-runner.sh 2>/dev/null; then
        cat >> tests/test-runner.sh << 'EOF'

# Run unit tests
if [[ -d "tests/unit" ]]; then
    echo "Running unit tests..."
    for test in tests/unit/test_*.sh; do
        [[ -f "$test" ]] && bash "$test"
    done
fi
EOF
    fi
fi

# Phase 7: Create index file
log "📚 Creating test index..."
cat > tests/TEST_INDEX.md << 'EOF'
# Test Suite Index

## Structure
```
tests/
├── 01-07-*.sh         # Numbered integration tests
├── unit/              # Unit tests for specific functions
│   ├── test_apply_metadata.sh
│   ├── test_common.sh
│   ├── test_framework.sh
│   └── test_secure_chmod.sh
├── lib/               # Test libraries and frameworks
│   ├── test-lib.sh
│   ├── test-logger.sh
│   └── test-config.sh
├── tools/             # Test utilities
│   └── test-improvements.sh
├── archive/           # Obsolete tests
└── results/           # Test results and logs
```

## Running Tests

### All Tests
```bash
bash tests/run-all-tests.sh
```

### Specific Categories
```bash
# Integration tests only
bash tests/test-runner.sh

# Unit tests only
for test in tests/unit/test_*.sh; do bash "$test"; done

# Safety checks
bash tests/01-safety-check.sh
```

## Test Categories

### Integration Tests (01-07)
- 01-safety-check.sh - Kernel safety validation
- 02-boot-test.sh - Boot sequence testing
- 03-functionality.sh - Core functionality
- 04-docker-smoke.sh - Docker build verification
- 05-consistency-check.sh - Configuration consistency
- 06-memory-guard.sh - Memory constraints
- 07-writer-experience.sh - User experience

### Unit Tests
- test_apply_metadata.sh - Metadata application
- test_common.sh - Common functions
- test_framework.sh - Test framework itself
- test_secure_chmod.sh - Permission security
EOF

# Summary
echo
log "═══════════════════════════════════════════════════════"
log "                CONSOLIDATION COMPLETE"
log "═══════════════════════════════════════════════════════"
echo
echo "📊 Summary:"
echo "  ✓ Backed up to: $BACKUP_DIR"
echo "  ✓ Unit tests moved to: tests/unit/"
echo "  ✓ Test tools moved to: tests/tools/"
echo "  ✓ Old directories removed"
echo ""
echo "📁 New Structure:"
echo "  tests/"
echo "  ├── unit/        (unit tests)"
echo "  ├── lib/         (test libraries)"
echo "  ├── tools/       (test utilities)"
echo "  ├── 01-07*.sh    (integration tests)"
echo "  └── archive/     (obsolete tests)"
echo ""
echo "🎯 Next Steps:"
echo "  1. Review: cat tests/TEST_INDEX.md"
echo "  2. Test: bash tests/run-all-tests.sh"
echo "  3. Commit: git add -A && git commit -m 'refactor: consolidate test directories'"

if [[ "$DRY_RUN" == "--dry-run" ]]; then
    echo
    warn "This was a DRY RUN. Run without --dry-run to execute changes."
fi