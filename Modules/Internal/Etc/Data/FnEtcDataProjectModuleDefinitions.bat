:: FnEtcDataProjectModuleDefinitions <SuiteId> <Flag[]>
:: leprechaun function data ProjectModuleDefinitions <SuiteId>
:: -- Reads Data/Organizations/<OrgDir>/Suites/<SuiteDir>/Modules.Definitions.csv,
:: -- which is the per project allow list of modules, and exports:
:: --   GLOBAL_DataProjectModuleDefinitions         (Pair[]) space separated project:module pairs
:: --   GLOBAL_DataProjectModuleDefinitionsSuiteId  (FK) the suite these were read for
:: --   GLOBAL_DataProjectModules_<ProjectId>       (ModuleIdentifier[]) modules that project declares
:: -- Flags:
:: --   --refresh: reread the CSV even when this suite is already loaded
:: --
:: -- The per project list is exported as its own variable rather than as a list
:: -- of bracketed pairs to search. A membership test is then a single IF DEFINED
:: -- against a name, with no <, > or , travelling through CALL SET and ECHO,
:: -- where they would be read as redirection and separators.
:: --
:: -- NOTE: Locals are Export_ rather than Function_ on purpose. With no SETLOCAL,
:: --       a Function_ name here would be the CALLER's variable, and clearing one
:: --       on the way out would blank it under them.
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_DataProjectModule values.

@ECHO OFF

SET "Export_SuiteId=%~1"

IF NOT DEFINED Export_SuiteId (
    CALL FnEtcLogError FnEtcDataProjectModuleDefinitions "Missing required argument <SuiteId>"
    EXIT /B 1
)

CALL FnEtcFlags %*

IF /I "%GLOBAL_DataProjectModuleDefinitionsSuiteId%"=="%Export_SuiteId%" IF NOT DEFINED GLOBAL_FlagRefresh (
    SET "Export_SuiteId="
    EXIT /B 0
)

CALL FnEtcEnvGetDataPath
IF ERRORLEVEL 1 EXIT /B 1

CALL FnEtcResolveSuite "%Export_SuiteId%"
IF ERRORLEVEL 1 EXIT /B 1

CALL FnEtcResolveOrganization "%GLOBAL_ResolvedSuiteOrgId%"
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_DefsFile=%GLOBAL_DataPath%\Organizations\%GLOBAL_ResolvedOrgIdentifier%\Suites\%GLOBAL_ResolvedSuiteIdentifier%\Modules.Definitions.csv"
IF NOT EXIST "%Local_DefsFile%" (
    CALL FnEtcLogError FnEtcDataProjectModuleDefinitions "Modules.Definitions.csv not found at %Local_DefsFile%"
    SET "Local_DefsFile="
    SET "Export_SuiteId="
    EXIT /B 1
)

FOR /F "delims==" %%V IN ('SET GLOBAL_DataProjectModule 2^>NUL') DO SET "%%V="

:: Extract -> ProjectIdentifier,ModuleIdentifier
:: Lowercase loop variables, so a token range can never claim the %%G of
:: "%%GLOBAL_..." out from under it.
FOR /F "usebackq skip=1 tokens=1-2 delims=, eol=#" %%a IN ("%Local_DefsFile%") DO (
    CALL SET "GLOBAL_DataProjectModuleDefinitions=%%GLOBAL_DataProjectModuleDefinitions%% %%a:%%b"
    CALL SET "GLOBAL_DataProjectModules_%%a=%%GLOBAL_DataProjectModules_%%a%% %%b"
)

:: A CSV holding only its header is a declared but empty collection, which is
:: valid. Only a missing file is an error, and that was checked above.
IF DEFINED GLOBAL_DataProjectModuleDefinitions SET "GLOBAL_DataProjectModuleDefinitions=%GLOBAL_DataProjectModuleDefinitions:~1%"
SET "GLOBAL_DataProjectModuleDefinitionsSuiteId=%Export_SuiteId%"

SET "Local_DefsFile="
SET "Export_SuiteId="
EXIT /B 0
