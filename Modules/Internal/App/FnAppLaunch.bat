:: FnAppLaunch <SuiteId> <ProjectId> <Arg[]> <Flag[]>
:: leprechaun function app launch <SuiteId> <ProjectId> <Arg[]>
:: -- Launches an app in a project based on its' type.
:: -- Flags:
:: --   --here:               run in this window instead of spawning a new one
:: --   -v, --verbose:        verbose
:: --   -d, --dry-run:        report what would run, do not run it

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    CALL FnEtcExecFramework "%Output_Resolved_FrameworkId%" "%Output_Resolved_ProjectRootPath%"
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Destructor

:Constructor
    CALL FnEtcFlags %*
    SET "Input_SuiteId=%GLOBAL_FlagArg1%"
    SET "Input_ProjectId=%GLOBAL_FlagArg2%"
    SET "Input_Here=%GLOBAL_FlagHere%"
    SET "Input_Args=%GLOBAL_FlagArgsTail%"
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
    CALL FnEtcResolveSuite "%Input_SuiteId%"
    IF ERRORLEVEL 1 GOTO Failure
    CALL FnEtcResolveProject "%Input_SuiteId%" "%Input_ProjectId%"
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Main

:Failure
    SET "Input_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Input_Error CALL FnEtcLogError FnAppLaunch "%Input_Error%"
    EXIT /B %Input_ReturnCode%