:: FnEtcForEachProject <SuiteId> <FunctionName> <Arg[]> <Flag[]> 
:: FnEtcForEachProject <SuiteId> <FunctionName> --projects <ProjectId[]> <Arg[]> <Flag[]> 
:: leprechaun function for Projects <SuiteId> <FunctionName> <Arg[]> <Flag[]>
:: leprechaun function for Projects <SuiteId> <FunctionName> --projects <ProjectId[]> <Arg[]> <Flag[]>
:: -- Invokes FunctionName once per internal project in the suite:
:: --   FunctionName SuiteId Project ARGS... FLAGS...
:: --
:: -- This is how a leaf Fn reaches its single project base case. A leaf called
:: -- without a project calls back here with its own name, and each expansion
:: -- re-enters that leaf with one project.

@ECHO OFF
SETLOCAL EnableExtensions

SET "Function_SuiteId=%~1"
SET "Function_FunctionName=%~2"
SET "Function_Tail="
SET "Function_ReturnCode=0"

SHIFT
SHIFT

IF NOT DEFINED Function_SuiteId (
    CALL FnEtcLogError "FnEtcForEachProject" "Missing required argument ^<SuiteId^>"
    EXIT /B 1
)

IF NOT DEFINED Function_FunctionName (
    CALL FnEtcLogError "FnEtcForEachProject" "Missing required argument ^<FunctionName^>"
    EXIT /B 1
)

:: Get the rest of the arguments into a single variable
:COLLECT
    IF [%1]==[] GOTO :COLLECTED
    SET "Function_Tail=%Function_Tail% %1"
    SHIFT
    GOTO :COLLECT

:COLLECTED
    :: Trim leading space
    IF DEFINED Function_Tail SET "Function_Tail=%Function_Tail:~1%"

    :: Resolve Suite & Organization
    CALL FnEtcResolveSuite "%Function_SuiteId%"
    IF ERRORLEVEL 1 EXIT /B 1

    :: Resolve Suite Projects
    CALL FnEtcCsvProjects "%GLOBAL_ResolvedSuiteOrgId%" "%Function_SuiteId%"
    IF ERRORLEVEL 1 EXIT /B 1

    SET "Local_List=%GLOBAL_PROJECTS_INTERNAL%"
    IF NOT DEFINED Local_List (
        CALL FnEtcLogError "FnEtcForEachProject" "No internal projects in suite ^<%Function_SuiteId%^>"
        EXIT /B 1
    )

    FOR %%P IN (%Local_List%) DO (
        CALL %Function_FunctionName% "%Function_SuiteId%" "%%P" %Function_Tail%
        IF ERRORLEVEL 1 SET "Function_ReturnCode=1"
    )

    GOTO Destructor 1

:Destructor
    SET "Function_SuiteId="
    SET "Function_FunctionName="
    SET "Function_Tail="
    SET "Local_List="
    EXIT /B %~1
