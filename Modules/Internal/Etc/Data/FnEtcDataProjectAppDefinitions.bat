:: FnEtcDataProjectAppDefinitions <SuiteId> <ProjectId>
:: leprechaun function data ProjectAppDefinitions <SuiteId> <ProjectId>
:: -- Reads Data/Organizations/<OrgDir>/Suites/<SuiteDir>/Apps.Definitions.csv and exports:
:: --   GLOBAL_DataProjectAppDefinitions                         (<ProjectIdentifier,AppIdentifier>[]) space separated project identifiers
:: --   GLOBAL_DataProjectAppDefinition<Index>ProjectId          (ProjectIdentifier) command identifier
:: --   GLOBAL_DataProjectAppDefinition<Index>AppId              (AppIdentifier) command identifier

@ECHO OFF

SET "Export_SuiteId=%~1"
SET "Export_ProjectId=%~2"

IF NOT DEFINED Export_SuiteId (
    CALL leprechaun function log error FnEtcDataProjectAppDefinitions "Missing required argument ^<SuiteId^>"
    EXIT /B 1
)

IF NOT DEFINED Export_ProjectId (
    CALL leprechaun function log error FnEtcDataProjectAppDefinitions "Missing required argument ^<ProjectId^>"
    EXIT /B 1
)

CALL leprechaun function env DataPath
IF ERRORLEVEL 1 EXIT /B 1

CALL FnEtcResolveSuite "%Export_SuiteId%"
IF ERRORLEVEL 1 EXIT /B 1

CALL FnEtcResolveOrganization "%GLOBAL_ResolvedSuiteOrgId%"
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_DataProjectAppDefinitionsFile=%GLOBAL_DataPath%\Organizations\%GLOBAL_ResolvedOrgIdentifier%\Suites\%GLOBAL_ResolvedSuiteIdentifier%\Apps.Definitions.csv"
IF NOT EXIST "%Local_DataProjectAppDefinitionsFile%" (
    CALL leprechaun function log error FnEtcDataProjectAppDefinitions "Apps.Definitions.csv not found at %Local_DataProjectAppDefinitionsFile%"
    EXIT /B 1
)

FOR /F "delims==" %%V IN ('SET GLOBAL_DataProjectAppDefinitions 2^>NUL') DO SET "%%V="

:: Extract -> ProjectIdentifier,AppIdentifier
SET "Local_Index=0"
FOR /F "usebackq skip=1 tokens=1-2 delims=, eol=#" %%A IN ("%Local_DataProjectAppDefinitionsFile%") DO (
    CALL SET "GLOBAL_DataProjectAppDefinitions=%%GLOBAL_DataProjectAppDefinitions%% ^<%%A,%%B^>"
    CALL SET "GLOBAL_DataProjectAppDefinition%%Local_Index%%ProjectId=%%A"
    CALL SET "GLOBAL_DataProjectAppDefinition%%Local_Index%%AppId=%%B"
    SET /A Local_Index+=1
)

:: Trim if possible
SET "GLOBAL_DataProjectAppDefinitions=%GLOBAL_DataProjectAppDefinitions:~1%"
IF NOT DEFINED GLOBAL_DataProjectAppDefinitions (
    CALL leprechaun function log error FnEtcDataProjectAppDefinitions "No app definitions found in %Local_DataProjectAppDefinitionsFile%"
    SET "Local_DataProjectAppDefinitionsFile="
    EXIT /B 1
)

:: Cleanup
SET "Local_DataProjectAppDefinitionsFile="
SET "Local_Index="
EXIT /B 0
