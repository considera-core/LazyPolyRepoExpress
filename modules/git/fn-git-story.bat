:: ==========================================
:: fn-git-story <tenant> <project> <story-id>
:: ==========================================
@ECHO OFF
SET "tenant=%~1"
SET "project=%~2"
SET "storyId=%~3"

IF NOT DEFINED project (
    ECHO [ERROR] Missing project or story identifier
    EXIT /B 1
)

:: TWO SCENARIOS
:: 1. fn-git-story <tenant> <project> <story-id>
:: 2. fn-git-story <tenant> <story-id>
:: fn-foreach <tenant> <function> <...args>
::   => fn-git-story <tenant> <project> <storyId>
IF NOT DEFINED storyId (
    CALL fn-findProjectByAlias "%project%"
    IF NOT ERRORLEVEL 1 (
        ECHO [ERROR] Missing story identifier, got project "%project%" instead
        EXIT /B 1
    )
    CALL fn-foreach "%tenant%" "fn-git-story" "%project%"
    EXIT /B 0
)

CALL fn-findProjectByAlias "%storyId%"
IF NOT ERRORLEVEL 1 (
    ECHO [ERROR] Missing story identifier, got project "%storyId%" instead
    EXIT /B 1
)

CALL :FN
EXIT /B 0

:FN
    ECHO [LPRE GIT STORY: %tenant%/%project%/%storyId%]
    CALL fn-findTenantRoot "%tenant%"
    CALL fn-findProjectByAlias "%project%"

    SET "REPO_PATH=%SELECTED_TENANT_ROOT%/%FOUND_NAME%"
    SET "STASHED=0"

    REM Check if there are uncommitted changes
    git -C "%REPO_PATH%" diff-index --quiet HEAD -- >NUL 2>&1
    IF ERRORLEVEL 1 (
        REM There are changes, check if stash exists
        git -C "%REPO_PATH%" stash list | findstr /R "." >NUL 2>&1
        IF ERRORLEVEL 1 (
            REM No stash exists, stash the changes
            ECHO   [INFO] Stashing changes...
            git -C "%REPO_PATH%" stash push -m "Auto-stash from fn-git-story" >NUL 2>&1
            SET "STASHED=1"
        ) ELSE (
            ECHO   [INFO] Stash exists, carrying changes over...
        )
    )

    REM Try to switch to existing branch, or create new one
    git -C "%REPO_PATH%" switch "%storyId%" >NUL 2>&1
    IF ERRORLEVEL 1 (
        git -C "%REPO_PATH%" switch -c "%storyId%" >NUL 2>&1
        IF ERRORLEVEL 1 (
            ECHO   [ERROR] GIT SWITCH STORY FAILED:
            ECHO     git switch failed for %tenant%/%project%/%storyId% at %REPO_PATH%
            REM Pop stash if we stashed
            IF "%STASHED%"=="1" (
                ECHO   [INFO] Restoring stashed changes...
                git -C "%REPO_PATH%" stash pop >NUL 2>&1
            )
            EXIT /B 1
        )
    )

    REM Pop stash if we stashed
    IF "%STASHED%"=="1" (
        ECHO   [INFO] Restoring stashed changes...
        git -C "%REPO_PATH%" stash pop >NUL 2>&1
    )

    EXIT /B 0