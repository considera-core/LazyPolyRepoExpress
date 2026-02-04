# Functions
function CreateSymbolicLink {
    param (
        [string]$linkPath,
        [string]$targetPath
    )
    try {
        Remove-Item -Path $linkPath -Force -Recurse -ErrorAction SilentlyContinue
    } catch {
        echo "  Failed to remove $linkPath"
    }
    New-Item -ItemType SymbolicLink -Path $linkPath -Target "$REPO_PATH\$targetPath" | Out-Null
    if (Test-Path -Path $linkPath -PathType Container) {
        echo "  $linkPath created."
    } else {
        echo "  $linkPath not created."
    }
}

function VerifyPathAddition {
    param (
        [string]$linkPath,
        [string]$targetPath
    )
    CreateSymbolicLink -linkPath $linkPath -targetPath $targetPath

    $currentPath = [System.Environment]::GetEnvironmentVariable('PATH', "User")
    if ($currentPath -notlike "*$linkPath*") {
        echo "  $linkPath NOT added to PATH. Adding now..."

        if ($currentPath[$currentPath.Length - 1] -ne ";") {
            $currentPath += ";"
        }
        $currentPath += "$linkPath"
        [System.Environment]::SetEnvironmentVariable("Path", $currentPath, "User")
        echo "  Symbolic link added to PATH."
    } else {
        echo "  $linkPath already added to PATH."
    }
}

echo "Starting Vanguard Helper Tools initialization..."

# Get Root Repository Path
echo "Getting root repository path..."
$REPO_PATH = "C:\ROOT_DEV_TODO\Vanguard\Auto\eagle-vanguard-tools\"
echo "  Repository path: $REPO_PATH"

# Check if Symbolic Links Directory Exists
echo "Creating ROOT_SYM_LINKS_TODO directory..."
if (Test-Path -Path "C:\ROOT_SYM_LINKS_TODO" -PathType Container) {
    echo "  C:\ROOT_SYM_LINKS_TODO already exists."
} else {
    mkdir "C:\ROOT_SYM_LINKS_TODO"
}

echo "Backing up PATH (.\saved_path.txt)..."
$env:PATH > saved_path.txt

# Verify Symbolic Links
echo "Creating symbolic links for script paths..."
:: VerifyPathAddition -linkPath C:\ROOT_SYM_LINKS_TODO\EVT -targetPath ""

echo `n

# Verify Vanguard Command
echo "Testing vanguard commands... if they do not work, restart your terminal and run this script again."
vanguard-config new
vanguard-config set Username $env:USERNAME
vanguard-config set HelperToolsPath $PSScriptRoot
vanguard-config set LinksPath C:\ROOT_SYM_LINKS_TODO
vanguard hello
echo "If they did not work, restart your terminal and run this script again."
echo "I recommend ``refreshenv`` from chocolatey."