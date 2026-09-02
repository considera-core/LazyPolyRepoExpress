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

    IF NOT DEFINED GLOBAL_DataOrgs (
        SET "Function_Error=No organizations are defined"
        GOTO Failure
    )

    FOR %%O IN (%GLOBAL_DataOrgs%) DO (
        CALL %Function_FunctionName% "%%O" %Function_Tail%
        IF ERRORLEVEL 1 SET "Function_ReturnCode=1"
    )

    GOTO Destructor

:Constructor
    SET "Function_FunctionName=%~1"
    SET "Function_Tail="
    SET "Function_Error="
    SET "Function_ReturnCode=0"
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
    IF NOT DEFINED Function_FunctionName (
        SET "Function_Error=Missing required argument <FunctionName>"
        GOTO Failure
    )
    GOTO Main

:Failure
    SET "Function_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Function_Error CALL FnEtcLogError FnEtcForEachOrganization "%Function_Error%"
    SET "Function_FunctionName="
    SET "Function_Tail="
    SET "Function_Error="
    EXIT /B %Function_ReturnCode%
