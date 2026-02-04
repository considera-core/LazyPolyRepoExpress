@echo off

set categoryName=%~1
set projectName=%~2

echo    [spawn-angular-window/INFO] Spawning Angular window for %categoryName% %projectName%...

wt -w 0 powershell -NoExit -Command "spawn-angular %categoryName% %projectName%"
exit /B 0