@ECHO OFF

set "categoryName=%~1"
set "projectName=%~2"
set "here=%~3"

if not defined here (
    echo   [spawn-bff-window/INFO] Spawning BFF window for %categoryName% %projectName%...
    wt -w 0 powershell -NoExit -Command "spawn-bff %categoryName% %projectName%"
    exit /B 0
)

powershell -NoExit -Command "spawn-bff %categoryName% %projectName% %here%"
exit /B 0