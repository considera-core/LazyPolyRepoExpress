:: FnEtcDataSuites <OrgId> <Flag[]>
:: leprechaun function data Suites <OrgId>
:: -- Reads Data/Organizations/<OrgDir>/Suites.csv and exports:
:: --   GLOBAL_DataSuites                   (SuiteCommandIdentifier[]) space separated command identifiers
:: --   GLOBAL_DataSuitesActive             (SuiteCommandIdentifier[]) the subset whose Active column is true
:: --   GLOBAL_DataSuitesCount              (Computed) number of suites
:: --   GLOBAL_DataSuitesOrgId              (FK) the organization these suites were read for
:: --   GLOBAL_DataSuite<Index>Id           (SuiteCommandIdentifier) command identifier
:: --   GLOBAL_DataSuite<Index>Identifier   (SuiteFriendlyIdentifier) directory name
:: --   GLOBAL_DataSuite<Index>Name         (SuiteFriendlyName) friendly name
:: --   GLOBAL_DataSuite<Index>RootPath     (SuiteRootPath) root path
:: --   GLOBAL_DataSuite<Index>Active       (SuiteIsActive) true or false
:: --   GLOBAL_DataSuite<Index>OrgId        (FK) owning organization command identifier
:: -- Flags:
:: --   --refresh: reread the CSV even when this organization is already loaded
:: --
:: -- NOTE: Locals are Export_ rather than Function_ on purpose. With no
:: --       SETLOCAL, a Function_ name here would be the CALLER's variable,
:: --       and clearing one on the way out would blank it under them.
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_DataSuite variables.

@ECHO OFF

SET "Export_OrgId=%~1"

IF NOT DEFINED Export_OrgId (
    CALL FnEtcLogError FnEtcDataSuites "Missing required argument <OrgId>"
    EXIT /B 1
)

CALL FnEtcFlags %*

:: Memoized per organization: a different org always forces a reread.
IF /I "%GLOBAL_DataSuitesOrgId%"=="%Export_OrgId%" IF NOT DEFINED GLOBAL_FlagRefresh (
    SET "Export_OrgId="
    EXIT /B 0
)

CALL FnEtcEnvGetDataPath
IF ERRORLEVEL 1 EXIT /B 1

CALL FnEtcResolveOrganization "%Export_OrgId%"
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_DataSuitesFile=%GLOBAL_DataPath%\Organizations\%GLOBAL_ResolvedOrgIdentifier%\Suites.csv"
IF NOT EXIST "%Local_DataSuitesFile%" (
    CALL FnEtcLogError FnEtcDataSuites "Suites.csv not found at %Local_DataSuitesFile%"
    SET "Local_DataSuitesFile="
    SET "Export_OrgId="
    EXIT /B 1
)

FOR /F "delims==" %%V IN ('SET GLOBAL_DataSuite 2^>NUL') DO SET "%%V="

:: Extract -> SuiteCommandIdentifier,SuiteFriendlyIdentifier,SuiteFriendlyName,Description,RootPath,IsActive
:: CALL SET, because a plain SET inside a FOR body would expand the accumulator
:: once at block parse time and leave only the last row behind.
SET "Local_Index=0"
:: Lowercase loop variables on purpose. FOR variables are case sensitive, so a
:: token range can never claim the %%G of "%%GLOBAL_..." out from under it.
FOR /F "usebackq skip=1 tokens=1-6 delims=, eol=#" %%a IN ("%Local_DataSuitesFile%") DO (
    CALL SET "GLOBAL_DataSuites=%%GLOBAL_DataSuites%% %%a"
    CALL SET "GLOBAL_DataSuite%%Local_Index%%Id=%%a"
    CALL SET "GLOBAL_DataSuite%%Local_Index%%Identifier=%%b"
    CALL SET "GLOBAL_DataSuite%%Local_Index%%Name=%%c"
    CALL SET "GLOBAL_DataSuite%%Local_Index%%RootPath=%%e"
    CALL SET "GLOBAL_DataSuite%%Local_Index%%Active=%%f"
    CALL SET "GLOBAL_DataSuite%%Local_Index%%OrgId=%Export_OrgId%"
    IF /I "%%f"=="true" CALL SET "GLOBAL_DataSuitesActive=%%GLOBAL_DataSuitesActive%% %%a"
    SET /A Local_Index+=1
)

:: A CSV holding only its header is a declared but empty collection, which
:: is valid. Only a missing file is an error, and that was checked above.

IF DEFINED GLOBAL_DataSuites SET "GLOBAL_DataSuites=%GLOBAL_DataSuites:~1%"
IF DEFINED GLOBAL_DataSuitesActive SET "GLOBAL_DataSuitesActive=%GLOBAL_DataSuitesActive:~1%"
SET "GLOBAL_DataSuitesCount=%Local_Index%"
SET "GLOBAL_DataSuitesOrgId=%Export_OrgId%"

SET "Local_DataSuitesFile="
SET "Local_Index="
SET "Export_OrgId="
EXIT /B 0
