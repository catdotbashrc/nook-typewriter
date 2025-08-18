# Makefile for running script tests
# Integrates with main project Makefile

.PHONY: all test test-common test-apply test-secure test-verbose clean help

# Colors for output
GREEN := \033[0;32m
RED := \033[0;31m
YELLOW := \033[1;33m
NC := \033[0m

# Test configuration
TEST_DIR := $(shell pwd)
SCRIPTS_DIR := $(shell dirname $(TEST_DIR))

# Default target
all: test

# Run all tests
test:
	@echo "$(GREEN)Running all script tests...$(NC)"
	@bash $(TEST_DIR)/run_all_tests.sh

# Run specific test suites
test-common:
	@echo "$(GREEN)Testing lib/common.sh...$(NC)"
	@bash $(TEST_DIR)/test_common.sh

test-apply:
	@echo "$(GREEN)Testing apply_metadata.sh...$(NC)"
	@bash $(TEST_DIR)/test_apply_metadata.sh

test-secure:
	@echo "$(GREEN)Testing secure-chmod-replacements.sh...$(NC)"
	@bash $(TEST_DIR)/test_secure_chmod.sh

# Run tests with verbose output
test-verbose:
	@echo "$(GREEN)Running all tests (verbose)...$(NC)"
	@bash -x $(TEST_DIR)/run_all_tests.sh

# Run tests and generate coverage report (if available)
test-coverage:
	@echo "$(YELLOW)Coverage reporting not yet implemented$(NC)"
	@$(MAKE) test

# Clean test artifacts
clean:
	@echo "$(GREEN)Cleaning test artifacts...$(NC)"
	@rm -rf /tmp/nook-test.*
	@echo "$(GREEN)✓ Test artifacts cleaned$(NC)"

# Help target
help:
	@echo "Nook Scripts Test Suite"
	@echo "======================="
	@echo ""
	@echo "Available targets:"
	@echo "  make test          - Run all tests"
	@echo "  make test-common   - Test lib/common.sh only"
	@echo "  make test-apply    - Test apply_metadata.sh only"
	@echo "  make test-secure   - Test secure-chmod-replacements.sh only"
	@echo "  make test-verbose  - Run all tests with verbose output"
	@echo "  make clean         - Clean test artifacts"
	@echo "  make help          - Show this help message"
	@echo ""
	@echo "To run from project root:"
	@echo "  make -C scripts/test test"

# CI/CD integration target
ci-test: test
	@if [ $$? -eq 0 ]; then \
		echo "$(GREEN)✓ All tests passed - CI check successful$(NC)"; \
		exit 0; \
	else \
		echo "$(RED)✗ Tests failed - CI check failed$(NC)"; \
		exit 1; \
	fi