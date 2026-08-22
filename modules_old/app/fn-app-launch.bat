:: ================================
:: fn-app-launch <tenant> <project>
:: ================================
@ECHO OFF
SET "tenant=%~1"
SET "project=%~2"
set "here=%~3"
IF NOT DEFINED project (
    ECHO [ERROR] Missing project.
    EXIT /B 1
)
CALL :FN
EXIT /B 0

:FN
    ECHO [VANGUARD LAUNCH: %tenant%/%project%]
    CALL fn-findTenantRoot "%tenant%"
    CALL fn-findProjectByAlias "%project%"
    IF ERRORLEVEL 1 (
        ECHO [ERROR] Project not found: %project%
        EXIT /B 1
    )
    ECHO [INFO] Launching %FOUND_LABEL% (%FOUND_NAME%)...
    IF /I "%FOUND_TYPE%"=="bff" (
        CALL spawn-bff-window "%tenant%" "%FOUND_NAME%" "%here%"
    ) else (
        CALL spawn-api-window "%tenant%" "%FOUND_NAME%" "%here%"
    )
    EXIT /B 0