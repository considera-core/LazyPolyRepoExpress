:: ==============================
:: fn-git-home <tenant> <project>
:: ==============================
@ECHO OFF
SET "tenant=%~1"
SET "project=%~2"
IF NOT DEFINED project (
    CALL fn-foreach "%tenant%" "fn-git-home"
    EXIT /B 0
)
CALL :FN
EXIT /B 0

:FN
    ECHO [LPRE GIT HOME: %tenant%/%project%]
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
            git -C "%REPO_PATH%" stash push -m "Auto-stash from fn-git-home" >NUL 2>&1
            SET "STASHED=1"
        ) ELSE (
            ECHO   [INFO] Stash exists, carrying changes over...
        )
    )

    CALL git -C "%REPO_PATH%" "switch" "%FOUND_HOME%" >NUL 2>&1
    IF ERRORLEVEL 1 (
        ECHO   [ERROR] GIT SWITCH HOME FAILED:
        ECHO     git switch failed for %tenant%/%project% at %REPO_PATH%
        ECHO     Make sure the repo exists and the branch `%FOUND_HOME%` exists.
        REM Pop stash if we stashed
        IF "%STASHED%"=="1" (
            ECHO   [INFO] Restoring stashed changes...
            git -C "%REPO_PATH%" stash pop >NUL 2>&1
        )
        EXIT /B 1
    )

    REM Pop stash if we stashed
    IF "%STASHED%"=="1" (
        ECHO   [INFO] Restoring stashed changes...
        git -C "%REPO_PATH%" stash pop >NUL 2>&1
    )

    EXIT /B 0