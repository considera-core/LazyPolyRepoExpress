:: FnTestRun SUITE [PROJECT] [NAMES...] [FLAGS...]
:: -- Runs the schema test suite under Test/Cases.
:: --   no NAMES   -> every case, in every group
:: --   1+ NAMES   -> only those groups or individual cases
:: -- mirroring the all / 1+ semantics of the -p projects flag.
:: --
:: -- Each case is one pipe delimited line:  NAME|INPUT|RC|EXPECT
:: --   INPUT  a full command line, run as typed
:: --   RC     the exit code it must produce
:: --   EXPECT a substring its output must contain (blank to skip the check)
:: --
:: -- Cases assert against the -d resolution contract, so they exercise the real
:: -- grammar without needing every leaf function to exist.

@ECHO OFF
SETLOCAL EnableExtensions

CALL FnEtcFlags %*
IF ERRORLEVEL 1 EXIT /B 1

SET "T_SUITE=%FLAG_ARG_1%"
IF NOT DEFINED T_SUITE GOTO :MISSING_SUITE

SET "T_CASES=%~dp0Cases"
IF NOT EXIST "%T_CASES%" GOTO :NO_CASES

:: Re-entry guard. Fn<Module>Dispatch invokes the leaf even under -d, and one of
:: the grammar cases is "test run", so without this the suite would run itself
:: recursively. The case still gets its LPRE:RESOLVE line to assert against.
IF DEFINED LPRE_IN_TEST GOTO :NESTED
SET "LPRE_IN_TEST=1"

SET "T_VERBOSE=%FLAG_VERBOSE%"
SET "T_OUT=%TEMP%\lpre-test-%RANDOM%%RANDOM%.out"

CALL :SELECTIONS

SET "T_PASS=0"
SET "T_FAIL=0"
SET "T_RAN=0"
SET "T_MATCHED="

ECHO LeprechaunCLI:FnTestRun[I]: suite=%T_SUITE%
IF DEFINED T_SELECT ECHO LeprechaunCLI:FnTestRun[I]: selection=%T_SELECT%

FOR %%F IN ("%T_CASES%\*.cases") DO CALL :GROUP "%%~nF" "%%~fF"

IF EXIST "%T_OUT%" DEL /Q "%T_OUT%" >NUL 2>&1

IF DEFINED T_SELECT IF NOT DEFINED T_MATCHED GOTO :NO_MATCH

ECHO.
ECHO LeprechaunCLI:FnTestRun[I]: %T_PASS% passed, %T_FAIL% failed, %T_RAN% total
IF NOT "%T_FAIL%"=="0" EXIT /B 1
EXIT /B 0

:GROUP
    SET "T_GROUP=%~1"
    SET "T_GROUP_SELECTED="
    :: A selection matches either a whole group or individual case names inside it.
    IF NOT DEFINED T_SELECT SET "T_GROUP_SELECTED=1"
    IF DEFINED T_SELECT CALL :IS_LISTED "%T_GROUP%" "%T_SELECT%"
    IF DEFINED T_SELECT IF NOT ERRORLEVEL 1 SET "T_GROUP_SELECTED=1"
    IF DEFINED T_GROUP_SELECTED SET "T_MATCHED=1"
    :: Header is printed by :HEADER on the first case that actually runs, so an
    :: unselected group leaves no empty section behind.
    SET "T_GROUP_SHOWN="
    FOR /F "usebackq tokens=1-4 delims=| eol=#" %%A IN ("%~2") DO CALL :CASE "%%A" "%%B" "%%C" "%%D"
    EXIT /B 0

:CASE
    SET "TC_NAME=%~1"
    IF NOT DEFINED TC_NAME EXIT /B 0
    IF DEFINED T_GROUP_SELECTED GOTO :CASE_RUN
    :: Group not selected wholesale; run only if this case was named directly.
    CALL :IS_LISTED "%TC_NAME%" "%T_SELECT%"
    IF ERRORLEVEL 1 EXIT /B 0
    SET "T_MATCHED=1"

:CASE_RUN
    SET "TC_INPUT=%~2"
    SET "TC_RC=%~3"
    SET "TC_EXPECT=%~4"
    IF NOT DEFINED TC_INPUT GOTO :CASE_MALFORMED
    IF NOT DEFINED TC_RC SET "TC_RC=0"

    CALL :HEADER
    SET /A T_RAN+=1
    CALL %TC_INPUT% > "%T_OUT%" 2>&1
    SET "TC_ACTUAL=%ERRORLEVEL%"

    IF NOT "%TC_ACTUAL%"=="%TC_RC%" GOTO :CASE_FAIL_RC
    IF NOT DEFINED TC_EXPECT GOTO :CASE_PASS
    :: An EXPECT starting with ! asserts the substring is absent, which is how a
    :: case proves something was skipped rather than merely not looked for.
    IF "%TC_EXPECT:~0,1%"=="!" GOTO :CASE_EXPECT_ABSENT
    FINDSTR /C:"%TC_EXPECT%" "%T_OUT%" >NUL 2>&1
    IF ERRORLEVEL 1 GOTO :CASE_FAIL_EXPECT
    GOTO :CASE_PASS

