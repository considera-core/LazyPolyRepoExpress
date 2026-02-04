@echo off

set categoryName=%~1
set projectName=%~2
set command=%~3
set "here=%~4"

if not defined here (
    echo   [spawn-claude-window/INFO] Spawning Claude Code window for %categoryName% %projectName%...
    wt -w 0 powershell -NoExit -Command "spawn-claude %categoryName% %projectName% '%command%'"
    exit /B 0
)

powershell -NoExit -Command "spawn-claude %categoryName% %projectName% '%command%' '%here%'"
exit /B 0
