:: FnEtcDataProjectAppDefinitions <OrgId> <SuiteId> <AppId>
:: -- Output:
:: --   Output_Data_ProjectAppDefinitionsProjects                   (ProjectIdentifier[]) space separated project identifiers
:: --   Output_Data_ProjectAppDefinitionsProjectsCount              (Integer) count of project identifiers

@ECHO OFF

:: INPUT
SET "Input_OrgId=%~1"
SET "Input_SuiteId=%~2"
SET "Input_AppId=%~3"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument ^<OrgId^>" & EXIT /B 1
IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "Missing required argument ^<SuiteId^>" & EXIT /B 1
IF NOT DEFINED Input_AppId CALL FnEtcLogError %~n0 "Missing required argument ^<AppId^>" & EXIT /B 1

:: RESOLVE
CALL FnEtcCacheGet "OrgIdentifier[%Input_OrgId%]"
SET "Output_Resolved_OrgIdentifier=%Output_Cache_OrgIdentifier%"
IF NOT DEFINED Output_Resolved_OrgIdentifier CALL FnEtcResolveOrganization "%Input_OrgId%"

CALL FnEtcCacheGet "SuiteIdentifier[%Input_OrgId%][%Input_SuiteId%]"
SET "Output_Resolved_SuiteIdentifier=%Output_Cache_SuiteIdentifier%"
IF NOT DEFINED Output_Resolved_SuiteIdentifier CALL FnEtcResolveSuite "%Input_OrgId%" "%Input_SuiteId%"

:: MAPPING(A: AppId, B: ProjectId)
SET "Output_Data_ProjectAppDefinitionsProjects="
SET "Output_Data_ProjectAppDefinitionsProjectsCount=0"
SET "Local_DataFile=%~dp0..\..\..\..\Data\Organizations\%Output_Resolved_OrgIdentifier%\Suites\%Output_Resolved_SuiteIdentifier%\Apps.Definitions.csv"
FOR /F "usebackq skip=1 tokens=1-2 delims=, eol=#" %%A IN ("%Local_DataFile%") DO (
    IF /I "%%A"=="%Input_AppId%" (
        IF DEFINED Output_Data_ProjectAppDefinitionsProjects CALL SET "Output_Data_ProjectAppDefinitionsProjects=%%Output_Data_ProjectAppDefinitionsProjects%% %%B"
        IF NOT DEFINED Output_Data_ProjectAppDefinitionsProjects CALL SET "Output_Data_ProjectAppDefinitionsProjects=%%B"
        SET /A Output_Data_ProjectAppDefinitionsProjectsCount+=1
        CALL FnEtcCacheSet "ProjectAppDefinitionsProjects[%Input_OrgId%][%Input_SuiteId%]" "%%Output_Data_ProjectAppDefinitionsProjects%%"
        CALL FnEtcCacheSet "ProjectAppDefinitionProjectId[%Input_OrgId%][%Input_SuiteId%][%%B]" "%%B"
    )
)

IF NOT DEFINED Output_Data_ProjectAppDefinitionsProjects CALL FnEtcLogWarning %~n0 "No app definitions found in %Local_DataFile%" & EXIT /B 1

EXIT /B 0
