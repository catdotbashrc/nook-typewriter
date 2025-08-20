#!/bin/sh
# Load SquireOS modules in correct order

MODULE_DIR="/lib/modules/2.6.29"

echo "Loading SquireOS modules..."

# Load core first
if [ -f "$MODULE_DIR/squireos_core.ko" ]; then
    insmod "$MODULE_DIR/squireos_core.ko"
    echo "Loaded squireos_core"
fi

# Load feature modules
for mod in jester typewriter wisdom; do
    if [ -f "$MODULE_DIR/${mod}.ko" ]; then
        insmod "$MODULE_DIR/${mod}.ko"
        echo "Loaded ${mod}"
    fi
done

# Check if modules loaded
if [ -d /proc/squireos ]; then
    echo "SquireOS modules loaded successfully!"
    ls /proc/squireos/
else
    echo "Failed to load SquireOS modules"
fi
