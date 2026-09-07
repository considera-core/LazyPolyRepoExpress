:: FnEtcResolveProjectAppDefinition <OrgId> <SuiteId> <ProjectId> <AppId> <Action?>
:: -- Output:
:: --   Output_Resolved_ProjectAppDefinitionAppId                    (AppCommandIdentifier) command identifier
:: --   Output_Resolved_ProjectAppDefinitionProjectId                (ProjectCommandIdentifier) command identifier
:: -- Action (Optional):
:: --   refresh: forces a reload of the project app data, even if it was already loaded in this scope
:: --   fuck: resolves the project suite's organization and exports:
:: --     Output_Resolved_ProjectAppDefinitionOrgId                  (FK) owning organization command identifier
:: --     Output_Resolved_ProjectAppDefinitionSuiteId                (FK) owning suite command identifier

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

:: INPUT
SET "Input_OrgId=%~1"
SET "Input_SuiteId=%~2"
SET "Input_ProjectId=%~3"
SET "Input_AppId=%~4"
SET "Input_Action=%~5"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument ^<OrgId^>" & EXIT /B 1
IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "Missing required argument ^<SuiteId^>" & EXIT /B 1
IF NOT DEFINED Input_ProjectId CALL FnEtcLogError %~n0 "Missing required argument ^<ProjectId^>" & EXIT /B 1
IF NOT DEFINED Input_AppId CALL FnEtcLogError %~n0 "Missing required argument ^<AppId^>" & EXIT /B 1

:: CLEAR
CALL FnEtcLogDebug %~n0 "Clearing existing data..."
FOR /F "delims==" %%V IN ('SET Output_Resolved_ProjectAppDefinition 2^>NUL') DO SET "%%V="
CALL FnEtcLogDebug %~n0 "Cleared existing data."

:: RESOLVE
CALL FnEtcLogDebug %~n0 "Resolving source data..."
CALL FnEtcDataProjectAppDefinitions "%Input_OrgId%" "%Input_SuiteId%" "%Input_ProjectId%"
IF ERRORLEVEL 1 EXIT /B 1
CALL FnEtcLogDebug %~n0 "Resolved source data."

:: MAPPING
SET "Temp_ProjectAppDefinitions="%Output_Data_ProjectAppDefinitions: =" "%""
FOR %%A IN (%Temp_ProjectAppDefinitions%) DO (
    IF NOT DEFINED Output_Resolved_ProjectAppDefinitionAppId (
        IF /I NOT "[%Input_AppId%,%Input_ProjectId%]"=="%%~A" (
            CALL FnEtcLogDebug %~n0 "Skipping project app definition %%~A"
        ) ELSE (
            CALL SET "Output_Resolved_ProjectAppDefinitionAppId=%Input_AppId%"
            CALL SET "Output_Resolved_ProjectAppDefinitionProjectId=%Input_ProjectId%"
            IF /I "%Input_Action%"=="fuck" (
                CALL FnEtcResolveSuite "%Input_OrgId%" "%Input_SuiteId%"
                CALL SET "Output_Resolved_ProjectAppDefinitionOrgId=%%Output_Resolved_SuiteOrgId%%"
                CALL SET "Output_Resolved_ProjectAppDefinitionSuiteId=%%Output_Resolved_SuiteId%%"
                IF ERRORLEVEL 1 CALL FnEtcLogWarning %~n0 "Failed to resolve suite %Input_SuiteId%"
            )
            CALL FnEtcLogDebug %~n0 "Resolved project app definition (Output_Resolved_ProjectAppDefinitionAppId): !Output_Resolved_ProjectAppDefinitionAppId!"
            CALL FnEtcLogDebug %~n0 "Resolved project app definition (Output_Resolved_ProjectAppDefinitionProjectId): !Output_Resolved_ProjectAppDefinitionProjectId!"
            CALL FnEtcLogDebug %~n0 "Resolved project app definition (Output_Resolved_ProjectAppDefinitionOrgId): !Output_Resolved_ProjectAppDefinitionOrgId!"
            CALL FnEtcLogDebug %~n0 "Resolved project app definition (Output_Resolved_ProjectAppDefinitionSuiteId): !Output_Resolved_ProjectAppDefinitionSuiteId!"
        )
    )
)
IF NOT DEFINED Output_Resolved_ProjectAppDefinitionAppId CALL FnEtcLogError %~n0 "Failed to resolve project app definition for [%Input_AppId%,%Input_ProjectId%]" & EXIT /B 1
CALL FnEtcLogDebug %~n0 "Resolved data."

ENDLOCAL ^
    & SET "Output_Resolved_ProjectAppDefinitionAppId=%Output_Resolved_ProjectAppDefinitionAppId%" ^
    & SET "Output_Resolved_ProjectAppDefinitionProjectId=%Output_Resolved_ProjectAppDefinitionProjectId%" ^
    & SET "Output_Resolved_ProjectAppDefinitionOrgId=%Output_Resolved_ProjectAppDefinitionOrgId%" ^
    & SET "Output_Resolved_ProjectAppDefinitionSuiteId=%Output_Resolved_ProjectAppDefinitionSuiteId%"

EXIT /B 0
