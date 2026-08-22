:: FnEtcDispatchExternal --entry <global|org|suite> [--org <ORG>] [--suite <SUITE>] <COMMAND...>
:: -- Handles the External schema from Docs.md, reached when no positional is a
:: -- known module identifier. External projects (IsExternal=true in Projects.csv)
:: -- are treated as separate modules with their own set of commands.
:: --
:: --   entry  | positionals | meaning
:: --   global | 4           | ORG SUITE PROJECT COMMAND
:: --   global | 2           | ORG COMMAND            (all suites)
:: --   org    | 3           | SUITE PROJECT COMMAND
:: --   org    | 1           | COMMAND                (all suites)
:: --   suite  | 2           | PROJECT COMMAND

@ECHO OFF
SETLOCAL EnableExtensions

CALL FnEtcFlags %*
IF ERRORLEVEL 1 EXIT /B 1

SET "X_ENTRY=%FLAG_ENTRY%"
IF NOT DEFINED X_ENTRY SET "X_ENTRY=global"

SET "X_ORG=%FLAG_ORG%"
SET "X_SUITE=%FLAG_SUITE%"
SET "X_PROJECT="
SET "X_COMMAND="
SET "X_ARGS=%FLAG_ARGS%"
SET "X_FLAGS=%FLAG_PASSTHRU%"
SET "X_ARGC=%FLAG_ARGC%"

IF /I "%X_ENTRY%"=="suite" GOTO :SHAPE_SUITE
IF /I "%X_ENTRY%"=="org" GOTO :SHAPE_ORG
GOTO :SHAPE_GLOBAL

:SHAPE_SUITE
    IF NOT "%X_ARGC%"=="2" GOTO :BAD_SHAPE
    SET "X_PROJECT=%FLAG_ARG_1%"
    SET "X_COMMAND=%FLAG_ARG_2%"
    GOTO :SHAPE_DONE

:SHAPE_ORG
    IF "%X_ARGC%"=="1" GOTO :SHAPE_ORG_ALL
    IF NOT "%X_ARGC%"=="3" GOTO :BAD_SHAPE
    SET "X_SUITE=%FLAG_ARG_1%"
    SET "X_PROJECT=%FLAG_ARG_2%"
    SET "X_COMMAND=%FLAG_ARG_3%"
    GOTO :SHAPE_DONE
:SHAPE_ORG_ALL
    SET "X_COMMAND=%FLAG_ARG_1%"
    GOTO :SHAPE_DONE

:SHAPE_GLOBAL
    IF "%X_ARGC%"=="2" GOTO :SHAPE_GLOBAL_ALL
    IF NOT "%X_ARGC%"=="4" GOTO :BAD_SHAPE
    SET "X_ORG=%FLAG_ARG_1%"
    SET "X_SUITE=%FLAG_ARG_2%"
    SET "X_PROJECT=%FLAG_ARG_3%"
    SET "X_COMMAND=%FLAG_ARG_4%"
    GOTO :SHAPE_DONE
:SHAPE_GLOBAL_ALL
    SET "X_ORG=%FLAG_ARG_1%"
    SET "X_COMMAND=%FLAG_ARG_2%"
    GOTO :SHAPE_DONE

:SHAPE_DONE
    IF NOT DEFINED X_COMMAND GOTO :BAD_SHAPE
    IF NOT DEFINED X_SUITE GOTO :ALL_SUITES
    CALL :ONE_SUITE "%X_SUITE%"
    EXIT /B %ERRORLEVEL%

:ALL_SUITES
    IF NOT DEFINED X_ORG GOTO :BAD_SHAPE
    CALL FnEtcCsvSuites "%X_ORG%"
    IF ERRORLEVEL 1 EXIT /B 1
    SET "X_SUITE_LIST=%LPRE_SUITES_ACTIVE%"
    SET "X_RC=0"
    FOR %%S IN (%X_SUITE_LIST%) DO CALL :ONE_SUITE "%%S"
    EXIT /B %X_RC%

:ONE_SUITE
    CALL FnEtcResolveSuite "%~1"
    IF ERRORLEVEL 1 EXIT /B 1
    CALL FnEtcCsvProjects "%GLOBAL_ResolvedSuiteOrgId%" "%~1"
    IF ERRORLEVEL 1 EXIT /B 1
    IF NOT DEFINED X_PROJECT GOTO :ALL_EXTERNAL_PROJECTS
    CALL :ONE_PROJECT "%~1" "%X_PROJECT%"
    EXIT /B %ERRORLEVEL%

:ALL_EXTERNAL_PROJECTS
    SET "X_PROJECT_LIST=%GLOBAL_PROJECTS_EXTERNAL%"
    IF NOT DEFINED X_PROJECT_LIST EXIT /B 0
    FOR %%P IN (%X_PROJECT_LIST%) DO CALL :ONE_PROJECT "%~1" "%%P"
    EXIT /B 0

:ONE_PROJECT
    CALL SET "X_IS_EXTERNAL=%%GLOBAL_PROJECT_%~2_EXTERNAL%%"
    IF NOT DEFINED X_IS_EXTERNAL GOTO :UNKNOWN_PROJECT
    IF /I NOT "%X_IS_EXTERNAL%"=="true" GOTO :NOT_EXTERNAL
    IF DEFINED FLAG_DRY_RUN GOTO :EMIT
    CALL Fn%~2Dispatch "%~1" "%X_COMMAND%" %X_ARGS% %X_FLAGS%
    IF ERRORLEVEL 1 SET "X_RC=1"
    EXIT /B 0

:EMIT
    ECHO LPRE:EXTERNAL suite=%~1 project=%~2 command=%X_COMMAND% args=%X_ARGS% flags=%X_FLAGS%
    EXIT /B 0

:UNKNOWN_PROJECT
    ECHO LeprechaunCLI:FnEtcDispatchExternal[E]: Unknown module or project "%~2"
    ECHO   Projects: %GLOBAL_PROJECTS%
    SET "X_RC=1"
    EXIT /B 1

:NOT_EXTERNAL
    ECHO LeprechaunCLI:FnEtcDispatchExternal[E]: Project "%~2" is not external, so it has no commands of its own
    ECHO   External projects: %GLOBAL_PROJECTS_EXTERNAL%
    SET "X_RC=1"
    EXIT /B 1

:BAD_SHAPE
    ECHO LeprechaunCLI:FnEtcDispatchExternal[E]: Not a valid command for a %X_ENTRY%-level invocation
    ECHO   Internal: ^<MODULE^> ^<ACTION^> ^<ARGS...^> ^<FLAGS...^>
    ECHO   External: ^<PROJECT^> ^<COMMAND^>
    EXIT /B 1
