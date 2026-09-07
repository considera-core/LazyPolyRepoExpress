:: FnEtcDataProjectModuleDefinitions <OrgId> <SuiteId>
:: -- Output:
:: --   Output_Data_ProjectModuleDefinitions         (Pair[]) space separated project:module pairs
:: --   Output_Data_ProjectModuleDefinitionsSuiteId  (FK) the suite these were read for
:: --   Output_Data_ProjectModules_<ProjectId>       (ModuleIdentifier[]) modules that project declares

@ECHO OFF

:: Config inputs
SET "Input_OrgId=%~1"
IF NOT DEFINED Input_OrgId (
    CALL FnEtcLogError %~n0 "Missing required argument ^<OrgId^>"
    EXIT /B 1
)

SET "Input_SuiteId=%~2"
IF NOT DEFINED Input_SuiteId (
    CALL FnEtcLogError %~n0 "Missing required argument ^<SuiteId^>"
    EXIT /B 1
)

:: Resolve source
CALL FnEtcLogDebug %~n0 "Resolving data path..."
CALL FnEtcEnvGetDataPath
CALL FnEtcLogDebug %~n0 "Resolved data path (Output_Env_DataPath): %Output_Env_DataPath%"

CALL FnEtcLogDebug %~n0 "Resolving source suite..."
CALL FnEtcResolveSuite "%Input_OrgId%" "%Input_SuiteId%"
IF ERRORLEVEL 1 EXIT /B 1
CALL FnEtcLogDebug %~n0 "Resolved source suite (Output_Resolved_SuiteId): %Output_Resolved_SuiteId%"
CALL FnEtcLogDebug %~n0 "Resolved source organization (Output_Resolved_OrgId): %Output_Resolved_OrgId%"

:: Verify source
CALL FnEtcLogDebug %~n0 "Verifying data path..."
SET "Local_DataFile=%Output_Env_DataPath%\Organizations\%Output_Resolved_OrgIdentifier%\Suites\%Output_Resolved_SuiteIdentifier%\Modules.Definitions.csv"
IF NOT EXIST "%Local_DataFile%" (
    CALL FnEtcLogError %~n0 "Modules.Definitions.csv not found at %Local_DataFile%"
    EXIT /B 1
)
CALL FnEtcLogDebug %~n0 "Verified data file (Local_DataFile): %Local_DataFile%"

:: Clear existing
CALL FnEtcLogDebug %~n0 "Clearing existing data..."
FOR /F "delims==" %%V IN ('SET Output_Data_ProjectModuleDefinition 2^>NUL') DO SET "%%V="
CALL FnEtcLogDebug %~n0 "Cleared existing data."

:: Map to output
CALL FnEtcLogDebug %~n0 "Mapping data..."
FOR /F "usebackq skip=1 tokens=1-2 delims=, eol=#" %%a IN ("%Local_DataFile%") DO (
    CALL SET "Output_Data_ProjectModuleDefinitions=%%Output_Data_ProjectModuleDefinitions%% %%a:%%b"
    CALL SET "Output_Data_ProjectModules_%%a=%%Output_Data_ProjectModules_%%a%% %%b"
    CALL FnEtcLogDebug %~n0 "Mapped (Output_Data_ProjectModules_%%a): %%Output_Data_ProjectModules_%%a%%"
    CALL FnEtcLogDebug %~n0 "Updated (Output_Data_ProjectModuleDefinitions): %Output_Data_ProjectModuleDefinitions%"
)
IF NOT DEFINED Output_Data_ProjectModuleDefinitions (
    CALL FnEtcLogWarning %~n0 "No module definitions found in %Local_DataFile%"
    EXIT /B 1
)
CALL FnEtcLogDebug %~n0 "Mapped data."

:: Trim leading list separator
SET "Output_Data_ProjectModuleDefinitions=%Output_Data_ProjectModuleDefinitions:~1%"

SET "Output_Data_ProjectModuleDefinitionsSuiteId=%Input_SuiteId%"
EXIT /B 0
