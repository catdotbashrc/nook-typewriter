#!/bin/bash
# phase2-migrate-paths.sh - Replace hardcoded paths with configuration variables
# Part of Phase 2 consolidation effort

set -euo pipefail

echo "========================================="
echo "  Phase 2: Path Migration Tool"
echo "========================================="
echo ""

# Backup directory
BACKUP_DIR="backups/phase2-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Common path replacements
declare -A PATH_REPLACEMENTS=(
    ["/usr/local/bin/jester-daemon"]='$JESTER_DAEMON'
    ["/src/services/system/common.sh"]='$COMMON_LIB/common.sh'
    ["/src/hal/power/battery-monitor.sh"]='$BATTERY_MONITOR'
    ["/src/hal/power/power-optimizer.sh"]='$POWER_OPTIMIZER'
    ["/src/hal/sensors/temperature-monitor.sh"]='$TEMP_MONITOR'
    ["/var/jesteros"]='$JESTEROS_VAR'
    ["/var/log/jesteros"]='$JESTEROS_LOG'
    ["/tmp/jesteros"]='$JESTEROS_TMP'
    ["/src/services/1-ui"]='$LAYER1_UI'
    ["/src/services/2-application"]='$LAYER2_APP'
    ["/src/services/3-system"]='$LAYER3_SYSTEM'
    ["/src/services/4-hardware"]='$LAYER4_HARDWARE'
    ["/data/jesteros"]='$JESTEROS_VAR'
    ["/root/notes"]='$NOTES_DIR'
    ["/root/drafts"]='$DRAFTS_DIR'
)

# Files to update
FILES_TO_UPDATE=(
    runtime/**/*.sh
    runtime/config/*.conf
)

echo "Scanning for hardcoded paths..."
TOTAL_REPLACEMENTS=0

for pattern in "${FILES_TO_UPDATE[@]}"; do
    for file in $pattern; do
        if [ -f "$file" ]; then
            # Skip binary files and our own config
            if file "$file" | grep -q "text" && [ "$file" != "src/services/config/jesteros.conf" ]; then
                echo -n "Checking $(basename $file)... "
                
                # Count replacements needed
                replacements=0
                for hardcoded in "${!PATH_REPLACEMENTS[@]}"; do
                    count=$(grep -F "$hardcoded" "$file" 2>/dev/null | wc -l || echo 0)
                    replacements=$((replacements + count))
                done
                
                if [ $replacements -gt 0 ]; then
                    echo "$replacements paths to fix"
                    
                    # Backup original
                    cp "$file" "$BACKUP_DIR/$(basename $file).bak"
                    
                    # Create temp file
                    temp_file=$(mktemp)
                    cp "$file" "$temp_file"
                    
                    # Apply replacements
                    for hardcoded in "${!PATH_REPLACEMENTS[@]}"; do
                        variable="${PATH_REPLACEMENTS[$hardcoded]}"
                        # Use sed to replace, escaping special characters
                        escaped_hard=$(echo "$hardcoded" | sed 's/[[\.*^$()+?{|]/\\&/g')
                        sed -i "s|$escaped_hard|$variable|g" "$temp_file"
                    done
                    
                    # Add config sourcing if not present
                    if ! grep -q "jesteros.conf" "$temp_file"; then
                        # Add after shebang and comments
                        awk '
                        /^#!/ { print; printed=1; next }
                        /^#/ && printed { print; next }
                        !printed_source && printed { 
                            print "# Source JesterOS configuration"
                            print "JESTEROS_CONFIG=\"${JESTEROS_CONFIG:-/src/services/config/jesteros.conf}\""
                            print "[ -f \"$JESTEROS_CONFIG\" ] && source \"$JESTEROS_CONFIG\""
                            print ""
                            printed_source=1
                        }
                        { print }
                        ' "$temp_file" > "$temp_file.new"
                        mv "$temp_file.new" "$temp_file"
                    fi
                    
                    # Replace original
                    mv "$temp_file" "$file"
                    
                    TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + replacements))
                else
                    echo "OK"
                fi
            fi
        fi
    done
done

echo ""
echo "========================================="
echo "  Migration Summary"
echo "========================================="
echo "Total paths replaced: $TOTAL_REPLACEMENTS"
echo "Backups saved to: $BACKUP_DIR"
echo ""

# Create a validation script
cat > "$BACKUP_DIR/validate.sh" << 'EOF'
#!/bin/bash
# Validate path migration

echo "Validating path migration..."

# Source config
source /src/services/config/jesteros.conf

# Check for remaining hardcoded paths
echo "Checking for remaining hardcoded paths..."
grep -r "/usr/local/bin\|/var/jesteros\|/src/services/[1-4]" runtime/**/*.sh 2>/dev/null | \
    grep -v "JESTEROS\|LAYER\|CONFIG" | \
    grep -v "^#" | head -20

echo "Done!"
EOF

chmod +x "$BACKUP_DIR/validate.sh"

echo "Run $BACKUP_DIR/validate.sh to check for remaining hardcoded paths"
echo ""

if [ $TOTAL_REPLACEMENTS -gt 0 ]; then
    echo "✅ Successfully migrated $TOTAL_REPLACEMENTS hardcoded paths!"
else
    echo "✅ No hardcoded paths found - system already clean!"
fi