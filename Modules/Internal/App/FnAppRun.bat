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
    CALL FnEtcForEachProjectAppDefinition "%Input_SuiteId%" "%Input_AppId%" FnAppLaunch %Input_Args%
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Destructor

:Constructor
    CALL FnEtcFlags %*
    SET "Input_SuiteId=%GLOBAL_FlagArg1%"
    SET "Input_AppId=%GLOBAL_FlagArg2%"
    SET "Input_Args=%GLOBAL_FlagArgsTail%"
    SET "Input_Error="
    SET "Input_ReturnCode=0"
    GOTO Validate

:Validate
    IF NOT DEFINED Input_SuiteId (
        SET "Input_Error=Missing required argument <SuiteId>"
        GOTO Failure
    )
    IF NOT DEFINED Input_AppId (
        SET "Input_Error=Missing required argument <AppId>"
        GOTO Failure
    )
    CALL FnEtcResolveSuite "%Input_SuiteId%"
    IF ERRORLEVEL 1 GOTO Failure
    CALL FnEtcResolveSuiteApp "%Input_SuiteId%" "%Input_AppId%"
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Main

:Failure
    SET "Input_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Input_Error CALL FnEtcLogError FnAppLaunch "%Input_Error%"
    SET "Input_SuiteId="
    SET "Input_AppId="
    SET "Input_Args="
    SET "Input_Error="
    SET "Input_ReturnCode=0"
    EXIT /B %Input_ReturnCode%
