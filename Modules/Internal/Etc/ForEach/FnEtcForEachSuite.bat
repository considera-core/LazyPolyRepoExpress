:: FnEtcForEachSuite <ORG> <FN> ARGS... -p PROJECTS... FLAGS...
:: -- Invokes FN once per active suite in the organization:
:: --   FN SUITE ARGS... -p PROJECTS... FLAGS...
:: --
:: -- Suites whose Active column is not true are skipped.

@ECHO OFF
SETLOCAL EnableExtensions

SET "FUNCTION_ORG=%~1"
SET "FUNCTION_FN=%~2"
SET "FUNCTION_TAIL="
SET "FUNCTION_RETURN_CODE=0"

SHIFT
SHIFT

IF NOT DEFINED FUNCTION_ORG (
    ECHO LeprechaunCLI:FnEtcForEachSuite[E]: Missing required argument ^<ORG^>
    EXIT /B 1
)

IF NOT DEFINED FUNCTION_FN (
    ECHO LeprechaunCLI:FnEtcForEachSuite[E]: Missing required argument ^<FN^>
    EXIT /B 1
)

:: Get the rest of the arguments into a single variable
:COLLECT
    IF [%1]==[] GOTO :COLLECTED
    SET "FUNCTION_TAIL=%FUNCTION_TAIL% %1"
    SHIFT
    GOTO :COLLECT

:COLLECTED
    :: Trim leading space
    IF DEFINED FUNCTION_TAIL SET "FUNCTION_TAIL=%FUNCTION_TAIL:~1%"

    :: Resolve Organization Suites
    CALL FnEtcCsvSuites "%FUNCTION_ORG%"
    IF ERRORLEVEL 1 EXIT /B 1

    SET "FUNCTION_LIST=%LPRE_SUITES_ACTIVE%"
    IF NOT DEFINED FUNCTION_LIST (
        ECHO LeprechaunCLI:FnEtcForEachSuite[E]: No active suites in organization "%FUNCTION_ORG%"
        EXIT /B 1
    )

    FOR %%S IN (%FUNCTION_LIST%) DO (
        CALL %FUNCTION_FN% "%%S" %FUNCTION_TAIL%
        IF ERRORLEVEL 1 SET "FUNCTION_RETURN_CODE=1"
    )

    EXIT /B %FUNCTION_RETURN_CODE%
