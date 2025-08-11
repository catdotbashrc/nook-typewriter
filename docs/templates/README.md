# Diataxis Documentation Templates

## Overview

These templates implement the [Diataxis framework](https://diataxis.fr/) for technical documentation. Diataxis organizes documentation into four distinct types, each serving a specific user need:

```
        Practical Steps                    Theoretical Knowledge
              ↑                                      ↑
    ┌─────────┴──────────┐                ┌────────┴──────────┐
    │                    │                │                   │
    │    TUTORIALS       │                │   EXPLANATION     │
    │  (Learning-        │                │ (Understanding-   │
    │   Oriented)        │                │   Oriented)       │
    │                    │                │                   │
Study →──────────────────┼────────────────┼──────────────────→ Work
    │                    │                │                   │
    │    HOW-TO          │                │   REFERENCE       │
    │    GUIDES          │                │  (Information-    │
    │  (Goal-Oriented)   │                │   Oriented)       │
    │                    │                │                   │
    └────────────────────┘                └───────────────────┘
              ↓                                      ↓
        Practical Steps                    Theoretical Knowledge
```

## Template Files

### 📚 Tutorial Template
**File:** `diataxis-tutorial.md`  
**Purpose:** Help beginners learn by doing  
**When to use:** 
- Onboarding new users
- Teaching new concepts through practice
- Building confidence with hands-on experience

**Key characteristics:**
- Step-by-step instructions
- Concrete examples that build on each other
- Clear learning outcomes
- Encouragement and support

### 🎯 How-To Guide Template
**File:** `diataxis-how-to.md`  
**Purpose:** Help users accomplish specific tasks  
**When to use:**
- Documenting common workflows
- Providing solutions to specific problems
- Showing different ways to achieve a goal

**Key characteristics:**
- Goal-oriented structure
- Minimal explanation
- Multiple approaches when applicable
- Troubleshooting section

### 🧠 Explanation Template
**File:** `diataxis-explanation.md`  
**Purpose:** Provide understanding and context  
**When to use:**
- Explaining design decisions
- Discussing concepts and theory
- Comparing alternatives
- Providing background knowledge

**Key characteristics:**
- Conceptual focus
- Discussion of tradeoffs
- Historical context
- Mental models and analogies

### 📖 Reference Template
**File:** `diataxis-reference.md`  
**Purpose:** Provide complete technical information  
**When to use:**
- API documentation
- Configuration options
- Command-line interfaces
- Data structures and schemas

**Key characteristics:**
- Comprehensive coverage
- Consistent structure
- Easy to scan
- Accurate and up-to-date

## How to Use These Templates

### Step 1: Choose the Right Template

Ask yourself:
- **Is the user learning?** → Use Tutorial
- **Is the user doing?** → Use How-To Guide  
- **Is the user understanding?** → Use Explanation
- **Is the user looking up?** → Use Reference

### Step 2: Copy the Template

```bash
# For a new tutorial
cp docs/templates/diataxis-tutorial.md docs/tutorials/my-feature-tutorial.md

# For a new how-to guide
cp docs/templates/diataxis-how-to.md docs/how-to/accomplish-task.md

# For a new explanation
cp docs/templates/diataxis-explanation.md docs/explanations/understanding-concept.md

# For a new reference
cp docs/templates/diataxis-reference.md docs/reference/component-reference.md
```

### Step 3: Fill in the Template

1. **Replace placeholders** marked with `[brackets]`
2. **Remove optional sections** that don't apply
3. **Maintain the structure** - it helps readers navigate
4. **Keep the metadata** at the bottom for maintenance

### Step 4: Organize Your Documentation

Recommended directory structure:
```
docs/
├── templates/          # These templates
│   ├── README.md
│   ├── diataxis-tutorial.md
│   ├── diataxis-how-to.md
│   ├── diataxis-explanation.md
│   └── diataxis-reference.md
├── tutorials/          # Learning-oriented guides
│   ├── getting-started.md
│   └── first-project.md
├── how-to/            # Task-oriented guides
│   ├── install.md
│   ├── configure.md
│   └── deploy.md
├── explanations/      # Understanding-oriented guides
│   ├── architecture.md
│   └── design-decisions.md
├── reference/         # Information-oriented guides
│   ├── api.md
│   ├── cli.md
│   └── configuration.md
└── index.md           # Documentation home
```

## Using with `/sc:document` Command

These templates are designed to work with the `/sc:document` command:

```bash
# Generate tutorial documentation
/sc:document my-feature --type guide --template tutorials/getting-started

# Generate how-to documentation
/sc:document setup-process --type guide --template how-to/setup

# Generate explanation documentation
/sc:document architecture --type external --template explanations/system-design

# Generate reference documentation
/sc:document api/endpoints --type api --template reference/api
```

## Best Practices

### Do's ✅
- **Keep types separate** - Don't mix tutorial steps with reference information
- **Cross-reference** - Link between different documentation types
- **Be consistent** - Use the same structure within each type
- **Update regularly** - Keep examples and references current
- **Test everything** - Ensure code examples work

### Don'ts ❌
- **Don't explain in how-to guides** - Save explanations for explanation docs
- **Don't make tutorials goal-oriented** - Focus on learning, not outcomes
- **Don't make reference docs narrative** - Keep them scannable
- **Don't mix audiences** - Each type serves different needs

## Template Customization

### Adding Project-Specific Sections

You can extend templates with project-specific sections:

```markdown
## Project-Specific Section
<!-- Add after the main template content -->

### [Your Custom Content]
[Project-specific information]
```

### Creating Variations

Create specialized versions for your project:

```bash
# Create a specialized tutorial template
cp diataxis-tutorial.md api-tutorial-template.md
# Customize for API tutorials specifically

# Create a specialized reference template  
cp diataxis-reference.md cli-reference-template.md
# Customize for CLI documentation specifically
```

## Examples in This Project

Here are examples of each type in the Nook project:

- **Tutorial:** [First Nook Setup](../tutorials/01-first-nook-setup.md)
- **How-To:** [Setup Wireless Keyboard](../how-to/setup-wireless-keyboard.md)
- **Explanation:** [Architecture Overview](../explanation/architecture-overview.md)
- **Reference:** [Keyboard Shortcuts](../reference/keyboard-shortcuts.md)

## Quick Decision Tree

```
Start Here
    ↓
Is the reader trying to learn something new?
    Yes → TUTORIAL
    No ↓
    
Is the reader trying to accomplish a task?
    Yes → HOW-TO GUIDE
    No ↓
    
Is the reader trying to understand something?
    Yes → EXPLANATION
    No ↓
    
Is the reader looking up specific information?
    Yes → REFERENCE
    No → Consider if documentation is needed
```

## Resources

- [Diataxis Framework](https://diataxis.fr/) - Official framework documentation
- [Documentation System](https://documentation.divio.com/) - Original conception
- [Write the Docs Guide](https://www.writethedocs.org/guide/docs-as-code/) - Documentation best practices

## Contributing

When contributing documentation:

1. Use the appropriate template
2. Follow the structure consistently
3. Test all code examples
4. Update the index when adding new docs
5. Cross-reference related documentation

---

*These templates are maintained as part of the project documentation standards. Last updated: 2024*