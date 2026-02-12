# Functions
function Create-SymbolicLink {
    param (
        [Parameter(Mandatory)][string]$LinkPath,
        [Parameter(Mandatory)][string]$TargetPath
    )

    try {
        Remove-Item -Path $LinkPath -Force -Recurse -ErrorAction SilentlyContinue
    } catch {
        Write-Host "  Failed to remove $LinkPath"
    }

    New-Item `
        -ItemType SymbolicLink `
        -Path $LinkPath `
        -Target $TargetPath `
        -Force | Out-Null

    if (Test-Path -Path $LinkPath -PathType Container) {
        Write-Host "  $LinkPath created."
    } else {
        Write-Host "  $LinkPath not created."
    }
}

function Verify-PathAddition {
    param (
        [Parameter(Mandatory)][string]$LinkPath,
        [Parameter(Mandatory)][string]$TargetPath
    )

    Create-SymbolicLink -LinkPath $LinkPath -TargetPath $TargetPath

    # Normalize link path
    $normalizedLink = (Resolve-Path $LinkPath).Path.TrimEnd('\')

    # Split PATH safely
    $pathEntries = [Environment]::GetEnvironmentVariable("Path", "User") `
        -split ';' |
        Where-Object { $_ -and $_.Trim() } |
        ForEach-Object { $_.TrimEnd('\') }

    # Deduplicate (case-insensitive)
    $pathSet = [System.Collections.Generic.HashSet[string]]::new(
        [StringComparer]::OrdinalIgnoreCase
    )

    foreach ($entry in $pathEntries) {
        $pathSet.Add($entry) | Out-Null
    }

    if (-not $pathSet.Contains($normalizedLink)) {
        Write-Host "  Adding $normalizedLink to PATH"
        $pathSet.Add($normalizedLink) | Out-Null
    } else {
        Write-Host "  $normalizedLink already in PATH"
        return;
    }

    # Rebuild PATH cleanly
    $cleanPath = ($pathSet | Sort-Object) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $cleanPath, "User")
}

Write-Host "Starting Lazy Polyrepo Express Tools installation..."

# Root paths
$REPO_PATH = Resolve-Path "$PSScriptRoot"
$SYM_PATH  = "C:/.symlinks/LPRE"

Write-Host "Repository path: $REPO_PATH"
Write-Host "Symbolic links path: $SYM_PATH"

# Create links directory
Write-Host "Creating $SYM_PATH directory..."
if (-not (Test-Path $SYM_PATH)) {
    New-Item -ItemType Directory -Path $SYM_PATH | Out-Null
} else {
    Write-Host "  $SYM_PATH already exists."
}

# Backup PATH
Write-Host "Backing up PATH (.\saved_path.txt)..."
$env:PATH | Out-File -Encoding utf8 "saved_path.txt"

Write-Host "Creating symbolic links for script paths..."

Verify-PathAddition `
    -LinkPath (Join-Path $SYM_PATH "Root") `
    -TargetPath $REPO_PATH

Verify-PathAddition `
    -LinkPath (Join-Path $SYM_PATH "Config") `
    -TargetPath (Join-Path $REPO_PATH "config")

Verify-PathAddition `
    -LinkPath (Join-Path $SYM_PATH "Modules") `
    -TargetPath (Join-Path $REPO_PATH "modules")

Verify-PathAddition `
    -LinkPath (Join-Path $SYM_PATH "ModulesAi") `
    -TargetPath (Join-Path $REPO_PATH "modules\ai")

Verify-PathAddition `
    -LinkPath (Join-Path $SYM_PATH "ModulesApp") `
    -TargetPath (Join-Path $REPO_PATH "modules\app")

Verify-PathAddition `
    -LinkPath (Join-Path $SYM_PATH "ModulesEtc") `
    -TargetPath (Join-Path $REPO_PATH "modules\etc")

Verify-PathAddition `
    -LinkPath (Join-Path $SYM_PATH "ModulesGit") `
    -TargetPath (Join-Path $REPO_PATH "modules\git")

Verify-PathAddition `
    -LinkPath (Join-Path $SYM_PATH "ModulesIde") `
    -TargetPath (Join-Path $REPO_PATH "modules\ide")

Verify-PathAddition `
    -LinkPath (Join-Path $SYM_PATH "ModulesNpm") `
    -TargetPath (Join-Path $REPO_PATH "modules\npm")

Verify-PathAddition `
    -LinkPath (Join-Path $SYM_PATH "ModulesAws") `
    -TargetPath (Join-Path $REPO_PATH "modules\aws")

Verify-PathAddition `
    -LinkPath (Join-Path $SYM_PATH "Tenants") `
    -TargetPath (Join-Path $REPO_PATH "tenants")

Verify-PathAddition `
    -LinkPath (Join-Path $SYM_PATH "TenantsDispatch") `
    -TargetPath (Join-Path $REPO_PATH "tenants\dispatch")

Write-Host ""

# =========================
# Verify org commands
# =========================

Write-Host "Testing org commands..."
Write-Host "If they do not work, restart your terminal and run this script again."

fn-config new
fn-config set Username $env:USERNAME
fn-config set RootRepoPath $REPO_PATH
fn-config set RootSymLinksPath $SYM_PATH
sample-org hello

Write-Host "If they did not work, restart your terminal and run this script again."