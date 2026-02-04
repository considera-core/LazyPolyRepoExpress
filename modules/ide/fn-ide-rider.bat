:: ==============================
:: fn-ide-rider <tenant> <project>
:: ==============================
@ECHO OFF
SET "tenant=%~1"
SET "project=%~2"
IF NOT DEFINED project (
    CALL fn-foreach-alias "%tenant%" fn-ide-rider
    EXIT /B 0
)
CALL :FN
EXIT /B 0

:FN
    ECHO [VANGUARD IDE RIDER: %tenant%/%project%]
    CALL fn-setRepoRootPath
    CALL fn-findProjectByAlias "%project%"
    IF ERRORLEVEL 1 (
        ECHO   [ERROR] Project not found: %project%
        EXIT /B 1
    )
    ECHO   [INFO] Opening %FOUND_LABEL% (%FOUND_NAME%) in JetBrains Rider...
    CD "%REPO_ROOT_PATH%"/%TENANT%/%FOUND_NAME%/
    START "" "rider64.exe" . >NUL 2>&1
    IF ERRORLEVEL 1 (
        ECHO   [ERROR] Failed to launch JetBrains Rider. Make sure you add the rider64.exe's bin directory to your system/user PATH and then refresh your terminal.
        EXIT /B 1
    )
    EXIT /B 0