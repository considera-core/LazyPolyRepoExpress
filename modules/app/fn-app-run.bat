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
    ECHO [LPRE RUN: %tenant%/%app%]
    CALL fn-findTenantRoot "%tenant%"
    ECHO   [INFO] Running %app%...
    CALL fn-app-launch "%tenant%" "%app%"
    CALL fn-app-launch "%tenant%" "api"
    CALL fn-app-launch "%tenant%" "public-api"
    EXIT /B 0