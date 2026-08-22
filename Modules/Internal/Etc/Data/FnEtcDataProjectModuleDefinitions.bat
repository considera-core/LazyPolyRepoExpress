:: FnEtcDataProjectModuleDefinitions <SuiteId> <ProjectId>
:: leprechaun function data ProjectModuleDefinitions <SuiteId> <ProjectId>
:: -- Reads Data/Organizations/<OrgDir>/Suites/<SuiteDir>/Modules.Definitions.csv and exports:
:: --   GLOBAL_DataProjectModuleDefinitions                         (<ProjectIdentifier,ModuleIdentifier>[]) space separated project identifiers
:: --   GLOBAL_DataProjectModuleDefinition<Index>ProjectId          (ProjectIdentifier) command identifier
:: --   GLOBAL_DataProjectModuleDefinition<Index>ModuleId           (ModuleIdentifier) command identifier

@ECHO OFF

SET "Function_SuiteId=%~1"
SET "Function_ProjectId=%~2"

IF NOT DEFINED Function_SuiteId (
    CALL leprechaun function log error FnEtcDataProjectModuleDefinitions "Missing required argument ^<SuiteId^>"
    EXIT /B 1
)

IF NOT DEFINED Function_ProjectId (
    CALL leprechaun function log error FnEtcDataProjectModuleDefinitions "Missing required argument ^<ProjectId^>"
    EXIT /B 1
)

CALL leprechaun function env DataPath
IF ERRORLEVEL 1 EXIT /B 1

CALL leprechaun function resolve Suite "%Function_SuiteId%"
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_DataProjectModuleDefinitionsFile=%GLOBAL_DataPath%\Organizations\%GLOBAL_ResolvedSuiteOrgDirName%\Suites\%GLOBAL_ResolvedSuiteDirName%\Modules.Definitions.csv"
IF NOT EXIST "%Local_DataProjectModuleDefinitionsFile%" (
    CALL leprechaun function log error FnEtcDataProjectModuleDefinitions "Modules.Definitions.csv not found at %Local_DataProjectModuleDefinitionsFile%"
    EXIT /B 1
)

FOR /F "delims==" %%V IN ('SET GLOBAL_DataProjectModuleDefinition 2^>NUL') DO SET "%%V="

:: Extract -> ProjectIdentifier,ModuleIdentifier
SET "Local_Index=0"
FOR /F "usebackq skip=1 tokens=1-2 delims=, eol=#" %%A IN ("%Local_DataProjectModuleDefinitionsFile%") DO (
    CALL SET "GLOBAL_DataProjectModuleDefinitions=%%GLOBAL_DataProjectModuleDefinitions%% ^<%%A,%%B^>"
    CALL SET "GLOBAL_DataProjectModuleDefinition%%Local_Index%%ProjectId=%%A"
    CALL SET "GLOBAL_DataProjectModuleDefinition%%Local_Index%%ModuleId=%%B"
    SET /A Local_Index+=1
)

:: Trim if possible
SET "GLOBAL_DataProjectModuleDefinitions=%GLOBAL_DataProjectModuleDefinitions:~1%"
IF NOT DEFINED GLOBAL_DataProjectModuleDefinitions (
    CALL leprechaun function log error FnEtcDataProjectModuleDefinitions "No module definitions found in %Local_DataProjectModuleDefinitionsFile%"
    SET "Local_DataProjectModuleDefinitionsFile="
    EXIT /B 1
)

:: Cleanup
SET "Local_DataProjectModuleDefinitionsFile="
SET "Local_Index="
EXIT /B 0
