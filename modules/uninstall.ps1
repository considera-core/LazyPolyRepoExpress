# Functions
function RemoveSymbolicLink {
    param (
        [string]$linkPath,
        [string]$targetPath
    )
    try {
        Remove-Item -Path $linkPath -Force -Recurse -ErrorAction SilentlyContinue
    } catch {
        echo "Failed to remove $linkPath"
    }
    if (Test-Path -Path $linkPath -PathType Container) {
        echo "$linkPath still exists."
    } else {
        echo "$linkPath deleted."
    }
}

function VerifyPathAddition {
    param (
        [string]$pathToCheck
    )
    $currentPath = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::User)
    if ($currentPath -notlike "*$pathToCheck*") {
        echo "$pathToCheck NOT added to PATH."
    }
    echo "$pathToCheck added to PATH."
}

echo "Starting Vanguard Helper Tools uninstallation..."

# Get Root Repository Path
echo `n
echo "Getting root repository path..."
$REPO_PATH = & .\vanguard-helper-settings.bat repository-path | Select-Object -First 1
$REPO_PATH = $REPO_PATH.Trim()
echo `n

# Check if Symbolic Links Directory Exists
echo "Checking ROOT_SYM_LINKS_TODO directory..."
if (Test-Path -Path "C:\ROOT_SYM_LINKS_TODO" -PathType Container) {
    echo "C:\ROOT_SYM_LINKS_TODO exists."
} else {
    mkdir "C:\ROOT_SYM_LINKS_TODO doesn't exist"
    exit /B 0
}
echo `n

# Create Symbolic Links for Vanguard Helper Tools (to prevent PATH length issues)
echo "Removing symbolic links for script paths..."
RemoveSymbolicLink -linkPath "C:\ROOT_SYM_LINKS_TODO\VHT" -targetPath ""
RemoveSymbolicLink -linkPath "C:\ROOT_SYM_LINKS_TODO\VHT_D" -targetPath "docker"
RemoveSymbolicLink -linkPath "C:\ROOT_SYM_LINKS_TODO\VHT_R" -targetPath "repository"
RemoveSymbolicLink -linkPath "C:\ROOT_SYM_LINKS_TODO\VHT_RF" -targetPath "repository\functions"
RemoveSymbolicLink -linkPath "C:\ROOT_SYM_LINKS_TODO\VHT_RP" -targetPath "repository\projects"

echo `n