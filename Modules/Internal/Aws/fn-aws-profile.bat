:: =======================
:: fn-aws-profile <tenant>
:: =======================
@ECHO OFF
SET "tenant=%~1"
SET "isProd=%~2"

ECHO leprechaun/fn-aws-profile[D]: [Tenant=%tenant% IsProd=%isProd%]

IF NOT DEFINED tenant (
    ECHO [ERROR] Missing AWS tenant/profile name
    ECHO   Usage: fn-aws-profile ^<tenant^> ^<isProd?^>
    EXIT /B 1
)

IF DEFINED isProd (
    SET "tenant=%tenant%_prod"
)

CALL :FN
EXIT /B 0

:FN
    ECHO [LPRE AWS PROFILE: %tenant%]
    SETX AWS_PROFILE "%tenant%" >nul
    SET "AWS_PROFILE=%tenant%"
    ECHO [SUCCESS] AWS_PROFILE set to: %tenant%
    ECHO [NOTE] Environment variable updated for current session and future sessions... Run refreshenv if you can
    EXIT /B 0
