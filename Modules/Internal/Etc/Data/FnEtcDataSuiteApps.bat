:: FnEtcDataSuiteApps <OrgId> <SuiteId>
:: -- Output:
:: --   Output_Data_SuiteApps                                     (AppCommandIdentifier[]) space separated app command identifiers
:: --   Output_Data_SuiteApp<Index>Id                             (AppCommandIdentifier) command identifier
:: --   Output_Data_SuiteApp<Index>Label                          (AppFriendlyName) friendly name
:: --   Output_Data_SuiteApp<Index>Description                    (AppFriendlyDescription) friendly description
@ECHO OFF

:: INPUT
SET "Input_OrgId=%~1"
SET "Input_SuiteId=%~2"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument <OrgId>" & EXIT /B 1
IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "Missing required argument <SuiteId>" & EXIT /B 1

:: RESOLVE
CALL FnEtcResolveOrganization "%Input_OrgId%"
IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "Failed to resolve organization %Input_OrgId%" & EXIT /B 1

CALL FnEtcResolveSuite "%Input_OrgId%" "%Input_SuiteId%"
IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "Failed to resolve suite %Input_SuiteId% in organization %Input_OrgId%" & EXIT /B 1

:: MAPPING(A: Id, B: Label, C: Description)
SET "Output_Data_SuiteApps="
SET "Output_Data_SuiteAppsCount=0"
SET "Local_DataPath=%~dp0..\..\..\..\Data\Organizations\%Output_Resolved_OrgIdentifier%\Suites\%Output_Resolved_SuiteIdentifier%\Apps.csv"
FOR /F "usebackq skip=1 tokens=1-3 delims=, eol=#" %%A IN ("%Local_DataPath%") DO (
    IF DEFINED Output_Data_SuiteApps CALL SET "Output_Data_SuiteApps=%%Output_Data_SuiteApps%% %%A"
    IF NOT DEFINED Output_Data_SuiteApps SET "Output_Data_SuiteApps=%%A"
    CALL SET "Output_Data_SuiteApp%%Output_Data_SuiteAppsCount%%Id=%%A"
    CALL SET "Output_Data_SuiteApp%%Output_Data_SuiteAppsCount%%Label=%%B"
    CALL SET "Output_Data_SuiteApp%%Output_Data_SuiteAppsCount%%Description=%%C"
    SET /A Output_Data_SuiteAppsCount+=1
    CALL FnEtcCacheSet "SuiteApps[%Input_OrgId%][%Input_SuiteId%]" "%%Output_Data_SuiteApps%%"
    CALL FnEtcCacheSet "SuiteAppsCount[%Input_OrgId%][%Input_SuiteId%]" "%%Output_Data_SuiteAppsCount%%"
    CALL FnEtcCacheSet "SuiteAppId[%Input_OrgId%][%Input_SuiteId%][%%A]" "%%A"
    CALL FnEtcCacheSet "SuiteAppLabel[%Input_OrgId%][%Input_SuiteId%][%%A]" "%%B"
    CALL FnEtcCacheSet "SuiteAppDescription[%Input_OrgId%][%Input_SuiteId%][%%A]" "%%C"
)

IF NOT DEFINED Output_Data_SuiteApps CALL FnEtcLogWarning %~n0 "No apps found in %Local_DataPath%" & EXIT /B 1

EXIT /B 0
