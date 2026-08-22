:: FnEtcFlagsPick <SHORT_FLAG_NAME> <LONG_FLAG_NAME>
:: -- Copies FLAG_<SHORT> into FLAG_<LONG> when FLAG_<LONG> is not already set, so
:: -- callers only ever have to read the canonical long name.
:: -- Returns updated FLAG_<LONG_FLAG_NAME>
:: --
:: -- NOTE: No SETLOCAL here, for the same reason as FnEtcFlags -- the implicit
:: --       ENDLOCAL on return would discard the value this script exists to set.

@ECHO OFF

IF "%~1"=="" GOTO :MISSING_SHORT
IF "%~2"=="" GOTO :MISSING_LONG

SET "LPRE_PICK_SHORT=%~1"
SET "LPRE_PICK_LONG=%~2"
SET "LPRE_PICK_SHORT=%LPRE_PICK_SHORT:-=_%"
SET "LPRE_PICK_LONG=%LPRE_PICK_LONG:-=_%"

:: CALL doubles the parse pass, turning %%FLAG_ORG%% into the value of FLAG_ORG.
CALL SET "LPRE_PICK_VALUE=%%FLAG_%LPRE_PICK_LONG%%%"
IF DEFINED LPRE_PICK_VALUE GOTO :DONE

CALL SET "LPRE_PICK_VALUE=%%FLAG_%LPRE_PICK_SHORT%%%"
IF NOT DEFINED LPRE_PICK_VALUE GOTO :DONE

SET "FLAG_%LPRE_PICK_LONG%=%LPRE_PICK_VALUE%"

:DONE
    CALL :CLEANUP
    EXIT /B 0

:MISSING_SHORT
    ECHO LeprechaunCLI:FnEtcFlagsPick[E]: Missing required short flag argument
    CALL :CLEANUP
    EXIT /B 1

:MISSING_LONG
    ECHO LeprechaunCLI:FnEtcFlagsPick[E]: Missing required long flag argument
    CALL :CLEANUP
    EXIT /B 1

:CLEANUP
    SET "LPRE_PICK_SHORT="
    SET "LPRE_PICK_LONG="
    SET "LPRE_PICK_VALUE="
    EXIT /B 0
