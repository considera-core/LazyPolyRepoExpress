:: FnEtcRouter <OrgId> <SuiteId> <ModuleId> <ActionId> <AppId | ProjectId | Arg> <...Args?> <...Flags?>
:: ^| FnEtcRouter <OrgId> <ModuleId> <ActionId> <AppId | ProjectId | Arg> <...Args?> <...Flags?>
:: -- Also validates the existence of the params if related to Data, so no need to check again in the action level
:: Puesdo:
:: If (Input_SuiteId.IsSuite()) then
::   SET "Input_Module=%~2"
::   SET "Input_Action=%~3"
::   SET "Input_Arg4=%~4"
::   CALL FnEtcFlags -p "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" "!Input_Arg4!" -a %*
::   If (Input_Arg4.IsApp()) then
::     CALL FnEtcDispatch2 app !Input_Arg4! !Input_SuiteId! !Input_Module! !Input_Action! !Output_FnEtcFlags_Args! !Output_FnEtcFlags_Flags!
::   Else If (Input_Arg4.IsProject()) then
::     CALL FnEtcDispatch2 project !Input_Arg4! !Input_SuiteId! !Input_Module! !Input_Action! !Output_FnEtcFlags_Args! !Output_FnEtcFlags_Flags!
::   Else
::     CALL FnEtcDispatch2 suite !Input_SuiteId! !Input_Module! !Input_Action! !Output_FnEtcFlags_Args! !Output_FnEtcFlags_Flags!
:: Else then
::   SET "Input_Module=%~1"
::   SET "Input_Action=%~2"
::   SET "Input_Arg3=%~3"
:: End If

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

:: INPUT
SET "Input_OrgId=%~1"
SET "Input_SuiteIdOrModuleId=%~2"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument ^<OrgId^>" & EXIT /B 1
IF NOT DEFINED Input_SuiteIdOrModuleId CALL FnEtcLogError %~n0 "Missing required argument ^<SuiteId | ModuleId^>" & CALL FnEtcHelp organization "%Input_OrgId%" & EXIT /B 1

:: RESOLVE
CALL FnEtcLogDebug %~n0 "Resolving suite..."
CALL FnEtcResolveSuite "%Input_OrgId%" "%Input_SuiteIdOrModuleId%"

IF ERRORLEVEL 1 (
    CALL FnEtcLogDebug %~n0 "Enter [Module]: %~2"

    REM INPUT
    SET "Input_Module=%Input_SuiteIdOrModuleId%"
    SET "Input_Action=%~3"
    SET "Input_Arg=%~4"

    IF NOT DEFINED Input_Action CALL FnEtcLogError %~n0 "[Module] Missing required argument ^<ActionId^>" & EXIT /B 1
    
    IF DEFINED Input_Arg (
        CALL FnEtcLogDebug %~n0 "[Module] Resolving flags..."
        ::CALL FnEtcFlags -p "!Input_OrgId!" "!Input_Module!" "!Input_Action!" "!Input_Arg!" -a %*
        CALL FnEtcLogDebug %~n0 "[Module] Resolved flags (Output_FnEtcFlags_Args: !Output_FnEtcFlags_Args!)"
        CALL FnEtcLogDebug %~n0 "[Module] Resolved flags (Output_FnEtcFlags_Flags: !Output_FnEtcFlags_Flags!)"

        CALL FnEtcLogDebug %~n0 "[Module] Dispatching via organization..."
        CALL FnEtcDispatch2 organization "!Input_OrgId!" "!Input_Module!" "!Input_Action!" "!Input_Arg!" "!Output_FnEtcFlags_Args!"
        IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "[Module] Dispatch via organization failed" & EXIT /B 1
        CALL FnEtcLogDebug %~n0 "[Module] Dispatched via organization"
    ) ELSE (
        CALL FnEtcLogDebug %~n0 "[Module] Resolving flags..."
        ::CALL FnEtcFlags -p "!Input_OrgId!" "!Input_Module!" "!Input_Action!" -a %*
        CALL FnEtcLogDebug %~n0 "[Module] Resolved flags (Output_FnEtcFlags_Args: !Output_FnEtcFlags_Args!)"
        CALL FnEtcLogDebug %~n0 "[Module] Resolved flags (Output_FnEtcFlags_Flags: !Output_FnEtcFlags_Flags!)"

        CALL FnEtcLogDebug %~n0 "[Module] Dispatching via organization..."
        CALL FnEtcDispatch2 organization "!Input_OrgId!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!"
        IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "[Module] Dispatch via organization failed" & EXIT /B 1
        CALL FnEtcLogDebug %~n0 "[Module] Dispatched via organization"
    )

) ELSE (
    CALL FnEtcLogDebug %~n0 "Enter [Suite]: !Input_SuiteId!"

    REM INPUT
    SET "Input_SuiteId=%Input_SuiteIdOrModuleId%"
    SET "Input_Module=%~3"
    SET "Input_Action=%~4"
    SET "Input_Arg=%~5"

    IF NOT DEFINED Input_Module CALL FnEtcLogError %~n0 "[Suite] Missing required argument <ModuleId>" & EXIT /B 1
    IF NOT DEFINED Input_Action CALL FnEtcLogError %~n0 "[Suite] Missing required argument <ActionId>" & EXIT /B 1

    IF DEFINED Input_Arg (
        CALL FnEtcLogDebug %~n0 "[Suite] Checking if argument is a suite app..."
        CALL FnEtcResolveSuiteApp "!Input_OrgId!" "!Input_SuiteId!" "!Input_Arg!"

        IF NOT DEFINED Output_Resolved_SuiteAppId (
            CALL FnEtcLogDebug %~n0 "[Suite] Argument is not a suite app, resolving as project..."
            CALL FnEtcResolveProject "!Input_OrgId!" "!Input_SuiteId!" "!Input_Arg!"

            REM Input_Arg is Output_Resolved_ProjectId if Output_Resolved_ProjectId is defined
            IF NOT DEFINED Output_Resolved_ProjectId (
                CALL FnEtcDispatch2 suite "!Input_OrgId!" "!Input_SuiteId!" "!Input_Module!" "!Input_Action!" "!Input_Arg!"
                IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "[Suite] Dispatch via suite failed" & EXIT /B 1
            ) ELSE (
                CALL FnEtcDispatch2 project "!Input_OrgId!" "!Input_SuiteId!" "!Output_Resolved_ProjectId!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!"
                IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "[Suite] Dispatch via project failed" & EXIT /B 1
            )
        ) ELSE (
            CALL FnEtcLogDebug %~n0 "[Suite] Argument is a suite app, dispatching via app..."
            CALL FnEtcDispatch2 app "!Input_OrgId!" "!Input_SuiteId!" "!Input_Arg!" "!Input_Module!" "!Input_Action!" "!Output_FnEtcFlags_Args!"
            IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "[Suite] Dispatch via app failed" & EXIT /B 1
        )
    ) ELSE (
        CALL FnEtcLogDebug %~n0 "[Suite] No argument provided, dispatching via suite... suite !Input_OrgId! !Input_SuiteId! !Input_Module! !Input_Action!"
        CALL FnEtcDispatch2 suite "!Input_OrgId!" "!Input_SuiteId!" "!Input_Module!" "!Input_Action!"
        IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "[Suite] Dispatch via suite failed" & EXIT /B 1
    )
)
