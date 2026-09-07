:: FnEtcDispatchInternal <SuiteId> <ProjectId> <ModuleId> <ActionId> <Arg[]> <Flag[]>
:: leprechaun function dispatch-internal <SuiteId> <ProjectId> <ModuleId> <ActionId> <Arg[]> <Flag[]>
:: -- Validates the module and hands off to the module's dispatch function.
:: -- <ProjectId> may be empty, which is the fan out form: the module dispatcher
:: -- passes it through and the leaf recurses to its single project base case.

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    CALL leprechaun function resolve Module "%Input_ModuleId%"
    IF ERRORLEVEL 1 GOTO Failure

    CALL leprechaun function resolve Suite "%Input_SuiteId%"
    IF ERRORLEVEL 1 GOTO Failure

    IF DEFINED Input_ProjectId (
        CALL leprechaun function resolve Project "%Input_SuiteId%" "%Input_ProjectId%"
        IF ERRORLEVEL 1 GOTO Failure

        CALL leprechaun function resolve ProjectModuleDefinition "%Input_SuiteId%" "%Input_ProjectId%" "%Input_ModuleId%"
        IF ERRORLEVEL 1 GOTO Failure
    )

    CALL leprechaun function %Input_ModuleId% dispatch "%Input_SuiteId%" "%Input_ProjectArg%" "%Input_ActionId%" %Input_Args%
    IF ERRORLEVEL 1 GOTO Failure

    GOTO Destructor

:Constructor
    SET "Input_SuiteId=%~1"
    SET "Input_ProjectId=%~2"
    SET "Input_ModuleId=%~3"
    SET "Input_ActionId=%~4"
    SET "Input_Args="
    SET "Input_Error="
    SET "Input_ReturnCode=0"

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
    SET "Input_Args=%Input_Args% %1"
    SHIFT
    GOTO Collect

:Collected
    IF DEFINED Input_Args SET "Input_Args=%Input_Args:~1%"
    GOTO Validate

:Validate
    IF NOT DEFINED Input_SuiteId (
        SET "Input_Error=Missing required argument <SuiteId>"
        GOTO Failure
    )

    IF NOT DEFINED Input_ModuleId (
        SET "Input_Error=Missing required argument <ModuleId>"
        GOTO Failure
    )

    IF NOT DEFINED Input_ActionId (
        SET "Input_Error=Missing required argument <ActionId>"
        GOTO Failure
    )

    :: The module dispatcher takes ProjectId as a fixed positional, so an absent
    :: project is passed as an empty string rather than omitted.
    SET "Input_ProjectArg=%Input_ProjectId%"
    GOTO Main

:Failure
    SET "Input_ReturnCode=1"
    GOTO Destructor

:Destructor
    :: GOTO takes no arguments, so the return code travels in a variable. A
    :: called function that already logged its own failure leaves Input_Error
    :: empty, which is what keeps one fault from being reported at every layer.
    IF DEFINED Input_Error CALL leprechaun function log error FnEtcDispatchInternal "%Input_Error%"
    SET "Input_SuiteId="
    SET "Input_ProjectId="
    SET "Input_ModuleId="
    SET "Input_ActionId="
    SET "Input_ProjectArg="
    SET "Input_Args="
    SET "Input_Error="
    EXIT /B %Input_ReturnCode%
