:: =========================
:: fn-app-run <tenant> <app>
:: =========================
@ECHO OFF
SET "tenant=%~1"
SET "app=%~2"
set "here=%~3"
IF NOT DEFINED app (
    ECHO [ERROR] Missing app.
    EXIT /B 1
)
CALL :FN
EXIT /B 0

:FN
    ECHO [VANGUARD RUN: %tenant%/%app%]
    CALL fn-setRepoRootPath
    ECHO   [INFO] Running %app%...
    CALL fn-app-launch "%tenant%" "%app%"
    CALL fn-app-launch "%tenant%" "api"
    CALL fn-app-launch "%tenant%" "public-api"
    IF /I "%FOUND_TYPE%"=="bff" (
        CALL spawn-bff-window "%tenant%" "%FOUND_NAME%" "%here%"
    ) else (
        CALL spawn-api-window "%tenant%" "%FOUND_NAME%" "%here%"
    )
    EXIT /B 0