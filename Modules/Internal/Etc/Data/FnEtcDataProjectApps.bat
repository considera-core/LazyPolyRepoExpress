:: FnEtcDataProjectApps <SuiteId> <ProjectId>
:: leprechaun function data ProjectApps <SuiteId> <ProjectId>
:: -- Reads Data/Organizations/<OrgDir>/Suites/<SuiteDir>/Apps.csv and exports:
:: --   GLOBAL_DataProjectApps                                     (AppCommandIdentifier[]) space separated app command identifiers
:: --   GLOBAL_DataProjectApp<Index>Id                             (AppCommandIdentifier) command identifier
:: --   GLOBAL_DataProjectApp<Index>Label                          (AppFriendlyName) friendly name
:: --   GLOBAL_DataProjectApp<Index>Description                    (AppFriendlyDescription) friendly description
@ECHO OFF

SET "Function_SuiteId=%~1"
SET "Function_ProjectId=%~2"

IF NOT DEFINED Function_SuiteId (
    CALL leprechaun function log error FnEtcDataProjectApps "Missing required argument ^<SuiteId^>"
    EXIT /B 1
)

IF NOT DEFINED Function_ProjectId (
    CALL leprechaun function log error FnEtcDataProjectApps "Missing required argument ^<ProjectId^>"
    EXIT /B 1
)

CALL leprechaun function env DataPath
IF ERRORLEVEL 1 EXIT /B 1

CALL leprechaun function resolve Suite "%Function_SuiteId%"
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_DataProjectAppsFile=%GLOBAL_DataPath%\Organizations\%GLOBAL_ResolvedSuiteOrgDirName%\Suites\%GLOBAL_ResolvedSuiteDirName%\Apps.csv"
IF NOT EXIST "%Local_DataProjectAppsFile%" (
    CALL leprechaun function log error FnEtcDataProjectApps "Apps.csv not found at %Local_DataProjectAppsFile%"
    EXIT /B 1
)

FOR /F "delims==" %%V IN ('SET GLOBAL_DataProjectApp 2^>NUL') DO SET "%%V="

:: Extract -> AppCommandIdentifier,AppFriendlyName,AppFriendlyDescription
SET "Local_Index=0"
FOR /F "usebackq skip=1 tokens=1-3 delims=, eol=#" %%A IN ("%Local_DataProjectAppsFile%") DO (
    CALL SET "GLOBAL_DataProjectApps=%%GLOBAL_DataProjectApps%% %%A"
    CALL SET "GLOBAL_DataProjectApp%%Local_Index%%Id=%%A"
    CALL SET "GLOBAL_DataProjectApp%%Local_Index%%Label=%%B"
    CALL SET "GLOBAL_DataProjectApp%%Local_Index%%Description=%%C"
    SET /A Local_Index+=1
)

:: Trim if possible
SET "GLOBAL_DataProjectApps=%GLOBAL_DataProjectApps:~1%"
IF NOT DEFINED GLOBAL_DataProjectApps (
    CALL leprechaun function log error FnEtcDataProjectApps "No apps found in %Local_DataProjectAppsFile%"
    SET "Local_DataProjectAppsFile="
    EXIT /B 1
)

:: Cleanup
SET "Local_DataProjectAppsFile="
SET "Local_Index="
EXIT /B 0
