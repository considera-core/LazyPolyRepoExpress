:: FnEtcResolveProjectModuleDefinition <OrgId> <SuiteId> <ProjectId> <ModuleId> <Action?>
:: -- Output:
:: --   Output_Resolved_ProjectModuleDefinitionModuleId                    (ModuleIdentifier) module identifier
:: --   Output_Resolved_ProjectModuleDefinitionProjectId                   (ProjectIdentifier) project identifier
:: -- Action (Optional):
:: --   refresh: forces a reload of the project module data, even if it was already loaded in this scope

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

:: INPUT
SET "Input_OrgId=%~1"
SET "Input_SuiteId=%~2"
SET "Input_ProjectId=%~3"
SET "Input_ModuleId=%~4"
SET "Input_Action=%~5"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument <OrgId>" & EXIT /B 1
IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "Missing required argument <SuiteId>" & EXIT /B 1
IF NOT DEFINED Input_ProjectId CALL FnEtcLogError %~n0 "Missing required argument <ProjectId>" & EXIT /B 1
IF NOT DEFINED Input_ModuleId CALL FnEtcLogError %~n0 "Missing required argument <ModuleId>" & EXIT /B 1

:: CLEAR
CALL FnEtcLogDebug %~n0 "Clearing existing data..."
FOR /F "delims==" %%V IN ('SET Output_Resolved_ProjectModuleDefinition 2^>NUL') DO SET "%%V="
CALL FnEtcLogDebug %~n0 "Cleared existing data."

:: RESOLVE
CALL FnEtcLogDebug %~n0 "Resolving source data..."
CALL FnEtcDataProjectModuleDefinitions "%Input_OrgId%" "%Input_SuiteId%"
IF ERRORLEVEL 1 EXIT /B 1
CALL FnEtcLogDebug %~n0 "Resolved source data."

:: MAPPING
CALL SET "Local_ProjectModules=%%Output_Data_ProjectModules_%Input_ProjectId%%%"
SET "Local_ProjectModules=%Local_ProjectModules:~1%"
FOR %%M IN (%Local_ProjectModules%) DO (
    IF NOT DEFINED Output_Resolved_ProjectModuleDefinitionModuleId (
        IF /I NOT "%%M"=="%Input_ModuleId%" (
            CALL FnEtcLogDebug %~n0 "Skipping module %%M"
        ) ELSE (
            SET "Output_Resolved_ProjectModuleDefinitionModuleId=%Input_ModuleId%"
            SET "Output_Resolved_ProjectModuleDefinitionProjectId=%Input_ProjectId%"
            CALL FnEtcLogDebug %~n0 "Resolved project module definition (Output_Resolved_ProjectModuleDefinitionModuleId): %Input_ModuleId%"
            CALL FnEtcLogDebug %~n0 "Resolved project module definition (Output_Resolved_ProjectModuleDefinitionProjectId): %Input_ProjectId%"
        )
    )
)

IF NOT DEFINED Output_Resolved_ProjectModuleDefinitionModuleId CALL FnEtcLogError %~n0 "Failed to resolve project module definition for [%Input_ModuleId%,%Input_ProjectId%]" & EXIT /B 1
CALL FnEtcLogDebug %~n0 "Resolved data."

ENDLOCAL ^
    & SET "Output_Resolved_ProjectModuleDefinitionModuleId=%Output_Resolved_ProjectModuleDefinitionModuleId%" ^
    & SET "Output_Resolved_ProjectModuleDefinitionProjectId=%Output_Resolved_ProjectModuleDefinitionProjectId%"

EXIT /B 0
