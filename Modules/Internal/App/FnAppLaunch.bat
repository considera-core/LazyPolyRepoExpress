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
    CALL FnEtcExecFramework "%GLOBAL_ResolvedFrameworkId%" "%GLOBAL_ResolvedProjectRootPath%"
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Destructor

:Constructor
    CALL FnEtcFlags %*
    SET "Function_SuiteId=%GLOBAL_FlagArg1%"
    SET "Function_ProjectId=%GLOBAL_FlagArg2%"
    SET "Function_Here=%GLOBAL_FlagHere%"
    SET "Function_Args=%GLOBAL_FlagArgsTail%"
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
    CALL FnEtcResolveSuite "%Function_SuiteId%"
    IF ERRORLEVEL 1 GOTO Failure
    CALL FnEtcResolveProject "%Function_SuiteId%" "%Function_ProjectId%"
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Main

:Failure
    SET "Function_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Function_Error CALL FnEtcLogError FnAppLaunch "%Function_Error%"
    EXIT /B %Function_ReturnCode%