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

Write-Host "LeprechaunCLI:Install[I]: Starting Lazy Polyrepo Express Tools installation..."

# Root paths
$REPO_PATH = Resolve-Path "$PSScriptRoot"
$SYM_PATH  = "C:/.symlinks/Leprechaun"

Write-Host "LeprechaunCLI:Install[I]: Repository path: $REPO_PATH"
Write-Host "LeprechaunCLI:Install[I]: Symbolic links path: $SYM_PATH"

# Create links directory
Write-Host "LeprechaunCLI:Install[I]: Creating $SYM_PATH directory..."
if (-not (Test-Path $SYM_PATH)) {
    New-Item -ItemType Directory -Path $SYM_PATH | Out-Null
} else {
    Write-Host "LeprechaunCLI:Install[I]: $SYM_PATH already exists."
}

# Backup PATH
Write-Host "LeprechaunCLI:Install[I]: Backing up PATH (.\saved_path.txt)..."
$env:PATH | Out-File -Encoding utf8 "saved_path.txt"

Write-Host "LeprechaunCLI:Install[I]: Creating symbolic links for script paths..."

Verify-PathAddition -LinkPath (Join-Path $SYM_PATH "Root") -TargetPath $REPO_PATH
Verify-PathAddition -LinkPath (Join-Path $SYM_PATH "Exec") -TargetPath "$REPO_PATH\Bin"

Write-Host "LeprechaunCLI:Install[I]: Testing org commands..."
Write-Host "LeprechaunCLI:Install[I]: If they do not work, restart your terminal and run this script again."

fn-config new
fn-config set Username $env:USERNAME
fn-config set RootRepoPath $REPO_PATH
fn-config set RootSymLinksPath $SYM_PATH
leprechaun modules
ConsideraWeb test run
