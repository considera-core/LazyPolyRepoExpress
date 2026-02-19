:: ==============================
:: fn-npx-knip <tenant> <project>
:: ==============================
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "DrivePath=%~dp0"
SET "RootDrive=%DrivePath:~0,2%"
SET "tenant=%~1"
SET "project=%~2"

IF NOT DEFINED tenant (
    ECHO [ERROR] Missing tenant
    EXIT /B 1
)

IF NOT DEFINED project (
    CALL fn-forEachAliasByType "bff" "%tenant%" "fn-npx-knip" "%project%"
    EXIT /B 0
)

IF NOT EXIST "%RootDrive%/.tmp/knip" (
    MKDIR "%RootDrive%/.tmp/knip"
    IF ERRORLEVEL 1 (
        ECHO [ERROR] Could not create output directory
        EXIT /B 1
    )
    ECHO [DEBUG] Created output directory "%RootDrive%/.tmp/knip"
)
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

PUSHD "%SELECTED_TENANT_ROOT%/%FOUND_NAME%/%FOUND_NAME%/client" || (
    ECHO [ERROR] Could not cd into repo client path.
    EXIT /B 1
)

REM Only capture npx output, not ECHO statements
npx -y knip --dependencies > "%RootDrive%/.tmp/knip/%tenant%-%project%.txt" 2>&1
SET "rc=%ERRORLEVEL%"

    POPD
    ECHO Output saved to "%RootDrive%/.tmp/knip/%tenant%-%project%.txt"
    EXIT /B %rc%

:Usage
    ECHO Usage: %~nx0 ^<tenant^> ^<project^>
    EXIT /B 2