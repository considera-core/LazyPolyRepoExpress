:: ==========================================
:: fn-npm-npx <tenant> <project> <npx-command>
:: ==========================================
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "tenant=%~1"
SET "project=%~2"
SET "command=%~3"

echo [DEBUG] tenant="%tenant%", project="%project%", command="%command%"

IF NOT DEFINED tenant (
    ECHO [ERROR] Missing tenant
    EXIT /B 1
)

IF NOT DEFINED project (
    ECHO [ERROR] Missing project or npx command
    EXIT /B 1
)

IF NOT DEFINED command (
    CALL fn-findProjectByAlias "%project%"
    IF NOT ERRORLEVEL 1 (
        ECHO [ERROR] Missing npx command, got project "%project%" instead
        EXIT /B 1
    )
    CALL fn-forEachAliasByType "bff" "%tenant%" "fn-npm-npx" "%project%"
    EXIT /B 0
)

CALL fn-findProjectByAlias "%command%"
IF NOT ERRORLEVEL 1 (
    ECHO [ERROR] Missing npx command, got project "%command%" instead
    EXIT /B 1
)


:: Build args string from %4..%9
SET "args=%~4 %~5 %~6 %~7 %~8 %~9"
SET "full=%command% %args%"

GOTO :FN
EXIT /B %ERRORLEVEL%

:FN
    ECHO [LPRE npx: %tenant%/%project%]
    ECHO -^> Running npx %full%

    CALL fn-findTenantRoot "%tenant%"
    IF ERRORLEVEL 1 (
        ECHO [ERROR] Could not determine repo root path
        EXIT /B 1
    )

    CALL fn-findProjectByAlias "%project%"
    IF ERRORLEVEL 1 (
        ECHO [ERROR] Project alias "%project%" not found
        EXIT /B 1
    )
echo "%SELECTED_TENANT_ROOT%/%FOUND_NAME%/%FOUND_NAME%/client"
    PUSHD "%SELECTED_TENANT_ROOT%/%FOUND_NAME%/%FOUND_NAME%/client" || (
        ECHO [ERROR] Could not cd into repo client path.
        EXIT /B 1
    )

    npx %full%
    SET "rc=%ERRORLEVEL%"

    POPD
    EXIT /B %rc%

:Usage
    ECHO Usage: %~nx0 ^<tenant^> ^<project^> ^<npx-command^> [args...]
    EXIT /B 2