:: FnAppDispatch <SuiteId> <ProjectId | AppId> <ActionId> <Arg[]> <Flag[]>
:: leprechaun function app dispatch <SuiteId> <ProjectId | AppId> <ActionId> <Arg[]> <Flag[]>
:: -- Validates the action for the app module and invokes the function against the project

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    IF /I "%Input_ActionId%"=="run" (
        CALL leprechaun function app run "%Input_SuiteId%" "%Input_AppId%" %Input_Args%
        IF ERRORLEVEL 1 GOTO Failure
    )
    IF /I "%Input_ActionId%"=="launch" (
        CALL leprechaun function app launch "%Input_SuiteId%" "%Input_ProjectId%" %Input_Args%
        IF ERRORLEVEL 1 GOTO Failure
    )
    GOTO Destructor

:Constructor
    CALL FnEtcFlags %*
    SET "Input_SuiteId=%GLOBAL_FlagArg1%"
    SET "Input_ProjectId=%GLOBAL_FlagArg2%"
    SET "Input_AppId=%GLOBAL_FlagArg2%"
    SET "Input_ActionId=%GLOBAL_FlagArg3%"
    SET "Input_Args=%GLOBAL_FlagArgs%"
    SET "Input_DryRun=%GLOBAL_FlagDryRun%"
    SET "Input_Verbose=%GLOBAL_FlagVerbose%"
    SET "Input_Error="
    SET "Input_ReturnCode=0"
    GOTO Validate

:Validate
    IF NOT DEFINED Input_SuiteId (
        SET "Input_Error=Missing required argument <SuiteId>"
        GOTO Failure
    )
    IF NOT DEFINED Input_ProjectId (
        SET "Input_Error=Missing required argument <ProjectId>"
        GOTO Failure
    )
    IF NOT DEFINED Input_ActionId (
        SET "Input_Error=Missing required argument <ActionId>"
        GOTO Failure
    )
    CALL FnEtcResolveSuite "%Input_SuiteId%"
    IF ERRORLEVEL 1 GOTO Failure
    CALL FnEtcResolveProject "%Input_SuiteId%" "%Input_ProjectId%"
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Main

:Failure
    SET "Input_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Input_Error CALL FnEtcLogError FnAppDispatch "%Input_Error%"
    EXIT /B %Input_ReturnCode%
