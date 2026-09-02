:: FnEtcForEachProjectAppDefinition <SuiteId> <AppId> <FunctionName> <Arg[]> <Flag[]>
:: leprechaun function for ProjectAppDefinition <SuiteId> <AppId> <FunctionName> <Arg[]> <Flag[]>
:: -- Invokes FunctionName once per internal project in the suite:
:: --   FunctionName SuiteId AppId ARGS... FLAGS...
:: --
:: -- This is how a leaf reaches its single project base case. A leaf called
:: -- without a project calls back here with its own name, and each expansion
:: -- re-enters that leaf with one project.
:: --
:: -- External projects are skipped: they are separate modules with their own
:: -- commands, reached through FnEtcDispatchExternal instead.

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    CALL FnEtcDataProjects "%Function_SuiteId%"
    IF ERRORLEVEL 1 GOTO Failure

    :: An explicit -p list wins over the suite's own internal project list, but
    :: each name in it still has to resolve.
    IF NOT DEFINED Function_List SET "Function_List=%GLOBAL_DataProjectsInternal%"

    :: No internal projects is a valid empty collection, for the same reason.
    IF NOT DEFINED Function_List (
        CALL FnEtcLogInfo FnEtcForEachProject "No internal projects in suite %Function_SuiteId%, skipping"
        GOTO Destructor
    )

    FOR %%P IN (%Function_List%) DO (
        CALL %Function_FunctionName% "%Function_SuiteId%" "%Function_AppId%" "%%P" %Function_Tail%
        IF ERRORLEVEL 1 SET "Function_ReturnCode=1"
    )

    GOTO Destructor

:Constructor
    SET "Function_SuiteId=%~1"
    SET "Function_AppId=%~2"
    SET "Function_FunctionName=%~3"
    SET "Function_Tail="
    SET "Function_List="
    SET "Function_Error="
    SET "Function_ReturnCode=0"

    CALL FnEtcFlags %*

    :: Snapshotted at once: FnEtcDataProjects calls FnEtcFlags for its own
    :: --refresh flag and does not SETLOCAL, so reading GLOBAL_FlagProjects after
    :: that call would find it already cleared.
    SET "Function_List=%GLOBAL_FlagProjects%"

    SHIFT
    SHIFT
    GOTO Collect

:Collect
    IF [%1]==[] GOTO Collected
    SET "Function_Tail=%Function_Tail% %1"
    SHIFT
    GOTO Collect

:Collected
    IF DEFINED Function_Tail SET "Function_Tail=%Function_Tail:~1%"
    GOTO Validate

:Validate
    IF NOT DEFINED Function_SuiteId (
        SET "Function_Error=Missing required argument <SuiteId>"
        GOTO Failure
    )

    IF NOT DEFINED Function_FunctionName (
        SET "Function_Error=Missing required argument <FunctionName>"
        GOTO Failure
    )
    GOTO Main

:Failure
    SET "Function_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Function_Error CALL FnEtcLogError FnEtcForEachProjectAppDefinition "%Function_Error%"
    SET "Function_SuiteId="
    SET "Function_AppId="
    SET "Function_FunctionName="
    SET "Function_Tail="
    SET "Function_List="
    SET "Function_Error="
    SET "Function_ReturnCode=0"
    EXIT /B %Function_ReturnCode%
