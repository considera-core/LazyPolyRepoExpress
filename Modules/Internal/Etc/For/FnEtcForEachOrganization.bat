:: FnEtcForEachOrganization <FunctionName> <Arg[]> <Flag[]>
:: leprechaun function for Organizations <FunctionName> <Arg[]> <Flag[]>
:: -- Invokes FunctionName once per organization:
:: --   FunctionName OrgId ARGS... FLAGS...

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    CALL FnEtcDataOrganizations
    IF ERRORLEVEL 1 GOTO Failure

    IF NOT DEFINED Output_Data_Orgs (
        SET "Input_Error=No organizations are defined"
        GOTO Failure
    )

    FOR %%O IN (%Output_Data_Orgs%) DO (
        CALL %Input_FunctionName% "%%O" %Input_Tail%
        IF ERRORLEVEL 1 SET "Input_ReturnCode=1"
    )

    GOTO Destructor

:Constructor
    SET "Input_FunctionName=%~1"
    SET "Input_Tail="
    SET "Input_Error="
    SET "Input_ReturnCode=0"
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
    IF NOT DEFINED Input_FunctionName (
        SET "Input_Error=Missing required argument <FunctionName>"
        GOTO Failure
    )
    GOTO Main

:Failure
    SET "Input_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Input_Error CALL FnEtcLogError FnEtcForEachOrganization "%Input_Error%"
    SET "Input_FunctionName="
    SET "Input_Tail="
    SET "Input_Error="
    EXIT /B %Input_ReturnCode%
