@echo off

set categoryName=%~1
set projectName=%~2
set "here=%~3"

if not defined here (
    echo   [spawn-api-window/INFO] Spawning API window for %categoryName% %projectName%...
    wt -w 0 powershell -NoExit -Command "spawn-api %categoryName% %projectName%"
    exit /B 0
)

powershell -NoExit -Command "spawn-api %categoryName% %projectName% %here%"
exit /B 0