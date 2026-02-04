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
    CALL fn-setRepoRootPath
    CALL fn-findProjectByAlias "%project%"
    CALL fn-setVanguardConfigStatic "%tenant%" "%FOUND_LABEL%"
    CALL git -C "%REPO_ROOT_PATH%/%tenant%/%FOUND_NAME%" "switch" "%VANGUARD_CONFIG_STATIC_VALUE%"
    EXIT /B 0