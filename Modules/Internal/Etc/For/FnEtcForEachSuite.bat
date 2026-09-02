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
    CALL FnEtcDataSuites "%Function_OrgId%"
    IF ERRORLEVEL 1 GOTO Failure

    :: No active suites is a valid empty collection, not a failure: the name was
    :: already resolved upstream, so this is a real organization that simply has
    :: nothing scaffolded yet. A global fan out must not stop on it.
    IF NOT DEFINED GLOBAL_DataSuitesActive (
        CALL FnEtcLogInfo FnEtcForEachSuite "No active suites in organization %Function_OrgId%, skipping"
        GOTO Destructor
    )

    FOR %%S IN (%GLOBAL_DataSuitesActive%) DO (
        CALL %Function_FunctionName% "%%S" %Function_Tail%
        IF ERRORLEVEL 1 SET "Function_ReturnCode=1"
    )

    GOTO Destructor

:Constructor
    SET "Function_OrgId=%~1"
    SET "Function_FunctionName=%~2"
    SET "Function_Tail="
    SET "Function_Error="
    SET "Function_ReturnCode=0"
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
    IF NOT DEFINED Function_OrgId (
        SET "Function_Error=Missing required argument <OrgId>"
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
    IF DEFINED Function_Error CALL FnEtcLogError FnEtcForEachSuite "%Function_Error%"
    SET "Function_OrgId="
    SET "Function_FunctionName="
    SET "Function_Tail="
    SET "Function_Error="
    EXIT /B %Function_ReturnCode%
