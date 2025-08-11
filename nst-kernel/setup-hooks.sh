#!/bin/bash
# Setup git hooks for QuillKernel development

echo "Setting up QuillKernel git hooks..."

# Configure git to use our hooks directory
git config core.hooksPath .githooks

echo "✓ Git hooks configured"
echo ""
echo "The following hooks are now active:"
echo "  - pre-commit: Runs static analysis and style checks"
echo ""
echo "To bypass hooks (not recommended): git commit --no-verify"
echo ""
echo "     .~\"~.~\"~."
echo "    /  o   o  \\    Git hooks installed!"
echo "   |  >  ◡  <  |   Your code quality"
echo "    \\  ___  /      shall be maintained!"
echo "     |~|♦|~|       "