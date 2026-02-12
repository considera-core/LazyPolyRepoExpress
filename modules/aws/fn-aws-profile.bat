:: =======================
:: fn-aws-profile <tenant>
:: =======================
@ECHO OFF
SET "tenant=%~1"

IF NOT DEFINED tenant (
    ECHO [ERROR] Missing AWS tenant/profile name
    ECHO   Usage: fn-aws-profile ^<tenant^>
    EXIT /B 1
)

CALL :FN
EXIT /B 0

:FN
    ECHO [LPRE AWS PROFILE: %tenant%]
    SETX AWS_PROFILE "%tenant%" >nul
    SET "AWS_PROFILE=%tenant%"
    ECHO [SUCCESS] AWS_PROFILE set to: %tenant%
    ECHO [NOTE] Environment variable updated for current session and future sessions
    EXIT /B 0
