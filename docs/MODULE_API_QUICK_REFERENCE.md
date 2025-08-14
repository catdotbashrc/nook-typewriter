# 🔌 QuillKernel Module API Quick Reference
### *Complete API Guide for SquireOS Kernel Modules*

---

## `/proc/squireos/` Interface Map

### Directory Structure
```
/proc/squireos/
├── jester              # ASCII art jester display
├── typewriter/
│   └── stats          # Writing statistics
├── wisdom             # Random writing quotes
└── motto              # System motto
```

---

## Core Module APIs

### squireos_core.c - Foundation Module

#### Initialization
```c
static int __init squireos_init(void)
```
- **Purpose**: Initialize /proc/squireos/ filesystem
- **Returns**: 0 on success, negative on error
- **Creates**: Base proc directory structure

#### Cleanup
```c
static void __exit squireos_exit(void)
```
- **Purpose**: Clean up proc entries on module unload
- **Side Effects**: Removes all /proc/squireos/ entries

#### Export Functions
```c
struct proc_dir_entry* get_squireos_proc_dir(void)
```
- **Purpose**: Get proc directory for other modules
- **Returns**: Pointer to /proc/squireos/ entry
- **Used By**: jester.c, typewriter.c, wisdom.c

---

## Jester Module API (jester.c)

### Data Structures
```c
enum jester_mood {
    MOOD_JOVIAL = 0,
    MOOD_CONTEMPLATIVE,
    MOOD_MISCHIEVOUS,
    MOOD_SLEEPY,
    MOOD_INSPIRED,
    MOOD_MAX
};

struct jester_state {
    enum jester_mood current_mood;
    unsigned long last_update;
    int interaction_count;
};
```

### Public Functions
```c
int jester_get_mood(void)
```
- **Returns**: Current mood enum value
- **Thread Safe**: Yes (uses spinlock)

```c
void jester_update_mood(int writing_activity)
```
- **Parameters**: 
  - `writing_activity`: Words written in last interval
- **Updates**: Mood based on writing patterns

```c
const char* jester_get_ascii(void)
```
- **Returns**: ASCII art for current mood
- **Size**: Max 1024 bytes

### Proc Interface
- **Read `/proc/squireos/jester`**: Display current ASCII art
- **Write `/proc/squireos/jester`**: Change mood (debug only)

---

## Typewriter Module API (typewriter.c)

### Data Structures
```c
struct writing_stats {
    u32 total_words;
    u32 total_keystrokes;
    u32 session_words;
    u32 session_keystrokes;
    u32 words_per_minute;
    time_t session_start;
    time_t last_activity;
};

struct writing_achievement {
    const char* name;
    const char* description;
    u32 threshold;
    bool unlocked;
};
```

### Public Functions
```c
void typewriter_update_stats(int words, int keystrokes)
```
- **Parameters**:
  - `words`: Number of words written
  - `keystrokes`: Number of keys pressed
- **Updates**: All statistics and checks achievements

```c
struct writing_stats* typewriter_get_stats(void)
```
- **Returns**: Pointer to current statistics
- **Thread Safe**: Yes (read-only snapshot)

```c
void typewriter_reset_session(void)
```
- **Purpose**: Reset session statistics
- **Preserves**: Total counts

```c
int typewriter_check_achievements(void)
```
- **Returns**: Number of new achievements unlocked
- **Side Effects**: Updates achievement states

### Proc Interface
- **Read `/proc/squireos/typewriter/stats`**: Get formatted statistics
- **Write `/proc/squireos/typewriter/stats`**: Reset session (write "reset")

### Statistics Format
```
Total Words: 5432
Total Keystrokes: 28651
Session Words: 234
Session Keystrokes: 1205
Words Per Minute: 42
Session Duration: 00:45:23
Last Activity: 2 minutes ago
```

---

## Wisdom Module API (wisdom.c)

### Data Structures
```c
struct wisdom_quote {
    const char* text;
    const char* author;
    enum quote_category category;
};

enum quote_category {
    QUOTE_INSPIRATION = 0,
    QUOTE_CRAFT,
    QUOTE_PERSEVERANCE,
    QUOTE_HUMOR,
    QUOTE_MEDIEVAL,
    QUOTE_MAX
};
```

### Public Functions
```c
const char* wisdom_get_random_quote(void)
```
- **Returns**: Random quote string
- **Format**: "Quote text" - Author

```c
const char* wisdom_get_category_quote(enum quote_category cat)
```
- **Parameters**:
  - `cat`: Quote category
