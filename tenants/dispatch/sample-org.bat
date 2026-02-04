@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion
SET "project=%~1"
SET "module=%~2"
SET "action=%~3"
SET "arg1=%~4"
SET "arg2=%~5"
IF "%project%"=="hello" (
    ECHO Hello, %USERNAME%. This is Vanguard Helper Tools. This is the old description. Oops!
    ECHO Usage: vanguard [project] [mode?]
    ECHO Projects: ecertify, records, vitals, ram
    ECHO Modes ^(optional^): pull, list, active
    EXIT /B 0
)

FOR /F "tokens=*" %%a IN ('vanguard-config get HelperToolsPath') DO SET "REPO_PATH=%%a"
IF /I "%project%"=="ecertify" (
    CALL ecertify "%module%" "%action%" "%arg1%" "%arg2%"
) ELSE IF /I "%project%"=="records" (
    CALL records "%module%" "%action%" "%arg1%" "%arg2%"
) ELSE IF /I "%project%"=="vitals" (
    CALL vitals "%module%" "%action%" "%arg1%" "%arg2%"
) ELSE IF /I "%project%"=="ram" (
    CALL ram "%module%" "%action%" "%arg1%" "%arg2%"
) ELSE IF /I "%project%"=="reco" (
    CALL reco "%module%" "%action%" "%arg1%" "%arg2%"
) ELSE (
    SET "arg2=%arg1%"
    SET "arg1=%action%"
    SET "action=%module%"
    SET "module=%project%"
    ECHO [INFO] Dispatching to all tenants: tenant "!module!" "!action!" "!arg1!" "!arg2!"
    CALL ecertify "!module!" "!action!" "!arg1!" "!arg2!"
    CALL records "!module!" "!action!" "!arg1!" "!arg2!"
    CALL vitals "!module!" "!action!" "!arg1!" "!arg2!"
    CALL ram "!module!" "!action!" "!arg1!" "!arg2!"
    CALL reco "!module!" "!action!" "!arg1!" "!arg2!"
    exit /B 0
)
