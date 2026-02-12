param (
	[string]$CategoryName,
	[string]$ProjectName,
	[string]$Command,
	[string]$Here
)

$host.UI.RawUI.WindowTitle = "Claude Code - $ProjectName"

if (!$Here) {
	cls
}

echo "  [spawn-claude/INFO] Opening Claude Code for $CategoryName/$ProjectName..."

# Get the Vanguard path from config
$vanguardPath = & fn-config get VanguardPath

# Construct the project path
$projectPath = Join-Path $vanguardPath "$CategoryName\$ProjectName"

if (!(Test-Path $projectPath)) {
    echo "  [spawn-claude/ERROR] Project path not found: $projectPath"
    exit 1
}

echo "  [spawn-claude/INFO] Project path: $projectPath"
Set-Location $projectPath

# Launch Claude Code interactively, persisting in the terminal
if ($Command) {
    echo "  [spawn-claude/INFO] Launching Claude Code with command: $Command"
    & "claude" $Command
} else {
    echo "  [spawn-claude/INFO] Launching Claude Code..."
    & "claude"
}

echo "  [spawn-claude/INFO] Claude Code launched in background"
