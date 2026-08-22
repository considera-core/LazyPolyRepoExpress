:: FnEtcDataSuites <OrgId>
:: leprechaun function data Suites <OrgId>
:: -- Reads Data/Organizations/<OrgDir>/Suites.csv and exports:
:: --   GLOBAL_DataSuites                                           (SuiteCommandIdentifier[]) space separated suite command identifiers
:: --   GLOBAL_DataSuite<Index>Id                                   (SuiteCommandIdentifier) friendly identifier, used as the directory name
:: --   GLOBAL_DataSuite<Index>Identifier                           (SuiteFriendlyIdentifier) friendly identifier, used as the directory name
:: --   GLOBAL_DataSuite<Index>Name                                 (SuiteFriendlyName) friendly name
:: --   GLOBAL_DataSuite<Index>RootPath                             (SuiteRootPath) root path
:: --   GLOBAL_DataSuite<Index>Active                               (SuiteIsActive) true|false

@ECHO OFF

SET "Function_OrgId=%~1"

IF NOT DEFINED Function_OrgId (
    CALL leprechaun function log error FnEtcDataSuites "Missing required argument ^<OrgId^>"
    EXIT /B 1
)

CALL leprechaun function env DataPath
IF ERRORLEVEL 1 EXIT /B 1

CALL leprechaun function resolve Organization "%Function_OrgId%"
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_DataSuitesFile=%GLOBAL_DataPath%\Organizations\%GLOBAL_ResolvedOrgDirName%\Suites.csv"
IF NOT EXIST "%Local_DataSuitesFile%" (
    CALL leprechaun function log error FnEtcDataSuites "Suites.csv not found at %Local_DataSuitesFile%"
    EXIT /B 1
)

FOR /F "delims==" %%V IN ('SET GLOBAL_DataSuite 2^>NUL') DO SET "%%V="

:: Extract -> SuiteCommandIdentifier,SuiteFriendlyIdentifier,SuiteFriendlyName,Description,RootPath,IsActive
SET "Local_Index=0"
FOR /F "usebackq skip=1 tokens=1-6 delims=, eol=#" %%A IN ("%Local_DataSuitesFile%") DO (
    CALL SET "GLOBAL_DataSuites=%%GLOBAL_DataSuites%% %%A"
    CALL SET "GLOBAL_DataSuite%%Local_Index%%Id=%%A"
    CALL SET "GLOBAL_DataSuite%%Local_Index%%Identifier=%%B"
    CALL SET "GLOBAL_DataSuite%%Local_Index%%Name=%%C"
    CALL SET "GLOBAL_DataSuite%%Local_Index%%RootPath=%%E"
    CALL SET "GLOBAL_DataSuite%%Local_Index%%Active=%%F"
    SET /A Local_Index+=1
)

:: Trim if possible
SET "GLOBAL_DataSuites=%GLOBAL_DataSuites:~1%"
IF NOT DEFINED GLOBAL_DataSuites (
    CALL leprechaun function log error FnEtcDataSuites "No suites found in %Local_DataSuitesFile%"
    SET "Local_DataSuitesFile="
    EXIT /B 1
)

:: Cleanup
SET "Local_DataSuitesFile="
SET "Local_Index="
EXIT /B 0
