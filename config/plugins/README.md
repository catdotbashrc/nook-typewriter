# Nook Menu Plugin System

## Overview

The plugin system allows extending the Nook menu without modifying core scripts. Plugins are bash scripts that register menu items and handlers.

## Plugin Structure

Each plugin must:
1. Be a `.sh` file in `/usr/local/lib/nook-plugins/`
2. Define a menu item with `register_menu_item`
3. Provide a handler function

## Plugin API

### register_menu_item

Registers a new menu option.

```bash
register_menu_item "key" "label" "handler_function"
```

- `key`: Single character trigger (e.g., "x")
- `label`: Display text for menu
- `handler_function`: Function to call when selected

### Example Plugin

```bash
#!/bin/bash
# Plugin: Word of the Day
# File: /usr/local/lib/nook-plugins/word-of-day.sh

word_of_day_handler() {
    fbink -c || clear
    fbink -y 5 "WORD OF THE DAY" || echo "WORD OF THE DAY"
    fbink -y 7 "Serendipity" || echo "Serendipity"
    fbink -y 8 "Finding something good" || echo "Finding something good"
    fbink -y 9 "without looking for it" || echo "without looking for it"
    fbink -y 12 "Press any key..." || echo "Press any key..."
    read -n 1
}

# Register the menu item
register_menu_item "o" "[O] Word of the Day" "word_of_day_handler"
```

## Installation

1. Create plugin file in `/usr/local/lib/nook-plugins/`
2. Make it executable: `chmod +x plugin-name.sh`
3. Restart menu or reload

## Available Hooks

Plugins can hook into these events:

- `on_menu_start` - Called when menu launches
- `on_menu_exit` - Called before menu exits
- `on_vim_launch` - Called before Vim starts
- `on_vim_exit` - Called after Vim closes

## Environment Variables

Plugins have access to:

- `$NOOK_VERSION` - System version
- `$NOOK_WRITING_DIR` - Writing directory path
- `$NOOK_USER_HOME` - User home directory
- `$NOOK_PLUGIN_DIR` - Plugin directory path

## Best Practices

1. **Prefix functions**: Use plugin name prefix to avoid conflicts
2. **Check commands**: Verify commands exist before use
3. **Handle errors**: Provide fallbacks for missing dependencies
4. **Be minimal**: Respect RAM constraints
5. **Document well**: Include usage comments

## Included Plugins

### health-monitor.sh
Shows system health status (memory, disk, CPU).

### writing-stats.sh
Displays detailed writing statistics.

### backup-manager.sh
Quick backup to SD card or USB.

## Creating Your Own Plugin

1. Copy the template:
```bash
cp /usr/local/lib/nook-plugins/template.sh.example \
   /usr/local/lib/nook-plugins/my-plugin.sh
```

2. Edit the plugin:
```bash
vim /usr/local/lib/nook-plugins/my-plugin.sh
```

3. Test the plugin:
```bash
/usr/local/bin/nook-menu.sh
```

## Debugging

Enable debug mode:
```bash
export NOOK_DEBUG=1
/usr/local/bin/nook-menu.sh
```

This will show plugin loading messages and errors.

## Security

- Plugins run with user privileges
- No network access by default
- Sandboxed to plugin directory

## Contributing

Share your plugins at the XDA Forums Nook section!