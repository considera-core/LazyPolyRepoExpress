:: ==========================================
:: fn-git <tenant> <project> <git-subcommand>
:: ==========================================
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "tenant=%~1"
SET "project=%~2"
SET "sub=%~3"

IF NOT DEFINED tenant GOTO :Usage
IF NOT DEFINED project GOTO :Usage
IF NOT DEFINED sub GOTO :Usage

:: Build args string from %4..%9
SET "args=%~4 %~5 %~6 %~7 %~8 %~9"
SET "full=%sub% %args%"

:: Lowercase copy for matching
SET "lc=%full%"
call :ToLower lc
:: FOR /F "tokens=*" %%L IN ('fn-str-lower %full%') DO SET "lc=%%L"

:: Hard block: protected branch deletions
CALL fn-git-blockProtected "%lc%"
IF ERRORLEVEL 1 (
    ECHO.
    ECHO [BLOCKED] Refusing to delete protected branch ^(master/main/production-release^)
    EXIT /B 1
)

:: Only skip confirmation for readonly-ish commands
CALL :IsReadOnly "%lc%"
IF ERRORLEVEL 1 (
    CALL :Confirm "Run: git %full%   in %tenant%/%project%"
    IF ERRORLEVEL 1 (
        ECHO [CANCELLED] Not running git %full%
        EXIT /B 1
    )
)

CALL :FN
EXIT /B %ERRORLEVEL%

:FN
    ECHO [VANGUARD GIT: %tenant%/%project%]
    ECHO -^> Running git "%full%"

    CALL fn-findTenantRoot "%tenant%"
    IF ERRORLEVEL 1 (
        ECHO [ERROR] Could not determine repo root path
        EXIT /B 1
    )

    CALL fn-findProjectByAlias "%project%"
    IF ERRORLEVEL 1 (
        ECHO [ERROR] Project alias "%project%" not found
        EXIT /B 1
    )

    PUSHD "%~d0%SELECTED_TENANT_ROOT%/%FOUND_NAME%" || (
        ECHO [ERROR] Could not cd into repo path.
        EXIT /B 1
    )

    git %full%
    SET "rc=%ERRORLEVEL%"

    POPD
    EXIT /B %rc%

:Usage
    ECHO Usage: %~nx0 ^<tenant^> ^<project^> ^<git-subcommand^> [args...]
    EXIT /B 2

:Confirm
    SET "msg=%~1"
    ECHO.
    ECHO [CONFIRM] %msg%
    SET "ans=y"
    SET "a=%ans%"
    CALL :ToLower a
    IF /I NOT "%a%"=="y" EXIT /B 1
    EXIT /B 0

:IsReadOnly
    :: Returns 0 if read-only-ish (no confirm), 1 otherwise (confirm)
    SET "c=%~1"

    :: token-based: look at first word only
    FOR /F "tokens=1" %%T IN ("%c%") DO SET "t=%%T"

    IF "%t%"=="status" EXIT /B 0
    IF "%t%"=="log"    EXIT /B 0
    IF "%t%"=="diff"   EXIT /B 0
    IF "%t%"=="show"   EXIT /B 0
    IF "%t%"=="fetch"  EXIT /B 0

    :: Allow remote info commands (remote / remote -v / remote show ...)
    IF "%t%"=="remote" EXIT /B 0

    :: Allow listing branches/tags ONLY (no deletes/creates)
    IF "%t%"=="branch" (
        CALL fn-str-contains "%c%" " -d"
        IF NOT ERRORLEVEL 1 EXIT /B 1
        CALL fn-str-contains "%c%" " -D"
        IF NOT ERRORLEVEL 1 EXIT /B 1
        CALL fn-str-contains "%c%" " --delete"
        IF NOT ERRORLEVEL 1 EXIT /B 1
        EXIT /B 0
    )

    :: Allow switching branches ONLY (no deletes)
    IF "%t%"=="switch" (
        CALL fn-str-contains "%c%" " -d"
        IF NOT ERRORLEVEL 1 EXIT /B 1
        CALL fn-str-contains "%c%" " -D"
        IF NOT ERRORLEVEL 1 EXIT /B 1
        CALL fn-str-contains "%c%" " --delete"
        IF NOT ERRORLEVEL 1 EXIT /B 1
        EXIT /B 0
    )

    IF "%t%"=="tag" (
        CALL fn-str-contains "%c%" " -d"
        IF NOT ERRORLEVEL 1 EXIT /B 1
        CALL fn-str-contains "%c%" " -a"
        IF NOT ERRORLEVEL 1 EXIT /B 1
        CALL fn-str-contains "%c%" " -s"
        IF NOT ERRORLEVEL 1 EXIT /B 1
        EXIT /B 0
    )

    :: Everything else: confirm
    EXIT /B 1

:ToLower
    :: Usage: call :ToLower varName
    set "s=!%~1!"
    set "s=!s:A=a!"
    set "s=!s:B=b!"
    set "s=!s:C=c!"
    set "s=!s:D=d!"
    set "s=!s:E=e!"
    set "s=!s:F=f!"
    set "s=!s:G=g!"
    set "s=!s:H=h!"
    set "s=!s:I=i!"
    set "s=!s:J=j!"
    set "s=!s:K=k!"
    set "s=!s:L=l!"
    set "s=!s:M=m!"
    set "s=!s:N=n!"
    set "s=!s:O=o!"
    set "s=!s:P=p!"
    set "s=!s:Q=q!"
    set "s=!s:R=r!"
    set "s=!s:S=s!"
    set "s=!s:T=t!"
    set "s=!s:U=u!"
    set "s=!s:V=v!"
    set "s=!s:W=w!"
    set "s=!s:X=x!"
    set "s=!s:Y=y!"
    set "s=!s:Z=z!"
    set "%~1=%s%"
    exit /b 0