- **Returns**: Random quote from category

```c
void wisdom_set_context(int writing_state)
```
- **Parameters**:
  - `writing_state`: Current writing context
- **Purpose**: Bias quote selection

### Proc Interface
- **Read `/proc/squireos/wisdom`**: Get random quote
- **Write `/proc/squireos/wisdom`**: Request specific category

---

## Module Interaction Patterns

### Mood System Integration
```c
// Typewriter updates jester mood based on activity
void on_writing_update(int words) {
    typewriter_update_stats(words, 0);
    if (words > 100) {
        jester_update_mood(MOOD_INSPIRED);
    }
}
```

### Achievement Celebrations
```c
// Jester celebrates achievements
int achievements = typewriter_check_achievements();
if (achievements > 0) {
    jester_update_mood(MOOD_JOVIAL);
    wisdom_set_context(CONTEXT_CELEBRATION);
}
```

---

## Memory Management

### Buffer Sizes
- **Jester ASCII**: 1024 bytes max
- **Stats Buffer**: 512 bytes
- **Quote Buffer**: 256 bytes
- **Proc Read Buffer**: PAGE_SIZE (4096)

### Allocation Patterns
```c
// Safe buffer allocation
char *buffer = kmalloc(BUFFER_SIZE, GFP_KERNEL);
if (!buffer)
    return -ENOMEM;

// Always use snprintf
snprintf(buffer, BUFFER_SIZE, format, args);

// Clean up
kfree(buffer);
```

---

## Error Handling

### Standard Return Codes
- `0`: Success
- `-ENOMEM`: Out of memory
- `-EINVAL`: Invalid parameter
- `-ENODEV`: Device not available
- `-EBUSY`: Resource busy

### Error Propagation
```c
int ret = module_function();
if (ret < 0) {
    pr_err("SquireOS: Operation failed: %d\n", ret);
    return ret;
}
```

---

## Debugging Support

### Debug Proc Entries
```bash
# Enable debug mode
echo "debug" > /proc/squireos/debug

# View module state
cat /proc/squireos/debug/state

# Force mood change
echo "jovial" > /proc/squireos/jester

# Dump statistics
cat /proc/squireos/typewriter/debug
```

### Kernel Log Messages
```c
// Message levels
pr_info("SquireOS: Module loaded\n");
pr_debug("SquireOS: Debug info: %d\n", value);
pr_err("SquireOS: Error occurred: %s\n", msg);
```

---

## Thread Safety

### Locking Mechanisms
```c
// Module-wide spinlock
static DEFINE_SPINLOCK(module_lock);

// Safe update pattern
spin_lock(&module_lock);
update_shared_data();
spin_unlock(&module_lock);

// Read with lock
spin_lock(&module_lock);
value = shared_data;
spin_unlock(&module_lock);
```

### Atomic Operations
```c
// Atomic counters
atomic_t interaction_count = ATOMIC_INIT(0);
atomic_inc(&interaction_count);
int count = atomic_read(&interaction_count);
```

---

## Module Parameters

### Configurable Options
```c
// Module load-time parameters
static int update_interval = 30;
module_param(update_interval, int, 0644);
MODULE_PARM_DESC(update_interval, "Update interval in seconds");

// Usage: insmod jester.ko update_interval=60
```

---

## Performance Considerations

### Optimization Guidelines
1. **Minimize proc reads**: Cache frequently accessed data
2. **Batch updates**: Group statistics updates
3. **Avoid blocking**: Use non-blocking I/O where possible
4. **Memory efficiency**: Reuse buffers when safe

### Benchmarks
- Proc read latency: <1ms
- Mood update: <100μs
- Stats calculation: <50μs
- Quote selection: <10μs

---

## Testing the APIs

### Basic Functionality Test
```bash
#!/bin/bash
# Test all module interfaces

# Check modules loaded
lsmod | grep squireos

# Test jester
cat /proc/squireos/jester

# Test statistics  
cat /proc/squireos/typewriter/stats

# Test wisdom
cat /proc/squireos/wisdom

# Verify mood changes
echo "test" > /tmp/test.txt
cat /proc/squireos/jester  # Should show activity
```

### Stress Testing
```bash
# High-frequency updates
for i in {1..1000}; do
    echo "word" >> /tmp/test.txt
done

# Check stats didn't overflow
cat /proc/squireos/typewriter/stats
```

---

*"Code with quill, compile with wisdom!"* 📜✨

**Module Version**: 1.0.0 | **Kernel**: 2.6.29 | **Last Updated**: August 2025