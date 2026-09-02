:: FnAppRun <SuiteId> <AppId> <Arg[]> <Flag[]>
:: leprechaun function app run <SuiteId> <AppId> <Arg[]>
:: -- Launches each project in the app.
:: -- Flags:
:: --   -v, --verbose:        verbose
:: --   -d, --dry-run:        report what would run, do not run it

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    CALL FnEtcForEachProjectAppDefinition "%Function_SuiteId%" "%Function_AppId%" FnAppLaunch %Function_Args%
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Destructor

:Constructor
    CALL FnEtcFlags %*
    SET "Function_SuiteId=%GLOBAL_FlagArg1%"
    SET "Function_AppId=%GLOBAL_FlagArg2%"
    SET "Function_Args=%GLOBAL_FlagArgsTail%"
    SET "Function_Error="
    SET "Function_ReturnCode=0"
    GOTO Validate

:Validate
    IF NOT DEFINED Function_SuiteId (
        SET "Function_Error=Missing required argument <SuiteId>"
        GOTO Failure
    )
    IF NOT DEFINED Function_AppId (
        SET "Function_Error=Missing required argument <AppId>"
        GOTO Failure
    )
    CALL FnEtcResolveSuite "%Function_SuiteId%"
    IF ERRORLEVEL 1 GOTO Failure
    CALL FnEtcResolveSuiteApp "%Function_SuiteId%" "%Function_AppId%"
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Main

:Failure
    SET "Function_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Function_Error CALL FnEtcLogError FnAppLaunch "%Function_Error%"
    SET "Function_SuiteId="
    SET "Function_AppId="
    SET "Function_Args="
    SET "Function_Error="
    SET "Function_ReturnCode=0"
    EXIT /B %Function_ReturnCode%
