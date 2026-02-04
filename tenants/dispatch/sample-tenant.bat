@ECHO OFF
SETLOCAL EnableExtensions
SETLOCAL EnableDelayedExpansion

set "TENANT=Vitals"
SET "NAME=vitals"
SET "module=%~1"
SET "action=%~2"
SET "arg1=%~3"
SET "arg2=%~4"
SET "arg3=%~5"

echo [INFO] Dispatching %TENANT% %module% %action% %arg1% %arg2% %arg3%
CALL fn-dispatch "%TENANT%" "%NAME%" "%module%" "%action%" "%arg1%" "%arg2%" "%arg3%"
IF ERRORLEVEL 1 EXIT /B 1