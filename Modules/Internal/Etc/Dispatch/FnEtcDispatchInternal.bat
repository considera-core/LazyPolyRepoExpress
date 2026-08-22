:: FnEtcDispatchInternal <SuiteId> <ProjectId> <ModuleId> <ActionId> <Arg[]> <Flag[]>
:: leprechaun function dispatch-internal <SuiteId> <ProjectId> <ModuleId> <ActionId> <Arg[]> <Flag[]>
:: -- Validates the module and hands off to the module's dispatch function.

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    CALL leprechaun function resolve Module "%Function_ModuleId%"
    CALL leprechaun function resolve Suite "%Function_SuiteId%"
    CALL leprechaun function resolve Project "%Function_SuiteId%" "%Function_ProjectId%"
    CALL leprechaun function resolve ProjectModule "%Function_SuiteId%" "%Function_ProjectId%" "%Function_ModuleId%"
    IF ERRORLEVEL 1 GOTO Destructor 1

    CALL leprechaun function "%Function_ModuleId%" dispatch "%Function_SuiteId%" "%Function_ProjectId%" "%Function_ActionId%" %Function_Args%
    IF ERRORLEVEL 1 GOTO Destructor 1

    GOTO Destructor 0

:Constructor
    SET "Function_SuiteId=%~1"
    SET "Function_ProjectId=%~2"
    SET "Function_ModuleId=%~3"
    SET "Function_ActionId=%~4"
    SET "Function_Args="
    SHIFT
    SHIFT
    SHIFT
    SHIFT
    CALL leprechaun function flags %*
    SET "Function_Args=%*"
    GOTO ConstructorValidate

:Validate
    IF NOT DEFINED Function_SuiteId GOTO Destructor 1 "Missing required argument ^<SuiteId^>"
    IF NOT DEFINED Function_ProjectId GOTO Destructor 1 "Missing required argument ^<ProjectId^>"
    IF NOT DEFINED Function_ModuleId GOTO Destructor 1 "Missing required argument ^<ModuleId^>"
    IF NOT DEFINED Function_ActionId GOTO Destructor 1 "Missing required argument ^<ActionId^>"
    GOTO Main

:Destructor
    SET "Function_SuiteId="
    SET "Function_ProjectId="
    SET "Function_ModuleId="
    SET "Function_ActionId="
    SET "Function_Args="
    IF %~1 NEQ 0 (
        CALL leprechaun function log error FnEtcDispatchInternal %~2
    )
    EXIT /B %~1