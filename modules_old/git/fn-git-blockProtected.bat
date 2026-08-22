:: =====================
:: fn-git-blockProtected <cmd>
:: Returns 1 if protected delete detected, 0 otherwise
:: =====================
@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion
SET "c=%~1"
SET "blocked=0"

REM --- local branch delete ---
CALL fn-str-contains "!c!" "branch -d master" && IF NOT ERRORLEVEL 1 SET "blocked=1"
CALL fn-str-contains "!c!" "branch -d main" && IF NOT ERRORLEVEL 1 SET "blocked=1"
CALL fn-str-contains "!c!" "branch -d production-release" && IF NOT ERRORLEVEL 1 SET "blocked=1"

CALL fn-str-contains "!c!" "branch -D master" && IF NOT ERRORLEVEL 1 SET "blocked=1"
CALL fn-str-contains "!c!" "branch -D main" && IF NOT ERRORLEVEL 1 SET "blocked=1"
CALL fn-str-contains "!c!" "branch -D production-release" && IF NOT ERRORLEVEL 1 SET "blocked=1"

CALL fn-str-contains "!c!" "branch --delete master" && IF NOT ERRORLEVEL 1 SET "blocked=1"
CALL fn-str-contains "!c!" "branch --delete main" && IF NOT ERRORLEVEL 1 SET "blocked=1"
CALL fn-str-contains "!c!" "branch --delete production-release" && IF NOT ERRORLEVEL 1 SET "blocked=1"

REM --- remote delete (common patterns) ---
CALL fn-str-contains "!c!" "--delete master" && CALL fn-str-contains "!c!" "push" && IF NOT ERRORLEVEL 1 SET "blocked=1"
CALL fn-str-contains "!c!" "--delete main" && CALL fn-str-contains "!c!" "push" && IF NOT ERRORLEVEL 1 SET "blocked=1"
CALL fn-str-contains "!c!" "--delete production-release" && CALL fn-str-contains "!c!" "push" && IF NOT ERRORLEVEL 1 SET "blocked=1"

CALL fn-str-contains "!c!" ":master" && CALL fn-str-contains "!c!" "push" && IF NOT ERRORLEVEL 1 SET "blocked=1"
CALL fn-str-contains "!c!" ":main" && CALL fn-str-contains "!c!" "push" && IF NOT ERRORLEVEL 1 SET "blocked=1"
CALL fn-str-contains "!c!" ":production-release" && CALL fn-str-contains "!c!" "push" && IF NOT ERRORLEVEL 1 SET "blocked=1"

IF !blocked! NEQ 0 (
    ECHO "[DEBUG] Protected branch delete detected."
    ENDLOCAL & EXIT /B 1
)

ECHO "[DEBUG] No protected branch delete detected."
ENDLOCAL & EXIT /B 0