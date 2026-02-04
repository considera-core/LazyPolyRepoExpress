:: ================================
:: fn-git-branch <tenant> <project>
:: ================================
@ECHO OFF
SET "tenant=%~1"
SET "project=%~2"
IF NOT DEFINED project (
    CALL fn-foreach "%tenant%" "fn-git-branch"
    EXIT /B 0
)
CALL :FN
EXIT /B 0

:FN
    ECHO [VANGUARD GIT BRANCH: %tenant%/%project%]
    CALL fn-setRepoRootPath
    CALL fn-findProjectByAlias "%project%"
    CALL git -C "%REPO_ROOT_PATH%/%tenant%/%FOUND_NAME%" "branch" "--show-current"
    EXIT /B 0