# How to [Accomplish Specific Goal]
<!-- TEMPLATE: Diataxis How-To Guide
     Purpose: Help users accomplish a specific task
     Focus: Practical steps to achieve a goal
     Audience: Users who know what they want to do -->

## Goal

<!-- One sentence describing what will be accomplished -->
This guide shows you how to [specific, actionable goal].

## Before You Begin

<!-- Prerequisites and context -->
**Requirements:**
- [ ] [Required tool/access/permission]
- [ ] [Required knowledge/skill]
- [ ] [Required configuration/setup]

**When to use this approach:**
- ✅ When you need to [scenario 1]
- ✅ When [condition] is true
- ❌ Don't use this when [exception case]

## Steps

### 1. [Prepare/Check/Verify Something]

<!-- Direct, imperative instructions -->
First, ensure that [condition is met]:

```bash
# Check current state
command --check
```

Expected output:
```
[What you should see if ready]
```

<!-- Only essential context -->
> **Note:** If you see [different output], see [Troubleshooting](#troubleshooting).

### 2. [Main Action Step]

[Do the primary action]:

```bash
# Execute main task
command --option value
```

<!-- Alternative approaches if applicable -->
<details>
<summary>Alternative method (click to expand)</summary>

If you prefer/need to use [alternative]:

```bash
# Alternative approach
alternative-command
```

This method is useful when [specific condition].
</details>

### 3. [Configure/Customize]

Adjust the configuration for your needs:

```yaml
# config.yml
setting1: value1  # Required
setting2: value2  # Optional: for [purpose]
setting3: value3  # Optional: enables [feature]
```

<!-- Common configurations -->
**Common configurations:**

| Use Case | Setting1 | Setting2 | Setting3 |
|----------|----------|----------|----------|
| Development | `dev` | `true` | `debug` |
| Production | `prod` | `false` | `info` |
| Testing | `test` | `true` | `verbose` |

### 4. [Verify Success]

Confirm the task completed successfully:

```bash
# Verify the result
verify-command
```

You should see:
```
✓ [Success indicator 1]
✓ [Success indicator 2]
```

## Complete Example

<!-- Full, working example combining all steps -->
Here's the complete process from start to finish:

```bash
# 1. Prepare
command --check

# 2. Execute
command --option value

# 3. Configure
echo "setting: value" > config.yml

# 4. Verify
verify-command
```

## Variations

<!-- Different approaches for different situations -->
### For [Specific Scenario]

When [condition], modify step 2:

```bash
command --option different-value --extra-flag
```

### For [Another Scenario]

If you need [different outcome]:

1. Skip step 2
2. Instead, do [alternative action]
3. Continue with step 3

## Troubleshooting

<!-- Common problems and solutions -->
### Problem: [Error message or symptom]

**Cause:** [What causes this]

**Solution:**
```bash
# Fix command
fix-command --option
```

### Problem: [Another common issue]

**Cause:** [What causes this]

**Solution:**
1. Check [specific thing]
2. Ensure [condition]
3. Retry with [modification]

## Quick Reference

<!-- Command summary for experienced users -->
```bash
# Minimal working example
command --check && \
command --option value && \
verify-command
```

**Key options:**
- `--option`: [What it does]
- `--flag`: [What it enables]
- `--value X`: [What it sets]

## Related Guides

<!-- Links to related how-to guides -->
- [How to [Related Task 1]](./related-task-1.md)
- [How to [Related Task 2]](./related-task-2.md)
- [How to Troubleshoot [Feature]](./troubleshooting.md)

## See Also

<!-- Links to other documentation types -->
- **Understand:** [Explanation of [Concept]](../explanations/concept.md)
- **Learn:** [Tutorial: Getting Started with [Feature]](../tutorials/getting-started.md)
- **Reference:** [Complete [Feature] Reference](../reference/feature.md)

---

<!-- Metadata for template -->
<!-- 
Template: Diataxis How-To Guide
Last Updated: [Date]
Typical Length: 4-7 steps
Key Principles:
- Goal-oriented
- Flexible for different situations
- Minimal explanation
- Complete and correct
-->