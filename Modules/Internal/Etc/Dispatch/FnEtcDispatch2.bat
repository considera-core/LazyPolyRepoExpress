:: FnEtcDispatch <EntryId> <Command...>                     when <EntryId> is Global
:: FnEtcDispatch <EntryId> <ValueId> <Command...>            otherwise

:: FnEtcDispatch2 <Scope>
:: ^| FnEtcDispatch2 global         (all organizations, suites and projects)
:: ^| FnEtcDispatch2 organization   (all suites and projects in the organization)
:: ^| FnEtcDispatch2 suite          (all projects in the suite)
:: ^| FnEtcDispatch2 project        (the specific project)

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "Input_Scope=%~1"

echo "Dispatching to scope: %Input_Scope%"

IF /I "%Input_Scope%"=="global" (
    ECHO UNIMPLEMENTED: FnEtcDispatch2 global
    EXIT /B 1
) ELSE IF /I "%Input_Scope%"=="organization" (
    REM todo, fix this: considera git story zc-ev-123 -v -q
    REM "CALLING Fngitstory with OrgId: considera, Arg: zc-ev-123, Args: considera git story zc-ev-123, Flags: -v -q"


    REM FnEtcDispatch2 organization "!Input_OrgId!" "!Input_Module!" "!Input_Action!" "!Input_Arg!" "!Output_FnEtcFlags_Args!" "!Output_FnEtcFlags_Flags!"
    REM ^| FnEtcDispatch2 organization "!Input_OrgId!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!" "!Output_FnEtcFlags_Flags!"
    SET "Input_OrgId=%~2"
    SET "Input_Module=%~3"
    SET "Input_Action=%~4"
    SET "Input_Arg=%~5"
    SET "Input_Args=%~6"
    SET "Input_Flags=%~7"
    ECHO "CALLING Fn!Input_Module!!Input_Action! with OrgId: !Input_OrgId!, Arg: !Input_Arg!, Args: !Input_Args!, Flags: !Input_Flags!"
    CALL "Fn!Input_Module!!Input_Action!" "!Input_OrgId!" "!Input_Arg!" !Input_Args! !Input_Flags!
    EXIT /B %ERRORLEVEL%
) ELSE IF /I "%Input_Scope%"=="suite" (
    REM FnEtcDispatch2 suite "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!" "!Output_FnEtcFlags_Flags!"
    REM ^| FnEtcDispatch2 suite "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!" "!Output_FnEtcFlags_Flags!"
    SET "Input_SuiteId=%~2"
    SHIFT
) ELSE IF /I "%Input_Scope%"=="project" (
    REM FnEtcDispatch2 project "!Input_Arg!" "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!" "!Output_FnEtcFlags_Flags!"
    SET "Input_ProjectId=%~2"
    SHIFT
) ELSE IF /I "%Input_Scope%"=="app" (
    REM todo app needs to be able to control 
    
    REM FnEtcDispatch2 app "!Input_Arg!" "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!" "!Output_FnEtcFlags_Flags!"
    SET "Input_AppId=%~2"
    SET "Input_SuiteId=%~3"
    SET "Input_Module=%~4"
    SET "Input_Action=%~5"
    SET "Input_Args=%~6"
    SET "Input_Flags=%~7"
    CALL FnEtcForEachProjectApp "!Input_AppId!" "!Input_SuiteId!" "Fn!Input_Module!!Input_Action!" !Input_Args! !Input_Flags!
    REM FnEtcDispatch2 app <AppId> <SuiteId> <ModuleId> <ActionId> <Arg[]> <Flag[]>
    REM   => FnEtcForEachProjectApp <AppId> <SuiteId> Fn<ModuleId><ActionId> <Arg[]> <Flag[]>
    REM   <= FnEtcForEachProjectApp <AppId> <SuiteId> <Fn> <...Args> <...Flags>
    REM !!!!!!!!All action level commands will take in a projectId to determine where the command should be executed.
    EXIT /B %ERRORLEVEL%
) ELSE (
    SET "Function_Error=Unknown scope %Input_Scope%. Expected global, organization, suite or project"
    ECHO "Unknown scope %Input_Scope%. Expected global, organization, suite or project"
    EXIT /B 1
)