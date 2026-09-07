:: FnEtcForEachProject <SuiteId> <FunctionName> <Arg[]> <Flag[]>
:: FnEtcForEachProject <SuiteId> <FunctionName> --projects <ProjectId[]> <Arg[]> <Flag[]>
:: leprechaun function for Projects <SuiteId> <FunctionName> <Arg[]> <Flag[]>
:: -- Invokes FunctionName once per internal project in the suite:
:: --   FunctionName SuiteId ProjectId ARGS... FLAGS...
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
    CALL FnEtcDataProjects "%Input_SuiteId%"
    IF ERRORLEVEL 1 GOTO Failure

    :: An explicit -p list wins over the suite's own internal project list, but
    :: each name in it still has to resolve.
    IF NOT DEFINED Input_List SET "Input_List=%Output_Data_ProjectsInternal%"

    :: No internal projects is a valid empty collection, for the same reason.
    IF NOT DEFINED Input_List (
        CALL FnEtcLogInfo FnEtcForEachProject "No internal projects in suite %Input_SuiteId%, skipping"
        GOTO Destructor
    )

    FOR %%P IN (%Input_List%) DO (
        CALL %Input_FunctionName% "%Input_SuiteId%" "%%P" %Input_Tail%
        IF ERRORLEVEL 1 SET "Input_ReturnCode=1"
    )

    GOTO Destructor

:Constructor
    SET "Input_SuiteId=%~1"
    SET "Input_FunctionName=%~2"
    SET "Input_Tail="
    SET "Input_List="
    SET "Input_Error="
    SET "Input_ReturnCode=0"

    CALL FnEtcFlags %*

    :: Snapshotted at once: FnEtcDataProjects calls FnEtcFlags for its own
    :: --refresh flag and does not SETLOCAL, so reading GLOBAL_FlagProjects after
    :: that call would find it already cleared.
    SET "Input_List=%GLOBAL_FlagProjects%"

    SHIFT
    SHIFT
    GOTO Collect

:Collect
    IF [%1]==[] GOTO Collected
    SET "Input_Tail=%Input_Tail% %1"
    SHIFT
    GOTO Collect

:Collected
    IF DEFINED Input_Tail SET "Input_Tail=%Input_Tail:~1%"
    GOTO Validate

:Validate
    IF NOT DEFINED Input_SuiteId (
        SET "Input_Error=Missing required argument <SuiteId>"
        GOTO Failure
    )

    IF NOT DEFINED Input_FunctionName (
        SET "Input_Error=Missing required argument <FunctionName>"
        GOTO Failure
    )
    GOTO Main

:Failure
    SET "Input_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Input_Error CALL FnEtcLogError FnEtcForEachProject "%Input_Error%"
    SET "Input_SuiteId="
    SET "Input_FunctionName="
    SET "Input_Tail="
    SET "Input_List="
    SET "Input_Error="
    EXIT /B %Input_ReturnCode%
