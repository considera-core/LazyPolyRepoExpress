# Functions
function RemoveSymbolicLink {
    param ([string]$linkPath)
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

echo "Starting Lazy Polyrepo Express Tools uninstallation..."

# Check if Symbolic Links Directory Exists
CALL fn-config get RootSymLinksPath
if (Test-Path -Path "$LPRE_SYM_PATH" -PathType Container) {
    echo "$LPRE_SYM_PATH exists."
    echo "Removing symbolic links for script paths..."
    RemoveSymbolicLink -linkPath $LPRE_SYM_PATH/Root
    RemoveSymbolicLink -linkPath $LPRE_SYM_PATH/Config
    RemoveSymbolicLink -linkPath $LPRE_SYM_PATH/Modules
    RemoveSymbolicLink -linkPath $LPRE_SYM_PATH/ModulesAi
    RemoveSymbolicLink -linkPath $LPRE_SYM_PATH/ModulesApp
    RemoveSymbolicLink -linkPath $LPRE_SYM_PATH/ModulesEtc
    RemoveSymbolicLink -linkPath $LPRE_SYM_PATH/ModulesGit
    RemoveSymbolicLink -linkPath $LPRE_SYM_PATH/ModulesIde
    RemoveSymbolicLink -linkPath $LPRE_SYM_PATH/ModulesNpm
    RemoveSymbolicLink -linkPath $LPRE_SYM_PATH/ModulesAws
    RemoveSymbolicLink -linkPath $LPRE_SYM_PATH/Tenants
    RemoveSymbolicLink -linkPath $LPRE_SYM_PATH/TenantsDispatch
} else {
    echo "$LPRE_SYM_PATH does not exist, nothing to uninstall."
}