:CASE_EXPECT_ABSENT
    SET "TC_NEEDLE=%TC_EXPECT:~1%"
    FINDSTR /C:"%TC_NEEDLE%" "%T_OUT%" >NUL 2>&1
    IF NOT ERRORLEVEL 1 GOTO :CASE_FAIL_PRESENT

:CASE_PASS
    SET /A T_PASS+=1
    ECHO     PASS  %TC_NAME%
    IF DEFINED T_VERBOSE ECHO           $ %TC_INPUT%
    EXIT /B 0

:CASE_FAIL_RC
    SET /A T_FAIL+=1
    ECHO     FAIL  %TC_NAME%
    ECHO           $ %TC_INPUT%
    ECHO           expected rc=%TC_RC%, got rc=%TC_ACTUAL%
    CALL :DUMP
    EXIT /B 0

:CASE_FAIL_EXPECT
    SET /A T_FAIL+=1
    ECHO     FAIL  %TC_NAME%
    ECHO           $ %TC_INPUT%
    ECHO           output did not contain: %TC_EXPECT%
    CALL :DUMP
    EXIT /B 0

:CASE_FAIL_PRESENT
    SET /A T_FAIL+=1
    ECHO     FAIL  %TC_NAME%
    ECHO           $ %TC_INPUT%
    ECHO           output should not have contained: %TC_NEEDLE%
    CALL :DUMP
    EXIT /B 0

:CASE_MALFORMED
    SET /A T_FAIL+=1
    ECHO     FAIL  %TC_NAME%
    ECHO           malformed case, expected NAME^|INPUT^|RC^|EXPECT
    EXIT /B 0

:DUMP
    FOR /F "usebackq delims=" %%L IN ("%T_OUT%") DO ECHO           ^| %%L
    EXIT /B 0

:SELECTIONS
    :: Positionals after SUITE are selections. The first is a PROJECT instead if
    :: it names a project in this suite, per the Docs.md 1-Project form.
    SET "T_SELECT="
    IF %FLAG_ARGC% LSS 2 GOTO :SELECTIONS_ARGS
    CALL FnEtcResolveSuite "%T_SUITE%" >NUL 2>&1
    IF NOT ERRORLEVEL 1 CALL FnEtcCsvProjects "%Output_Resolved_SuiteOrgId%" "%T_SUITE%" >NUL 2>&1
    FOR /L %%I IN (2,1,%FLAG_ARGC%) DO CALL :SELECT %%I

:SELECTIONS_ARGS
    :: Names may also arrive through -a, which is how the dispatcher forwards ARGS.
    IF DEFINED FLAG_ARGS FOR %%A IN (%FLAG_ARGS%) DO SET "T_SELECT=%T_SELECT% %%A"
    IF DEFINED T_SELECT SET "T_SELECT=%T_SELECT:~1%"
    EXIT /B 0

:SELECT
    CALL SET "T_TOK=%%FLAG_ARG_%~1%%"
    IF NOT DEFINED T_TOK EXIT /B 0
    IF "%~1"=="2" CALL :IS_LISTED "%T_TOK%" "%GLOBAL_PROJECTS%"
    IF "%~1"=="2" IF NOT ERRORLEVEL 1 EXIT /B 0
    SET "T_SELECT=%T_SELECT% %T_TOK%"
    EXIT /B 0

:HEADER
    IF DEFINED T_GROUP_SHOWN EXIT /B 0
    SET "T_GROUP_SHOWN=1"
    ECHO.
    ECHO   [%T_GROUP%]
    EXIT /B 0

:IS_LISTED
    IF "%~1"=="" EXIT /B 1
    FOR %%K IN (%~2) DO IF /I "%%K"=="%~1" EXIT /B 0
    EXIT /B 1

:NO_MATCH
    ECHO.
    ECHO LeprechaunCLI:FnTestRun[E]: No test group or case matched "%T_SELECT%"
    EXIT /B 1

:NESTED
    ECHO LeprechaunCLI:FnTestRun[I]: nested run suppressed
    EXIT /B 0

:NO_CASES
    ECHO LeprechaunCLI:FnTestRun[E]: Cases directory not found at %T_CASES%
    EXIT /B 1

:MISSING_SUITE
    ECHO LeprechaunCLI:FnTestRun[E]: Missing required argument ^<SUITE^>
    EXIT /B 1
