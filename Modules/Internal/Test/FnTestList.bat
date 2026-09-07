:: FnTestList SUITE [PROJECT] [GROUPS...] [FLAGS...]
:: -- Lists the test groups and case names under Test/Cases.
:: -- With no GROUPS every group is listed; with 1+ only those are.

@ECHO OFF
SETLOCAL EnableExtensions

CALL FnEtcFlags %*
IF ERRORLEVEL 1 EXIT /B 1

SET "T_SUITE=%FLAG_ARG_1%"
IF NOT DEFINED T_SUITE GOTO :MISSING_SUITE

SET "T_CASES=%~dp0Cases"
IF NOT EXIST "%T_CASES%" GOTO :NO_CASES

CALL :SELECTIONS
SET "T_GROUPS=0"
SET "T_COUNT=0"

FOR %%F IN ("%T_CASES%\*.cases") DO CALL :GROUP "%%~nF" "%%~fF"

ECHO.
ECHO LeprechaunCLI:FnTestList[I]: %T_COUNT% case^(s^) in %T_GROUPS% group^(s^)
EXIT /B 0

:GROUP
    IF DEFINED T_SELECT CALL :IS_LISTED "%~1" "%T_SELECT%"
    IF DEFINED T_SELECT IF ERRORLEVEL 1 EXIT /B 0
    SET /A T_GROUPS+=1
    ECHO.
    ECHO   [%~1]
    SET "T_GROUP_SHOWN=1"
    FOR /F "usebackq tokens=1,3 delims=| eol=#" %%A IN ("%~2") DO CALL :CASE "%%A" "%%B"
    EXIT /B 0

:CASE
    IF "%~1"=="" EXIT /B 0
    SET /A T_COUNT+=1
    ECHO     %~1 ^(expects rc=%~2^)
    EXIT /B 0

:SELECTIONS
    :: Positionals after SUITE are selections. The first is a PROJECT instead if
    :: it names a project in this suite, per the Docs.md 1-Project form.
    SET "T_SELECT="
    IF %FLAG_ARGC% LSS 2 EXIT /B 0
    CALL FnEtcResolveSuite "%T_SUITE%" >NUL 2>&1
    IF NOT ERRORLEVEL 1 CALL FnEtcCsvProjects "%Output_Resolved_SuiteOrgId%" "%T_SUITE%" >NUL 2>&1
    FOR /L %%I IN (2,1,%FLAG_ARGC%) DO CALL :SELECT %%I
    IF DEFINED T_SELECT SET "T_SELECT=%T_SELECT:~1%"
    EXIT /B 0

:SELECT
    CALL SET "T_TOK=%%FLAG_ARG_%~1%%"
    IF NOT DEFINED T_TOK EXIT /B 0
    IF "%~1"=="2" CALL :IS_LISTED "%T_TOK%" "%GLOBAL_PROJECTS%"
    IF "%~1"=="2" IF NOT ERRORLEVEL 1 EXIT /B 0
    SET "T_SELECT=%T_SELECT% %T_TOK%"
    EXIT /B 0

:IS_LISTED
    IF "%~1"=="" EXIT /B 1
    FOR %%K IN (%~2) DO IF /I "%%K"=="%~1" EXIT /B 0
    EXIT /B 1

:NO_CASES
    ECHO LeprechaunCLI:FnTestList[E]: Cases directory not found at %T_CASES%
    EXIT /B 1

:MISSING_SUITE
    ECHO LeprechaunCLI:FnTestList[E]: Missing required argument ^<SUITE^>
    EXIT /B 1
