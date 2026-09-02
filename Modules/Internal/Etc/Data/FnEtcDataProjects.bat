:: FnEtcDataProjects <SuiteId> <Flag[]>
:: leprechaun function data Projects <SuiteId>
:: -- Reads Data/Organizations/<OrgDir>/Suites/<SuiteDir>/Projects.csv and exports:
:: --   GLOBAL_DataProjects                     (ProjectIdentifier[]) space separated identifiers
:: --   GLOBAL_DataProjectsInternal             (ProjectIdentifier[]) the subset with IsExternal false
:: --   GLOBAL_DataProjectsExternal             (ProjectIdentifier[]) the subset with IsExternal true
:: --   GLOBAL_DataProjectsCount                (Computed) number of projects
:: --   GLOBAL_DataProjectsSuiteId              (FK) the suite these projects were read for
:: --   GLOBAL_DataProject<Index>Id             (ProjectIdentifier) command identifier
:: --   GLOBAL_DataProject<Index>Identifier     (ProjectFriendlyIdentifier) directory name
:: --   GLOBAL_DataProject<Index>FrameworkId    (ProjectFrameworkIdentifier) framework identifier
:: --   GLOBAL_DataProject<Index>Name           (ProjectFriendlyName) friendly name
:: --   GLOBAL_DataProject<Index>Type           (ProjectType) Server, Client or Misc
:: --   GLOBAL_DataProject<Index>RootPath       (ProjectRootPath) root path, relative to the suite
:: --   GLOBAL_DataProject<Index>IsExternal     (IsExternal) true or false
:: --   GLOBAL_DataProject<Index>SuiteId        (FK) owning suite command identifier
:: -- Flags:
:: --   --refresh: reread the CSV even when this suite is already loaded
:: --
:: -- NOTE: Locals are Export_ rather than Function_ on purpose. With no
:: --       SETLOCAL, a Function_ name here would be the CALLER's variable,
:: --       and clearing one on the way out would blank it under them.
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_DataProject variables.

@ECHO OFF

SET "Export_SuiteId=%~1"

IF NOT DEFINED Export_SuiteId (
    CALL FnEtcLogError FnEtcDataProjects "Missing required argument <SuiteId>"
    EXIT /B 1
)

CALL FnEtcFlags %*

:: Memoized per suite: a different suite always forces a reread.
IF /I "%GLOBAL_DataProjectsSuiteId%"=="%Export_SuiteId%" IF NOT DEFINED GLOBAL_FlagRefresh (
    SET "Export_SuiteId="
    EXIT /B 0
)

CALL FnEtcEnvGetDataPath
IF ERRORLEVEL 1 EXIT /B 1

CALL FnEtcResolveSuite "%Export_SuiteId%"
IF ERRORLEVEL 1 EXIT /B 1

CALL FnEtcResolveOrganization "%GLOBAL_ResolvedSuiteOrgId%"
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_DataProjectsFile=%GLOBAL_DataPath%\Organizations\%GLOBAL_ResolvedOrgIdentifier%\Suites\%GLOBAL_ResolvedSuiteIdentifier%\Projects.csv"
IF NOT EXIST "%Local_DataProjectsFile%" (
    CALL FnEtcLogError FnEtcDataProjects "Projects.csv not found at %Local_DataProjectsFile%"
    SET "Local_DataProjectsFile="
    SET "Export_SuiteId="
    EXIT /B 1
)

FOR /F "delims==" %%V IN ('SET GLOBAL_DataProject 2^>NUL') DO SET "%%V="

:: Extract -> Identifier,FriendlyIdentifier,FrameworkIdentifier,FriendlyName,Type,Description,RootPath,IsExternal
:: CALL SET, because a plain SET inside a FOR body would expand the accumulator
:: once at block parse time and leave only the last row behind.
SET "Local_Index=0"
:: Lowercase loop variables on purpose. FOR variables are case sensitive, and
:: tokens=1-8 would otherwise claim %%G and %%H, so "%%GLOBAL_DataProjects%%"
:: would read as loop variable %%G followed by the literal LOBAL_DataProjects.
FOR /F "usebackq skip=1 tokens=1-8 delims=, eol=#" %%a IN ("%Local_DataProjectsFile%") DO (
    CALL SET "GLOBAL_DataProjects=%%GLOBAL_DataProjects%% %%a"
    CALL SET "GLOBAL_DataProject%%Local_Index%%Id=%%a"
    CALL SET "GLOBAL_DataProject%%Local_Index%%Identifier=%%b"
    CALL SET "GLOBAL_DataProject%%Local_Index%%FrameworkId=%%c"
    CALL SET "GLOBAL_DataProject%%Local_Index%%Name=%%d"
    CALL SET "GLOBAL_DataProject%%Local_Index%%Type=%%e"
    CALL SET "GLOBAL_DataProject%%Local_Index%%RootPath=%%g"
    CALL SET "GLOBAL_DataProject%%Local_Index%%IsExternal=%%h"
    CALL SET "GLOBAL_DataProject%%Local_Index%%SuiteId=%Export_SuiteId%"
    IF /I "%%h"=="true" CALL SET "GLOBAL_DataProjectsExternal=%%GLOBAL_DataProjectsExternal%% %%a"
    IF /I NOT "%%h"=="true" CALL SET "GLOBAL_DataProjectsInternal=%%GLOBAL_DataProjectsInternal%% %%a"
    SET /A Local_Index+=1
)

:: A CSV holding only its header is a declared but empty collection, which
:: is valid. Only a missing file is an error, and that was checked above.

IF DEFINED GLOBAL_DataProjects SET "GLOBAL_DataProjects=%GLOBAL_DataProjects:~1%"
IF DEFINED GLOBAL_DataProjectsInternal SET "GLOBAL_DataProjectsInternal=%GLOBAL_DataProjectsInternal:~1%"
IF DEFINED GLOBAL_DataProjectsExternal SET "GLOBAL_DataProjectsExternal=%GLOBAL_DataProjectsExternal:~1%"
SET "GLOBAL_DataProjectsCount=%Local_Index%"
SET "GLOBAL_DataProjectsSuiteId=%Export_SuiteId%"

SET "Local_DataProjectsFile="
SET "Local_Index="
SET "Export_SuiteId="
EXIT /B 0
