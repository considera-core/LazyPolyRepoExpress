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
    ECHO [VANGUARD GIT HOME: %tenant%/%project%]
    CALL fn-findTenantRoot "%tenant%"
    CALL fn-findProjectByAlias "%project%"
    CALL git -C "%SELECTED_TENANT_ROOT%/%FOUND_NAME%" "switch" "%FOUND_HOME%" >NUL 2>&1
    IF ERRORLEVEL 1 (
        ECHO   [ERROR] GIT SWITCH HOME FAILED:
        ECHO     git switch failed for %tenant%/%project% at %SELECTED_TENANT_ROOT%/%FOUND_NAME%
        ECHO     Make sure the repo exists and the branch `%FOUND_HOME%` exists.
        EXIT /B 1
    )
    EXIT /B 0