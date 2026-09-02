:: FnEtcDispatchInternal <SuiteId> <ProjectId> <ModuleId> <ActionId> <Arg[]> <Flag[]>
:: leprechaun function dispatch-internal <SuiteId> <ProjectId> <ModuleId> <ActionId> <Arg[]> <Flag[]>
:: -- Validates the module and hands off to the module's dispatch function.
:: -- <ProjectId> may be empty, which is the fan out form: the module dispatcher
:: -- passes it through and the leaf recurses to its single project base case.

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    CALL leprechaun function resolve Module "%Function_ModuleId%"
    IF ERRORLEVEL 1 GOTO Failure

    CALL leprechaun function resolve Suite "%Function_SuiteId%"
    IF ERRORLEVEL 1 GOTO Failure

    IF DEFINED Function_ProjectId (
        CALL leprechaun function resolve Project "%Function_SuiteId%" "%Function_ProjectId%"
        IF ERRORLEVEL 1 GOTO Failure

        CALL leprechaun function resolve ProjectModuleDefinition "%Function_SuiteId%" "%Function_ProjectId%" "%Function_ModuleId%"
        IF ERRORLEVEL 1 GOTO Failure
    )

    CALL leprechaun function %Function_ModuleId% dispatch "%Function_SuiteId%" "%Function_ProjectArg%" "%Function_ActionId%" %Function_Args%
    IF ERRORLEVEL 1 GOTO Failure

    GOTO Destructor

:Constructor
    SET "Function_SuiteId=%~1"
    SET "Function_ProjectId=%~2"
    SET "Function_ModuleId=%~3"
    SET "Function_ActionId=%~4"
    SET "Function_Args="
    SET "Function_Error="
    SET "Function_ReturnCode=0"

    CALL leprechaun function flags %*

    :: %* ignores SHIFT, so the tail is collected a token at a time. %1 rather
    :: than %~1 keeps each token's own quoting intact on the way to the module.
    SHIFT
    SHIFT
    SHIFT
    SHIFT
    GOTO Collect

:Collect
    IF [%1]==[] GOTO Collected
    SET "Function_Args=%Function_Args% %1"
    SHIFT
    GOTO Collect

:Collected
    IF DEFINED Function_Args SET "Function_Args=%Function_Args:~1%"
    GOTO Validate

:Validate
    IF NOT DEFINED Function_SuiteId (
        SET "Function_Error=Missing required argument <SuiteId>"
        GOTO Failure
    )

    IF NOT DEFINED Function_ModuleId (
        SET "Function_Error=Missing required argument <ModuleId>"
        GOTO Failure
    )

    IF NOT DEFINED Function_ActionId (
        SET "Function_Error=Missing required argument <ActionId>"
        GOTO Failure
    )

    :: The module dispatcher takes ProjectId as a fixed positional, so an absent
    :: project is passed as an empty string rather than omitted.
    SET "Function_ProjectArg=%Function_ProjectId%"
    GOTO Main

:Failure
    SET "Function_ReturnCode=1"
    GOTO Destructor

:Destructor
    :: GOTO takes no arguments, so the return code travels in a variable. A
    :: called function that already logged its own failure leaves Function_Error
    :: empty, which is what keeps one fault from being reported at every layer.
    IF DEFINED Function_Error CALL leprechaun function log error FnEtcDispatchInternal "%Function_Error%"
    SET "Function_SuiteId="
    SET "Function_ProjectId="
    SET "Function_ModuleId="
    SET "Function_ActionId="
    SET "Function_ProjectArg="
    SET "Function_Args="
    SET "Function_Error="
    EXIT /B %Function_ReturnCode%
