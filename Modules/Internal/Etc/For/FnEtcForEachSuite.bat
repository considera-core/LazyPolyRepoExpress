:: FnEtcForEachSuite <OrgId> <FunctionName> <Arg[]> <Flag[]>
:: leprechaun function for Suites <OrgId> <FunctionName> <Arg[]> <Flag[]>
:: -- Invokes FunctionName once per ACTIVE suite in the organization:
:: --   FunctionName SuiteId ARGS... FLAGS...
:: --
:: -- Suites whose Active column is not true are skipped, so a suite may be
:: -- declared in Suites.csv before it has been scaffolded on disk.

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    CALL FnEtcDataSuites "%Input_OrgId%"
    IF ERRORLEVEL 1 GOTO Failure

    :: No active suites is a valid empty collection, not a failure: the name was
    :: already resolved upstream, so this is a real organization that simply has
    :: nothing scaffolded yet. A global fan out must not stop on it.
    IF NOT DEFINED Output_Data_SuitesActive (
        CALL FnEtcLogInfo FnEtcForEachSuite "No active suites in organization %Input_OrgId%, skipping"
        GOTO Destructor
    )

    FOR %%S IN (%Output_Data_SuitesActive%) DO (
        CALL %Input_FunctionName% "%%S" %Input_Tail%
        IF ERRORLEVEL 1 SET "Input_ReturnCode=1"
    )

    GOTO Destructor

:Constructor
    SET "Input_OrgId=%~1"
    SET "Input_FunctionName=%~2"
    SET "Input_Tail="
    SET "Input_Error="
    SET "Input_ReturnCode=0"
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
    IF NOT DEFINED Input_OrgId (
        SET "Input_Error=Missing required argument <OrgId>"
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
    IF DEFINED Input_Error CALL FnEtcLogError FnEtcForEachSuite "%Input_Error%"
    SET "Input_OrgId="
    SET "Input_FunctionName="
    SET "Input_Tail="
    SET "Input_Error="
    EXIT /B %Input_ReturnCode%
