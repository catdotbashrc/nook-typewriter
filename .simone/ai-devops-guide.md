# 🤖 AI Development Operations Guide

## Context Management Strategy

### Optimal Context Windows
- **Discovery Phase**: 50K tokens (understanding codebase)
- **Implementation Phase**: 30K tokens (focused development)
- **Refinement Phase**: 20K tokens (targeted improvements)
- **Documentation Phase**: 15K tokens (clear explanations)

### Context Preservation Techniques
```yaml
always_include:
  - .simone/constitution.md
  - .simone/project.yaml
  - CLAUDE.md
  - Current issue/PR description
  
rotate_as_needed:
  - Related issue discussions
  - Test results
  - Performance metrics
  - Recent commits
```

## Token Economics

### Token Budget Allocation
```yaml
task_types:
  research:
    discovery: 40%
    analysis: 30%
    documentation: 30%
  
  implementation:
    planning: 20%
    coding: 50%
    testing: 20%
    refinement: 10%
  
  debugging:
    investigation: 60%
    fix_implementation: 25%
    validation: 15%
```

### Token Efficiency Metrics
- **Code Generation Rate**: 50-100 lines per 1K tokens
- **Documentation Rate**: 200-300 words per 1K tokens
- **Test Coverage Rate**: 1 test per 500 tokens of implementation
- **Refactor Efficiency**: 30% token reduction on second pass

## AI-Optimized Issue Templates

### Feature Request Template
```markdown
## Feature: [Name]

### Token Budget
- Research: [X]K tokens
- Implementation: [Y]K tokens
- Testing: [Z]K tokens

### Context Requirements
- Key files: [List critical files]
- Dependencies: [Required knowledge]
- Constraints: [Memory/performance limits]

### Success Metrics
- [ ] Passes all tests
- [ ] Stays within memory budget
- [ ] Follows conventions
- [ ] Has documentation

### AI Implementation Notes
- Preferred patterns: [Reference similar code]
- Avoid: [Known problematic approaches]
- Session estimate: [Number of AI sessions]
```

### Bug Report Template
```markdown
## Bug: [Description]

### Investigation Budget
- Max tokens: [X]K for investigation
- Fix tokens: [Y]K for implementation

### Context Clues
- Working in: [Last known good commit]
- Broken in: [First bad commit]
- Affected files: [Likely locations]

### AI Debugging Strategy
1. [First investigation approach]
2. [Fallback approach]
3. [Nuclear option]
```

## Session Management

### Session Handoff Template
```markdown
## Session [N] Summary - [ISO Date]

### Completed (✅)
- Task: [Description] - [Files modified]
- Token usage: [X]K / [Budget]K

### In Progress (🔄)
- Current task: [Description]
- Progress: [Percentage]
- Next step: [Specific action]

### Blocked (🚫)
- Issue: [Description]
- Needs: [Human decision/input]

### Context Cache
```yaml
critical_files:
  - path/to/file1  # Why it's important
  - path/to/file2  # Why it's important

key_decisions:
  - Decision: [Rationale]
  
established_patterns:
  - Pattern: [Where used]
```
```

### Session Planning
```yaml
session_types:
  exploration:
    duration: "High token budget"
    goals: "Understand system"
    outputs: "Documentation, notes"
  
  implementation:
    duration: "Medium token budget"
    goals: "Build specific feature"
    outputs: "Code, tests"
  
  refinement:
    duration: "Low token budget"
    goals: "Polish, optimize"
    outputs: "Improved code"
  
  firefighting:
    duration: "Variable token budget"
    goals: "Fix critical issue"
    outputs: "Working system"
```

## Code Generation Best Practices

### Incremental Development Strategy
```yaml
phase_1_skeleton:
  tokens: 5K
  goal: "Basic structure, interfaces"
  validation: "Compiles/parses"

phase_2_implementation:
  tokens: 15K
  goal: "Core functionality"
  validation: "Basic tests pass"

phase_3_edge_cases:
  tokens: 10K
  goal: "Error handling, edge cases"
  validation: "All tests pass"

phase_4_optimization:
  tokens: 5K
  goal: "Performance, cleanup"
  validation: "Benchmarks pass"
```

### Pattern Library References
```yaml
patterns:
  menu_system:
    reference: "source/scripts/menu/nook-menu.sh"
    use_for: "Any menu creation"
  
  kernel_module:
    reference: "source/kernel/src/drivers/jokeros/jester.c"
    use_for: "New kernel modules"
  
  error_handling:
    reference: "source/scripts/lib/common.sh"
    use_for: "Shell script safety"
  
  vim_config:
    reference: "source/configs/vim/vimrc"
    use_for: "Vim customization"
```

