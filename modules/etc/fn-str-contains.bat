:: =========================
:: fn-str-contains <in> <of>
:: =========================
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion
SET "h=%~1"
SET "n=%~2"
SET "x=!h:%n%=!"
IF "!x!"=="!h!" (
    REM ECHO "[DEBUG] Did NOT find '!n!' in '!h!'"
    EXIT /B 1
)
REM ECHO "[DEBUG] Did find '!n!' in '!h!'"
EXIT /B 0