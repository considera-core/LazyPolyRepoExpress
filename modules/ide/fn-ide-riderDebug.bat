:: ==============================
:: fn-ide-riderDebug <tenant> <project>
:: ==============================
@ECHO OFF
SET "tenant=%~1"
SET "project=%~2"
IF NOT DEFINED project (
    ECHO [ERROR] Project name required for debug attachment
    ECHO   Usage: fn-ide-riderDebug ^<tenant^> ^<project^>
    EXIT /B 1
)
CALL :FN
EXIT /B 0

:FN
    ECHO [LPRE IDE RIDER DEBUG: %tenant%/%project%]
    CALL fn-findTenantRoot "%tenant%"
    CALL fn-findProjectByAlias "%project%"
    IF ERRORLEVEL 1 (
        ECHO   [ERROR] Project not found: %project%
        EXIT /B 1
    )

    ECHO   [INFO] Searching for running process for %FOUND_LABEL% (%FOUND_NAME%)...

    :: Look for dotnet.exe processes running a .dll from this project
    SET "project_path=%REPO_ROOT_PATH%\%TENANT%\%FOUND_NAME%"
    SET "found_pid="

    :: Use WMIC to find dotnet.exe processes with command line containing the project name
    FOR /F "tokens=2" %%P IN ('WMIC process WHERE "name='dotnet.exe' AND commandline LIKE '%%%FOUND_NAME%%%'" GET processid 2^>NUL ^| FINDSTR /R "[0-9]"') DO (
        SET "found_pid=%%P"
        GOTO :FOUND_PROCESS
    )

    :FOUND_PROCESS
    IF NOT DEFINED found_pid (
        ECHO   [ERROR] No running dotnet.exe process found for %FOUND_NAME%
        ECHO   [INFO] Make sure the application is running before attempting to attach the debugger
        EXIT /B 1
    )

    ECHO   [INFO] Found process PID: %found_pid%
    ECHO   [INFO] Attempting to attach Rider debugger...

    :: Use Rider's command-line to attach to the process
    :: The --attach flag is used to attach to an existing process
    START "" "rider64.exe" --attach %found_pid% "%project_path%" >NUL 2>&1
    IF ERRORLEVEL 1 (
        ECHO   [ERROR] Failed to attach Rider debugger. Make sure:
        ECHO           1. rider64.exe is in your PATH
        ECHO           2. The process is still running
        ECHO           3. You have debugging permissions
        EXIT /B 1
    )

    ECHO   [SUCCESS] Rider debugger attach command sent for PID %found_pid%
    EXIT /B 0
