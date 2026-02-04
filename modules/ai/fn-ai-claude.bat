:: =========================================
:: fn-ai-claude <tenant> <project> <command>
:: =========================================
@ECHO OFF
SET "tenant=%~1"
SET "project=%~2"
SET "command=%~3"
SET "here=%~4"
IF NOT DEFINED project (
    ECHO [ERROR] Missing project.
    EXIT /B 1
)
IF NOT DEFINED command (
    CALL fn-findProjectByAlias "%project%"
    IF NOT ERRORLEVEL 1 (
        ECHO [ERROR] Missing command, got project "%project%" instead
        EXIT /B 1
    )
    ::CALL fn-foreach "%tenant%" "fn-ai-claude" "%project%"
    EXIT /B 0
)
CALL :FN
EXIT /B 0

:FN
    ECHO [VANGUARD AI: Claude Code for %tenant%/%project%]
    CALL fn-findTenantRoot "%tenant%"
    CALL fn-findProjectByAlias "%project%"
    IF ERRORLEVEL 1 (
        ECHO [ERROR] Project not found: %project%
        EXIT /B 1
    )
    ECHO [INFO] Opening Claude Code for %FOUND_LABEL% (%FOUND_NAME%)...
    CALL spawn-claude-window "%tenant%" "%FOUND_NAME%" "%command%" "%here%"
    EXIT /B 0
