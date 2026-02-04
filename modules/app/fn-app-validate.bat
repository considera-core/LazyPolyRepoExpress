:: ==============================
:: fn-validate <tenant> <project>
:: ==============================
@ECHO OFF
SET "tenant=%~1"
SET "project=%~2"
IF NOT DEFINED tenant (
    ECHO [ERROR] Missing tenant.
    EXIT /B 1
)
IF NOT DEFINED project (
    CALL fn-foreach "%tenant%" "fn-app-validate"
    EXIT /B 0
)
CALL :FN
EXIT /B 0

:FN
    CALL fn-setRepoRootPath
    CALL fn-findProjectByAlias "%project%"
    IF NOT EXIST "%REPO_ROOT_PATH%/%tenant%/%FOUND_NAME%" (
        ECHO [ERROR] Missing repository: %REPO_ROOT_PATH%/%tenant%/%FOUND_NAME%
    ) ELSE (
        ECHO [INFO] Found repository: %REPO_ROOT_PATH%/%tenant%/%FOUND_NAME%
    )