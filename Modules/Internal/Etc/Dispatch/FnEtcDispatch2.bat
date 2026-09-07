:: FnEtcDispatch <EntryId> <Command...>                     when <EntryId> is Global
:: FnEtcDispatch <EntryId> <ValueId> <Command...>            otherwise

:: FnEtcDispatch2 <Scope>
:: ^| FnEtcDispatch2 global         (all organizations, suites and projects)
:: ^| FnEtcDispatch2 organization   (all suites and projects in the organization)
:: ^| FnEtcDispatch2 suite          (all projects in the suite)
:: ^| FnEtcDispatch2 project        (the specific project)

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

:: INPUT
SET "Input_Scope=%~1"

IF NOT DEFINED Input_Scope CALL FnEtcLogError %~n0 "Missing required argument ^<Scope^>" & EXIT /B 1

IF /I "%Input_Scope%"=="global" (
    CALL FnEtcLogDebug %~n0 "Enter [Global]"
    ECHO UNIMPLEMENTED: FnEtcDispatch2 global
    EXIT /B 1
) ELSE IF /I "%Input_Scope%"=="organization" (
    REM CALL FnEtcLogDebug %~n0 "Enter [Organization]"

    REM INPUT
    SET "Input_OrgId=%~2"
    SET "Input_Module=%~3"
    SET "Input_Action=%~4"
    SET "Input_Arg=%~5"
    SET "Input_Args=%~6"

    IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "[Organization] Missing required argument ^<OrgId^>" & EXIT /B 1
    IF NOT DEFINED Input_Module CALL FnEtcLogError %~n0 "[Organization] Missing required argument ^<ModuleId^>" & EXIT /B 1
    IF NOT DEFINED Input_Action CALL FnEtcLogError %~n0 "[Organization] Missing required argument ^<ActionId^>" & EXIT /B 1

    REM CALL FnEtcLogDebug %~n0 "[Organization] Resolving suites..."
    CALL FnEtcDataSuites "%Input_OrgId%"
    REM CALL FnEtcLogDebug %~n0 "[Organization] Resolved suites."

    REM CALL FnEtcLogDebug %~n0 "[Organization] Dispatching..."
    FOR %%S IN (!Output_Data_Suites!) DO (
        REM CALL FnEtcLogDebug %~n0 "[Organization] Dispatching suite..."
        CALL FnEtcDispatch2 suite "%Input_OrgId%" "%%S" "%Input_Module%" "%Input_Action%" "%Input_Arg%" %Input_Args%
        IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "[Organization] Dispatch failed: FnEtcDispatch2 suite %Input_OrgId% %%S %Input_Arg% %Input_Args%" & EXIT /B 1
        REM CALL FnEtcLogDebug %~n0 "[Organization] Dispatched suite: %%S"
    )
    REM CALL FnEtcLogDebug %~n0 "[Organization] Dispatched."
    EXIT /B 0
) ELSE IF /I "%Input_Scope%"=="suite" (
    REM CALL FnEtcLogDebug %~n0 "Enter [Suite]"

    REM INPUT
    SET "Input_OrgId=%~2"
    SET "Input_SuiteId=%~3"
    SET "Input_Module=%~4"
    SET "Input_Action=%~5"
    SET "Input_Arg=%~6"

    IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "[Suite] Missing required argument <OrgId>" & EXIT /B 1
    IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "[Suite] Missing required argument <SuiteId>" & EXIT /B 1
    IF NOT DEFINED Input_Module CALL FnEtcLogError %~n0 "[Suite] Missing required argument <ModuleId>" & EXIT /B 1
    IF NOT DEFINED Input_Action CALL FnEtcLogError %~n0 "[Suite] Missing required argument <ActionId>" & EXIT /B 1

    REM CALL FnEtcLogDebug %~n0 "[Suite] Resolving projects..."
    CALL FnEtcCacheGet Projects "[!Input_OrgId!][!Input_SuiteId!]" || CALL FnEtcDataProjects "!Input_OrgId!" "!Input_SuiteId!"
    IF DEFINED Output_Cache_Projects (
        CALL SET "Output_Data_Projects=!Output_Cache_Projects!"
    )

    REM CALL FnEtcLogDebug %~n0 "[Suite] Dispatching projects... !Output_Data_Projects! !Output_Cached_Projects!"
    FOR %%P IN (!Output_Data_Projects!) DO (
        REM CALL FnEtcLogDebug %~n0 "[Suite] Dispatching project..."
        CALL FnEtcDispatch2 project "!Input_OrgId!" "!Input_SuiteId!" "%%P" "!Input_Module!" "!Input_Action!" "!Input_Arg!"
        IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "[Suite] Dispatch failed: FnEtcDispatch2 project !Input_OrgId! !Input_SuiteId! %%P !Input_Module! !Input_Action! !Input_Arg!" & EXIT /B 1
        REM CALL FnEtcLogDebug %~n0 "[Suite] Dispatched project: %%P"
    )
    REM CALL FnEtcLogDebug %~n0 "[Suite] Dispatched projects."

    SHIFT
) ELSE IF /I "%Input_Scope%"=="project" (
    REM CALL FnEtcLogDebug %~n0 "Enter [Project]"

    REM INPUT
    SET "Input_OrgId=%~2"
    SET "Input_SuiteId=%~3"
    SET "Input_ProjectId=%~4"
    SET "Input_Module=%~5"
    SET "Input_Action=%~6"
    SET "Input_Arg=%~7"
    SET "Input_Args=%~8"

    IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "[Project] Missing required argument ^<OrgId^>" & EXIT /B 1
    IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "[Project] Missing required argument ^<SuiteId^>" & EXIT /B 1
    IF NOT DEFINED Input_ProjectId CALL FnEtcLogError %~n0 "[Project] Missing required argument ^<ProjectId^>" & EXIT /B 1
    IF NOT DEFINED Input_Module CALL FnEtcLogError %~n0 "[Project] Missing required argument ^<ModuleId^>" & EXIT /B 1
    IF NOT DEFINED Input_Action CALL FnEtcLogError %~n0 "[Project] Missing required argument ^<ActionId^>" & EXIT /B 1

    REM CALL FnEtcLogDebug %~n0 "[Project] Dispatching project..."
    CALL Fn!Input_Module!!Input_Action! "!Input_OrgId!" "!Input_SuiteId!" "!Input_ProjectId!" "!Input_Arg!" "!Input_Args!"
    IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "[Project] Dispatch failed: Fn!Input_Module!!Input_Action! !Input_OrgId! !Input_SuiteId! !Input_ProjectId! !Input_Arg! !Input_Args!" & EXIT /B 1
    REM CALL FnEtcLogDebug %~n0 "[Project] Dispatched project: !Input_ProjectId!"
) ELSE IF /I "%Input_Scope%"=="app" (
    REM CALL FnEtcLogDebug %~n0 "Enter [App]"

    REM INPUT
    SET "Input_OrgId=%~2"
    SET "Input_SuiteId=%~3"
    SET "Input_AppId=%~4"
    SET "Input_Module=%~5"
    SET "Input_Action=%~6"
    SET "Input_Args=%~7"

    IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "[App] Missing required argument ^<OrgId^>" & EXIT /B 1
    IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "[App] Missing required argument ^<SuiteId^>" & EXIT /B 1
    IF NOT DEFINED Input_AppId CALL FnEtcLogError %~n0 "[App] Missing required argument ^<AppId^>" & EXIT /B 1
    IF NOT DEFINED Input_Module CALL FnEtcLogError %~n0 "[App] Missing required argument ^<ModuleId^>" & EXIT /B 1
    IF NOT DEFINED Input_Action CALL FnEtcLogError %~n0 "[App] Missing required argument ^<ActionId^>" & EXIT /B 1

    REM CALL FnEtcLogDebug %~n0 "[App] Resolving project app definitions..."
    CALL FnEtcDataProjectAppDefinitions "!Input_OrgId!" "!Input_SuiteId!" "!Input_AppId!"
    REM CALL FnEtcLogDebug %~n0 "[App] Resolved project app definitions."

    REM CALL FnEtcLogDebug %~n0 "[App] Dispatching projects..."
    FOR %%P IN (!Output_Data_ProjectAppDefinitionsProjects!) DO (
        REM CALL FnEtcLogDebug %~n0 "[App] Dispatching project..."
        CALL FnEtcDispatch2 project "!Input_OrgId!" "!Input_SuiteId!" "%%P" "!Input_Module!" "!Input_Action!" "!Input_Arg!" "!Input_Args!"
        IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "[App] Dispatch failed: FnEtcDispatch2 project !Input_OrgId! !Input_SuiteId! %%P !Input_Module! !Input_Action! !Input_Arg! !Input_Args!" & EXIT /B 1
        REM CALL FnEtcLogDebug %~n0 "[App] Dispatched project: %%P"
    )
    REM CALL FnEtcLogDebug %~n0 "[App] Dispatched projects."

) ELSE (
    SET "Input_Error=Unknown scope %Input_Scope%. Expected global, organization, suite, project or app"
    ECHO "Unknown scope %Input_Scope%. Expected global, organization, suite, project or app"
    EXIT /B 1
)