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
    ECHO [VANGUARD GIT PULL: %tenant%/%project%]
    CALL fn-setRepoRootPath
    CALL fn-findProjectByAlias "%project%"
    CALL git -C "%REPO_ROOT_PATH%/%tenant%/%FOUND_NAME%" pull
    EXIT /B 0