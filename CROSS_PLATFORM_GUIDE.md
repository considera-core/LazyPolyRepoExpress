# LazyPolyRepoExpress Cross-Platform Support

## Overview

LazyPolyRepoExpress now includes shell script (`.sh`) equivalents for all batch files (`.bat`), enabling Linux and macOS users to use the same powerful multi-repo management tools.

## Quick Start

### Windows
```batch
REM Use .bat files as before
sample-tenant git pull admin
```

### Linux/macOS
```bash
# Use .sh files instead
./sample-tenant.sh git pull admin
```

## Installation

### Prerequisites

**Linux/macOS:**
- Bash 4.0+
- Git
- Node.js and npm (for npm commands)
- Your IDE of choice (VS Code, WebStorm, Rider, etc.)

**Windows:**
- All existing requirements remain the same

### Setup

1. **Clone/Navigate to LazyPolyRepoExpress**:
   ```bash
   cd /path/to/LazyPolyRepoExpress
   ```

2. **Make Scripts Executable** (Linux/macOS only):
   ```bash
   find . -name "*.sh" -exec chmod +x {} \;
   ```

3. **Add to PATH** (optional but recommended):
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export PATH="/path/to/LazyPolyRepoExpress/tenants/dispatch:$PATH"

   # Source the file
   source ~/.bashrc  # or ~/.zshrc
   ```

4. **Create Symlinks** (optional, for easier access):
   ```bash
   # Instead of typing ./sample-tenant.sh, just type sample-tenant
   cd /usr/local/bin
   sudo ln -s /path/to/LazyPolyRepoExpress/tenants/dispatch/sample-tenant.sh sample-tenant
   ```

## Usage

### Basic Commands

All commands follow the same pattern as Windows, just use `.sh` extension:

```bash
# Git operations
./sample-tenant.sh git branch admin
./sample-tenant.sh git branches admin
./sample-tenant.sh git pull
./sample-tenant.sh git pull admin
./sample-tenant.sh git home
./sample-tenant.sh git story admin EV-4235

# App operations
./sample-tenant.sh app launch admin
./sample-tenant.sh app validate

# IDE operations
./sample-tenant.sh ide code admin
./sample-tenant.sh ide webstorm admin

# NPM operations
./sample-tenant.sh npm admin install
./sample-tenant.sh npm audit fix

# NPX operations
./sample-tenant.sh npx admin knip
```

### Path Differences

**Windows Paths:**
```
C:\Users\Public\SampleTenant\Sources
```

**Linux/macOS Paths:**
```
/Users/Public/SampleTenant/Sources  # macOS
/home/user/SampleTenant/Sources     # Linux
```

Update your `tenants/data/tenants.csv` accordingly:
```csv
alias,display,root
sample-tenant,SampleTenant,/Users/Public/SampleTenant/Sources
```

## Configuration

### CSV Files

CSV files work identically across platforms. Just use forward slashes (`/`) for paths:

**tenants.csv:**
```csv
alias,display,root
sample-tenant,SampleTenant,/path/to/tenant/sources
```

**sample-tenant.csv:**
```csv
alias,name,label,type,client,server,home
admin,my-admin,Admin,bff,my-admin/client,my-admin,main
api,my-api,Api,api,,my-api,master
```

## Implementation Status

### ✅ Fully Implemented

- `sample-tenant.sh` - Tenant dispatcher
- `TEMPLATE.sh` - Template for new tenants
- `fn-dispatch.sh` - Main command router
- `fn-bootstrap.sh` - Configuration loader

### 🟡 Placeholder (Basic Stub)

Most module-specific scripts are generated as placeholders. They currently:
- Echo a warning that they're not yet fully implemented
- Show what command would be executed
- Return success (exit 0)

**Placeholder scripts include:**
- Git modules: `fn-git-pull.sh`, `fn-git-branch.sh`, etc.
- IDE modules: `fn-ide-code.sh`, `fn-ide-rider.sh`, etc.
- NPM modules: `fn-npm.sh`, `fn-npx.sh`
- App modules: `fn-app-launch.sh`, `fn-app-run.sh`
- Utility modules: Various helpers

### 📝 Contributing Implementations

To implement a placeholder script:

1. Open the `.sh` file
2. Replace the TODO section with actual implementation
3. Convert batch syntax to bash:
   - `IF ERRORLEVEL` → `if [ $? -ne 0 ]`
   - `SET VAR=value` → `VAR="value"`
   - `%VAR%` → `$VAR`
   - `CALL` → `./script.sh` or `source script.sh`
   - `FOR /F` → `while read` or `for` loops
4. Test thoroughly
5. Update this status section

## Key Differences: Batch vs Bash

### Variables

**Batch:**
```batch
SET "var=value"
ECHO %var%
SET "path=%CD%\subdir"
```

**Bash:**
```bash
var="value"
echo "$var"
path="$(pwd)/subdir"
```

### Conditionals

**Batch:**
```batch
IF "%var%"=="value" (
    ECHO Match
) ELSE (
    ECHO No match
)

IF ERRORLEVEL 1 (
    ECHO Error occurred
)
```

**Bash:**
```bash
if [ "$var" = "value" ]; then
    echo "Match"
else
    echo "No match"
fi

if [ $? -ne 0 ]; then
    echo "Error occurred"
fi
```

### Loops

**Batch (CSV parsing):**
```batch
FOR /F "tokens=1-3 delims=," %%A IN (file.csv) DO (
    SET "col1=%%A"
    SET "col2=%%B"
    SET "col3=%%C"
)
```

**Bash (CSV parsing):**
```bash
while IFS=, read -r col1 col2 col3; do
    # Process columns
