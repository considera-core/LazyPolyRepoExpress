:: FnEtcDataSuites <OrgId>
:: -- Output:
:: --   Output_Data_Suites                   (SuiteCommandIdentifier[]) space separated command identifiers
:: --   Output_Data_SuitesActive             (SuiteCommandIdentifier[]) the subset whose Active column is true
:: --   Output_Data_SuitesCount              (Computed) number of suites
:: --   Output_Data_SuitesOrgId              (FK) the organization these suites were read for
:: --   Output_Data_Suite<Index>Id           (SuiteCommandIdentifier) command identifier
:: --   Output_Data_Suite<Index>Identifier   (SuiteFriendlyIdentifier) directory name
:: --   Output_Data_Suite<Index>Name         (SuiteFriendlyName) friendly name
:: --   Output_Data_Suite<Index>RootPath     (SuiteRootPath) root path
:: --   Output_Data_Suite<Index>Active       (SuiteIsActive) true or false
:: --   Output_Data_Suite<Index>OrgId        (FK) owning organization command identifier
:: -- Input:
:: --   Input_OrgId                         The organization ID to retrieve suites for.

@ECHO OFF

:: INPUT
SET "Input_OrgId=%~1"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument <OrgId>" & EXIT /B 1

:: RESOLVE
CALL FnEtcResolveOrganization "%Input_OrgId%"
IF ERRORLEVEL 1 CALL FnEtcLogError %~n0 "Failed to resolve organization %Input_OrgId%" & EXIT /B 1

:: MAPPING(A: Id, B: Identifier, C: Name, D: Description, E: RootPath, F: Active)
SET "Output_Data_Suites="
SET "Output_Data_SuitesActive="
SET "Output_Data_SuitesCount=0"
SET "Local_DataPath=%~dp0..\..\..\..\Data\Organizations\%Output_Resolved_OrgIdentifier%\Suites.csv"
FOR /F "usebackq skip=1 tokens=1-6 delims=, eol=#" %%a IN ("%Local_DataPath%") DO (
    IF DEFINED Output_Data_Suites CALL SET "Output_Data_Suites=%%Output_Data_Suites%% %%a"
    IF NOT DEFINED Output_Data_Suites SET "Output_Data_Suites=%%a"
    IF /I "%%f"=="true" (
        IF DEFINED Output_Data_SuitesActive CALL SET "Output_Data_SuitesActive=%%Output_Data_SuitesActive%% %%a"
        IF NOT DEFINED Output_Data_SuitesActive SET "Output_Data_SuitesActive=%%a"
    )
    CALL SET "Output_Data_Suite%%Output_Data_SuitesCount%%Id=%%a"
    CALL SET "Output_Data_Suite%%Output_Data_SuitesCount%%Identifier=%%b"
    CALL SET "Output_Data_Suite%%Output_Data_SuitesCount%%Name=%%c"
    CALL SET "Output_Data_Suite%%Output_Data_SuitesCount%%RootPath=%%e"
    CALL SET "Output_Data_Suite%%Output_Data_SuitesCount%%Active=%%f"
    CALL SET "Output_Data_Suite%%Output_Data_SuitesCount%%OrgId=%Input_OrgId%"
    SET /A Output_Data_SuitesCount+=1
    CALL FnEtcCacheSet "Suites[%Input_OrgId%]" "%%Output_Data_Suites%%"
    CALL FnEtcCacheSet "SuitesActive[%Input_OrgId%]" "%%Output_Data_SuitesActive%%"
    CALL FnEtcCacheSet "SuitesCount[%Input_OrgId%]" "%%Output_Data_SuitesCount%%"
    CALL FnEtcCacheSet "SuiteId[%Input_OrgId%][%%a]" "%%a"
    CALL FnEtcCacheSet "SuiteIdentifier[%Input_OrgId%][%%a]" "%%b"
    CALL FnEtcCacheSet "SuiteName[%Input_OrgId%][%%a]" "%%c"
    CALL FnEtcCacheSet "SuiteRootPath[%Input_OrgId%][%%a]" "%%e"
    CALL FnEtcCacheSet "SuiteActive[%Input_OrgId%][%%a]" "%%f"
    CALL FnEtcCacheSet "SuiteOrgId[%Input_OrgId%][%%a]" "%Input_OrgId%"
)

IF NOT DEFINED Output_Data_Suites CALL FnEtcLogWarning %~n0 "No suites found in %Local_DataPath%" & EXIT /B 1

SET "Output_Data_SuitesOrgId=%Output_Resolved_OrgId%"
EXIT /B 0
