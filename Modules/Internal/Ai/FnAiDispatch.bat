:: FnAiDispatch <SuiteId> <ProjectId> <ActionId> <Arg[]> <Flag[]>
:: -- Validates the action for the ai module and invokes the leaf function

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    CALL leprechaun function resolve Project "%Function_SuiteId%" "%Function_ProjectId%"
    IF ERRORLEVEL 1 GOTO Destructor 1

    CALL leprechaun function ai %Function_ActionId% "%Function_SuiteId%" "%Function_ProjectId%" --args %Function_Args%
    IF ERRORLEVEL 1 GOTO Destructor 1
    GOTO Destructor 0

:Constructor
    SET "Function_SuiteId=%~1"
    SET "Function_ProjectId=%~2"
    SET "Function_ActionId=%~3"
    SET "Function_Args="
    SHIFT
    SHIFT
    SHIFT
    CALL leprechaun function flags %*
    SET "Function_Args=%*"
    GOTO Validate

:Validate
    IF NOT DEFINED Function_SuiteId GOTO Destructor 1 "Missing required argument ^<SuiteId^>"
    IF NOT DEFINED Function_ProjectId GOTO Destructor 1 "Missing required argument ^<ProjectId^>"
    IF NOT DEFINED Function_ActionId GOTO Destructor 1 "Missing required argument ^<ActionId^>"
    GOTO Main

:Destructor
    SET "Function_SuiteId="
    SET "Function_ProjectId="
    SET "Function_ActionId="
    SET "Function_Args="
    IF %~1 NEQ 0 (
        CALL leprechaun function log error FnAiDispatch %~2
    )
    EXIT /B %~1