done < file.csv
```

### Script Directory

**Batch:**
```batch
SET "SCRIPT_DIR=%~dp0"
```

**Bash:**
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

## IDE-Specific Considerations

### Visual Studio Code

**Windows:**
```batch
code "C:\path\to\project"
```

**Linux/macOS:**
```bash
code "/path/to/project"
```

### JetBrains (Rider, WebStorm)

**Windows:**
```batch
rider "C:\path\to\project.sln"
```

**macOS:**
```bash
open -na "Rider.app" --args "/path/to/project.sln"
```

**Linux:**
```bash
rider "/path/to/project.sln"
```

### Opening New Terminal Windows

**Windows (cmd):**
```batch
start cmd /k "cd /d path && npm start"
```

**macOS:**
```bash
osascript -e 'tell app "Terminal" to do script "cd /path && npm start"'
```

**Linux (gnome-terminal):**
```bash
gnome-terminal -- bash -c "cd /path && npm start; exec bash"
```

## PolyRepoExpress UI Compatibility

The PolyRepoExpress UI (Angular + .NET API) works with shell scripts:

### Backend Configuration

Update `appsettings.json`:

```json
{
  "CommandExecution": {
    "ShellExecutable": "/bin/bash",  // Changed from cmd.exe
    "WorkingDirectory": "/path/to/LazyPolyRepoExpress"
  }
}
```

### Command Execution

The backend will automatically use `.sh` files:

**Windows:**
```
cmd.exe /c "sample-tenant.bat git pull admin"
```

**Linux/macOS:**
```
/bin/bash -c "sample-tenant.sh git pull admin"
```

## Environment Variables

### Windows
```batch
SET LPRE_REPO_PATH=C:\path\to\LazyPolyRepoExpress
```

### Linux/macOS
```bash
export LPRE_REPO_PATH="/path/to/LazyPolyRepoExpress"
```

Add to `~/.bashrc` or `~/.zshrc` for persistence.

## Troubleshooting

### Permission Denied

```bash
# Make scripts executable
chmod +x /path/to/script.sh
```

### Bad Interpreter

If you see `bad interpreter: /bin/bash^M`:

```bash
# Remove Windows line endings
dos2unix script.sh

# Or use sed
sed -i 's/\r$//' script.sh
```

### Script Not Found

```bash
# Use full path
/path/to/LazyPolyRepoExpress/tenants/dispatch/sample-tenant.sh git pull

# Or add to PATH
export PATH="/path/to/LazyPolyRepoExpress/tenants/dispatch:$PATH"
```

### CSV Parsing Issues

Ensure CSV files:
- Use commas as delimiters
- Don't have trailing spaces
- Use Unix line endings (LF, not CRLF)

```bash
# Convert CSV line endings
dos2unix tenants/data/*.csv
```

## Development Roadmap

### Phase 1 (Current)
- [x] Core dispatch infrastructure
- [x] Tenant dispatcher templates
- [x] Configuration loading (bootstrap)
- [x] Placeholder generation for all modules

### Phase 2 (Planned)
- [ ] Git module full implementation
- [ ] NPM/NPX module implementation
- [ ] IDE module implementation (VS Code priority)
- [ ] App module implementation

### Phase 3 (Future)
- [ ] Web module (browser opening)
- [ ] AWS module
- [ ] AI module
- [ ] Advanced utilities

## Contributing

To add functionality to a placeholder script:

1. **Understand the Batch Version**: Read the corresponding `.bat` file
2. **Convert Logic**: Translate batch commands to bash
3. **Test**: Verify it works on your platform
4. **Document**: Update this guide with any platform-specific notes
5. **Share**: Submit a pull request or share your implementation

## Examples

### Creating a New Tenant (Linux/macOS)

```bash
# Copy template
cp tenants/dispatch/TEMPLATE.sh tenants/dispatch/my-tenant.sh

# Edit with your tenant info
nano tenants/dispatch/my-tenant.sh

# Update these lines:
# Tenant="MyTenant"
# KEY="my-tenant"

# Make executable
chmod +x tenants/dispatch/my-tenant.sh

# Create CSV files
echo "alias,display,root" > tenants/data/tenants.csv
echo "my-tenant,MyTenant,/path/to/my/sources" >> tenants/data/tenants.csv

echo "alias,name,label,type,client,server,home" > tenants/data/my-tenant.csv
echo "admin,my-admin,Admin,bff,my-admin/client,my-admin,main" >> tenants/data/my-tenant.csv

# Test
./tenants/dispatch/my-tenant.sh help
```

## Platform-Specific Features

### macOS Specific

**Opening URLs:**
```bash
open "https://github.com/user/repo"
```

**Opening Apps:**
```bash
open -a "Visual Studio Code" /path/to/project
```

### Linux Specific

**Opening URLs:**
```bash
xdg-open "https://github.com/user/repo"
```

**Opening Apps:**
```bash
code /path/to/project  # VS Code
```

## Performance Notes

Shell scripts (.sh) are generally **faster** than batch files (.bat) due to:
- Native Unix command execution
- Better I/O handling
- More efficient process spawning

## License

Same as LazyPolyRepoExpress main project.

## Support

For issues or questions:
- Check this guide first
- Review the corresponding `.bat` file for expected behavior
- Open an issue with details about your platform

---

**Note**: This is an ongoing migration. Windows `.bat` files remain the primary, fully-tested implementation. Shell scripts are being implemented progressively. Contributions welcome!
