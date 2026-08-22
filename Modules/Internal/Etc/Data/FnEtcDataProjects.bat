:: FnEtcDataProjects <SuiteId>
:: leprechaun function data Projects <SuiteId>
:: -- Reads Data/Organizations/<OrgDir>/Suites/<SuiteDir>/Projects.csv and exports:
:: --   GLOBAL_DataProjects                                         (ProjectIdentifier[]) space separated project identifiers
:: --   GLOBAL_DataProject<Index>Id                                 (ProjectIdentifier) command identifier
:: --   GLOBAL_DataProject<Index>Identifier                         (ProjectFriendlyIdentifier) friendly identifier
:: --   GLOBAL_DataProject<Index>FrameworkId                        (ProjectFramework) framework identifier
:: --   GLOBAL_DataProject<Index>Name                               (ProjectFriendlyName) friendly name
:: --   GLOBAL_DataProject<Index>Type                               (ProjectType) Server|Client|Misc
:: --   GLOBAL_DataProject<Index>RootPath                           (ProjectRootPath) root path
:: --   GLOBAL_DataProject<Index>IsExternal                         (ProjectIsExternal) true|false

@ECHO OFF

SET "Function_SuiteId=%~1"

IF NOT DEFINED Function_SuiteId (
    CALL leprechaun function log error FnEtcDataProjects "Missing required argument ^<SuiteId^>"
    EXIT /B 1
)

CALL leprechaun function env DataPath
IF ERRORLEVEL 1 EXIT /B 1

CALL leprechaun function resolve Suite "%Function_SuiteId%"
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_DataProjectsFile=%GLOBAL_DataPath%\Organizations\%GLOBAL_ResolvedSuiteOrgDirName%\Suites\%GLOBAL_ResolvedSuiteDirName%\Projects.csv"
IF NOT EXIST "%Local_DataProjectsFile%" (
    CALL leprechaun function log error FnEtcDataProjects "Projects.csv not found at %Local_DataProjectsFile%"
    EXIT /B 1
)

FOR /F "delims==" %%V IN ('SET GLOBAL_DataProject 2^>NUL') DO SET "%%V="

:: Extract -> ProjectIdentifier,ProjectFriendlyIdentifier,ProjectFramework,ProjectFriendlyName,ProjectType,ProjectRootPath,IsExternal
SET "Local_Index=0"
FOR /F "usebackq skip=1 tokens=1-7 delims=, eol=#" %%A IN ("%Local_DataProjectsFile%") DO (
    CALL SET "GLOBAL_DataProjects=%%GLOBAL_DataProjects%% %%A"
    CALL SET "GLOBAL_DataProject%%Local_Index%%Id=%%A"
    CALL SET "GLOBAL_DataProject%%Local_Index%%Identifier=%%B"
    CALL SET "GLOBAL_DataProject%%Local_Index%%FrameworkId=%%C"
    CALL SET "GLOBAL_DataProject%%Local_Index%%Name=%%D"
    CALL SET "GLOBAL_DataProject%%Local_Index%%Type=%%E"
    CALL SET "GLOBAL_DataProject%%Local_Index%%RootPath=%%F"
    CALL SET "GLOBAL_DataProject%%Local_Index%%IsExternal=%%G"
    SET /A Local_Index+=1
)

:: Trim if possible
SET "GLOBAL_DataProjects=%GLOBAL_DataProjects:~1%"
IF NOT DEFINED GLOBAL_DataProjects (
    CALL leprechaun function log error FnEtcDataProjects "No projects found in %Local_DataProjectsFile%"
    SET "Local_DataProjectsFile="
    EXIT /B 1
)

:: Cleanup
SET "Local_DataProjectsFile="
SET "Local_Index="
EXIT /B 0