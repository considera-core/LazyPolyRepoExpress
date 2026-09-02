:: FnAppDispatch <SuiteId> <ProjectId | AppId> <ActionId> <Arg[]> <Flag[]>
:: leprechaun function app dispatch <SuiteId> <ProjectId | AppId> <ActionId> <Arg[]> <Flag[]>
:: -- Validates the action for the app module and invokes the function against the project

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    IF /I "%Function_ActionId%"=="run" (
        CALL leprechaun function app run "%Function_SuiteId%" "%Function_AppId%" %Function_Args%
        IF ERRORLEVEL 1 GOTO Failure
    )
    IF /I "%Function_ActionId%"=="launch" (
        CALL leprechaun function app launch "%Function_SuiteId%" "%Function_ProjectId%" %Function_Args%
        IF ERRORLEVEL 1 GOTO Failure
    )
    GOTO Destructor

:Constructor
    CALL FnEtcFlags %*
    SET "Function_SuiteId=%GLOBAL_FlagArg1%"
    SET "Function_ProjectId=%GLOBAL_FlagArg2%"
    SET "Function_AppId=%GLOBAL_FlagArg2%"
    SET "Function_ActionId=%GLOBAL_FlagArg3%"
    SET "Function_Args=%GLOBAL_FlagArgs%"
    SET "Function_DryRun=%GLOBAL_FlagDryRun%"
    SET "Function_Verbose=%GLOBAL_FlagVerbose%"
    SET "Function_Error="
    SET "Function_ReturnCode=0"
    GOTO Validate

:Validate
    IF NOT DEFINED Function_SuiteId (
        SET "Function_Error=Missing required argument <SuiteId>"
        GOTO Failure
    )
    IF NOT DEFINED Function_ProjectId (
        SET "Function_Error=Missing required argument <ProjectId>"
        GOTO Failure
    )
    IF NOT DEFINED Function_ActionId (
        SET "Function_Error=Missing required argument <ActionId>"
        GOTO Failure
    )
    CALL FnEtcResolveSuite "%Function_SuiteId%"
    IF ERRORLEVEL 1 GOTO Failure
    CALL FnEtcResolveProject "%Function_SuiteId%" "%Function_ProjectId%"
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Main

:Failure
    SET "Function_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Function_Error CALL FnEtcLogError FnAppDispatch "%Function_Error%"
    EXIT /B %Function_ReturnCode%