## Testing Strategy

### AI Test Generation Rules
```yaml
test_requirements:
  coverage_target: 80%
  test_types:
    - unit: "Individual functions"
    - integration: "Component interaction"
    - edge_case: "Boundary conditions"
    - error: "Failure scenarios"
  
  test_structure:
    arrange: "Set up test conditions"
    act: "Execute functionality"
    assert: "Verify results"
    cleanup: "Reset state"
```

### Validation Checklist
```markdown
## Pre-Commit Validation
- [ ] Code follows project style
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Memory budget checked
- [ ] No medieval theme (except where required)
- [ ] Error handling present
- [ ] Performance acceptable
```

## Performance Monitoring

### AI Development Metrics
```yaml
tracking:
  per_session:
    tokens_used: "Actual vs budget"
    lines_of_code: "Generated/modified"
    test_coverage: "New coverage added"
    documentation: "Words added"
    errors_fixed: "Bugs resolved"
  
  per_feature:
    total_tokens: "Sum across sessions"
    calendar_time: "Start to finish"
    iterations: "Refinement cycles"
    quality_score: "Tests, docs, style"
  
  per_sprint:
    velocity: "Features completed"
    token_efficiency: "Tokens per feature"
    bug_rate: "Bugs per KLOC"
    documentation_ratio: "Docs per code"
```

## Commit Message Convention

### AI Commit Format
```
[AI-SESSION-{N}] {type}: {description}

Token Usage: {used}K/{budget}K
Session Type: {explore|implement|refine|fix}
Confidence: {high|medium|low}

Changes:
- {Human readable change summary}
- {File group}: {what changed}

Context Preserved:
- {Key decision or pattern}

Next Session Needs:
- {Critical context item}

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code improvement
- `docs`: Documentation only
- `test`: Test addition/improvement
- `perf`: Performance improvement
- `style`: Code style/formatting

## GitHub Integration

### AI-Friendly Labels
```yaml
labels:
  # Complexity
  ai-simple: "< 10K tokens"
  ai-medium: "10-50K tokens"
  ai-complex: "> 50K tokens"
  
  # Status
  ai-ready: "Has all context needed"
  ai-blocked: "Needs human input"
  ai-in-progress: "AI currently working"
  
  # Type
  ai-research: "Investigation needed"
  ai-generation: "Code creation"
  ai-refinement: "Improvement pass"
```

### Milestone Token Budgets
```yaml
milestones:
  MVP:
    token_budget: 200K
    sessions_estimate: 10-15
    parallel_tracks: 2-3
  
  v1.0:
    token_budget: 300K
    sessions_estimate: 15-20
    parallel_tracks: 3-4
  
  v2.0:
    token_budget: 150K
    sessions_estimate: 8-10
    parallel_tracks: 2
```

## Automation Opportunities

### GitHub Actions for AI
```yaml
ai_workflows:
  context_preparation:
    trigger: "Issue labeled 'ai-ready'"
    action: "Generate context bundle"
    output: "Context cache file"
  
  session_tracking:
    trigger: "AI commit pushed"
    action: "Update token metrics"
    output: "Updated dashboard"
  
  quality_gates:
    trigger: "PR from ai/* branch"
    action: "Run AI-specific checks"
    output: "Validation report"
```

## Error Recovery

### When AI Gets Stuck
```yaml
recovery_strategies:
  context_overflow:
    solution: "Split into smaller tasks"
    prevention: "Better task decomposition"
  
  convention_violation:
    solution: "Reference pattern library"
    prevention: "Include examples in prompt"
  
  performance_regression:
    solution: "Revert and refactor"
    prevention: "Benchmark in prompt"
  
  test_failure:
    solution: "Add test context"
    prevention: "Test-first development"
```

## Knowledge Base

### Project-Specific AI Knowledge
```yaml
gotchas:
  - "E-Ink displays need manual refresh"
  - "Memory budget is HARD limit"
  - "Medieval theme is being removed"
  - "Vim must start in < 2 seconds"
  - "Kernel modules use 2.6.29 API"

conventions:
  - "Shell scripts use common.sh"
  - "ASCII art in source/configs/ascii/"
  - "Tests go in tests/unit/"
  - "Documentation uses comedy tone"

constraints:
  - "Total OS: < 96MB"
  - "UI system: < 2MB"
  - "Per module: < 500KB"
  - "Boot time: < 20 seconds"
```

---

*This guide helps AI assistants work efficiently with the Nook Typewriter project*