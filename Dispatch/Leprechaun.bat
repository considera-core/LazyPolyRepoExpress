:: leprechaun <Command> <Arg[]>
:: ^| leprechaun exec <Module> <Action> <Flag[]> -a <Arg[]> (=> FnEtcDispatch2 global)
:: ^| leprechaun exec <OrgId> <Module> <Action> <Flag[]> -a <Arg[]> (=> FnEtcDispatch2 organization)
:: ^| leprechaun exec <OrgId> <SuiteId> <Module> <Action> <Flag[]> -a <Arg[]> (=> FnEtcDispatch2 suite)
:: ^| leprechaun exec <OrgId> <SuiteId> <ProjectId> <Module> <Action> <Flag[]> -a <Arg[]> (=> FnEtcDispatch2 project)
:: ^| leprechaun function <Submodule> <Action> -a <Arg[]>
:: ^| leprechaun edit
:: ^| leprechaun build
:: -- Params:
:: --   Commands:
:: --   ^| exec <OrgId> <SuiteId> <Module> <Action> <Flag[]> -a <Arg[]>
:: --   ^| function <Submodule> <Action> <Flag[]> -a <Arg[]>
:: --   ^| edit
:: -- Inputs:
:: -- Outputs:
:: --   void

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "Input_Command=%~1"

IF /I "%Input_Command%"=="exec" (
    SET "Input_Org=%~2"
    SET "Input_Suite=%~3"
    SET "Input_Module=%~4"
    SET "Input_Action=%~5"
    SET "Input_Args="
    SET "Input_Flags="

    :: CALL FnEtcFlags -p "!Input_Org!" "!Input_Suite!" "!Input_Module!" "!Input_Action!" -a %*
    :: CALL FnEtcDispatch2 global "!Input_Org!" "!Input_Suite!" "!Input_Module!" "!Input_Action!" !Output_FnEtcFlags_Args! !Output_FnEtcFlags_Flags!
    CALL FnEtcFlags -p -a %*
    CALL FnEtcDispatch2 global !Output_FnEtcFlags_Args! !Output_FnEtcFlags_Flags!
) ELSE IF /I "%Input_Command%"=="function" (
    SET "Input_Submodule=%~2"
    SET "Input_Action=%~3"
    SET "Input_Args="
    SET "Input_Flags="

    CALL FnEtcFlags -p function "!Input_Submodule!" "!Input_Action!" -a %*
    CALL "FnEtc!Input_Submodule!!Input_Action!" !Output_FnEtcFlags_Args! !Output_FnEtcFlags_Flags!
) ELSE IF /I "%Input_Command%"=="edit" (
    CALL CODE "C:\Envrionments\Dev\ConsideraDev\SoftwareDev\Sources\LazyPolyRepoExpress\"
) ELSE IF /I "%Input_Command%"=="build" (
    CALL FnExternalBootstrapShortcuts
) ELSE (
    CALL FnEtcLogError Leprechaun "Unknown command %Input_Command%. Expected exec, function or edit"
    EXIT /B 1
)

EXIT /B 0
