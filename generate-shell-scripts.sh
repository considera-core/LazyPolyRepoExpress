#!/usr/bin/env bash
# ==============================================================================
# Generate shell script equivalents for all batch files
# This script creates .sh versions of .bat files for Linux/Mac compatibility
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Generating shell script equivalents for LazyPolyRepoExpress..."
echo "This will create .sh files alongside existing .bat files"
echo ""

# Counter for created files
created=0

# Function to create a basic shell script wrapper
create_shell_wrapper() {
    local bat_file="$1"
    local sh_file="${bat_file%.bat}.sh"
    local bat_name=$(basename "$bat_file" .bat)

    # Skip if .sh already exists
    if [ -f "$sh_file" ]; then
        echo "  [SKIP] $sh_file already exists"
        return
    fi

    # Create shell script
    cat > "$sh_file" << 'SHELL_SCRIPT_EOF'
#!/usr/bin/env bash
# Auto-generated shell script equivalent for Linux/Mac
# Original: %BAT_NAME%.bat

# TODO: Implement %BAT_NAME% functionality
# This is a placeholder - refer to the .bat file for logic

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[WARN] %BAT_NAME%.sh is not yet fully implemented"
echo "[INFO] Refer to %BAT_NAME%.bat for the expected behavior"

# Placeholder: pass through to show what would be executed
echo "[DEBUG] Would execute: %BAT_NAME% $@"

exit 0
SHELL_SCRIPT_EOF

    # Replace placeholders
    sed -i "s/%BAT_NAME%/$bat_name/g" "$sh_file"

    # Make executable
    chmod +x "$sh_file"

    echo "  [CREATE] $sh_file"
    ((created++))
}

# Find all .bat files and create .sh equivalents
echo "Scanning for .bat files..."
echo ""

while IFS= read -r -d '' bat_file; do
    # Skip if it's one of the files we already created manually
    bat_name=$(basename "$bat_file")
    case "$bat_name" in
        "sample-tenant.bat"|"TEMPLATE.bat"|"fn-dispatch.bat")
            echo "  [SKIP] $bat_file (already manually created)"
            ;;
        *)
            create_shell_wrapper "$bat_file"
            ;;
    esac
done < <(find "$SCRIPT_DIR" -name "*.bat" -print0)

echo ""
echo "=============================================="
echo "Generation complete!"
echo "Created $created shell script files"
echo ""
echo "NOTE: The generated .sh files are placeholders."
echo "You'll need to implement the logic by converting"
echo "batch file syntax to bash syntax for each file."
echo "=============================================="
