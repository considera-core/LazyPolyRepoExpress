:: ==================================
:: fn-git-branches <tenant> <project>
:: ==================================
@ECHO OFF
SET "tenant=%~1"
SET "project=%~2"
IF NOT DEFINED project (
    CALL fn-foreach "%tenant%" "fn-git-branches"
    EXIT /B 0
)
CALL :FN
EXIT /B 0

:FN
    ECHO [VANGUARD GIT BRANCHES: %tenant%/%project%]
    CALL fn-setRepoRootPath
    CALL fn-findProjectByAlias "%project%"
    CALL git -C "%REPO_ROOT_PATH%/%tenant%/%FOUND_NAME%" "recent-branches"
    EXIT /B 0