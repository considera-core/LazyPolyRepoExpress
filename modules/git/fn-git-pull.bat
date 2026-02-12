:: ==============================
:: fn-git-pull <tenant> <project>
:: ==============================
@ECHO OFF
SET "tenant=%~1"
SET "project=%~2"
IF NOT DEFINED project (
    CALL fn-foreach "%tenant%" "fn-git-pull"
    EXIT /B 0
)
CALL :FN
EXIT /B 0

:FN
    ECHO [LPRE GIT PULL: %tenant%/%project%]
    CALL fn-findTenantRoot "%tenant%"
    CALL fn-findProjectByAlias "%project%"
    CALL git -C "%SELECTED_TENANT_ROOT%/%FOUND_NAME%" pull
    EXIT /B 0