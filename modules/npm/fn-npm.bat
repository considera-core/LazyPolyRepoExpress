:: ==========================================
:: fn-npm <tenant> <project> <npm-command>
:: ==========================================
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "tenant=%~1"
SET "project=%~2"
SET "command=%~3"

IF NOT DEFINED tenant GOTO :Usage
IF NOT DEFINED project GOTO :Usage
IF NOT DEFINED command GOTO :Usage

:: Build args string from %4..%9
SET "args=%~4 %~5 %~6 %~7 %~8 %~9"
SET "full=%command% %args%"

CALL :FN
EXIT /B %ERRORLEVEL%

:FN
    ECHO [VANGUARD NPM: %tenant%/%project%]
    ECHO -^> Running npm %full%

    CALL fn-setRepoRootPath
    IF ERRORLEVEL 1 (
        ECHO [ERROR] Could not determine repo root path
        EXIT /B 1
    )

    CALL fn-findProjectByAlias "%project%"
    IF ERRORLEVEL 1 (
        ECHO [ERROR] Project alias "%project%" not found
        EXIT /B 1
    )

echo %~d0%REPO_ROOT_PATH%/%tenant%/%FOUND_NAME%/%FOUND_NAME%/client
    PUSHD "%~d0%REPO_ROOT_PATH%/%tenant%/%FOUND_NAME%/%FOUND_NAME%/client" || (
        ECHO [ERROR] Could not cd into repo client path.
        EXIT /B 1
    )

    npm %full%
    SET "rc=%ERRORLEVEL%"

    POPD
    EXIT /B %rc%

:Usage
    ECHO Usage: %~nx0 ^<tenant^> ^<project^> ^<npm-command^> [args...]
    EXIT /B 2
