:: FnEtcResolveProjectModuleDefinition <SuiteId> <ProjectId> <ModuleId> <Flag[]>
:: leprechaun function resolve ProjectModuleDefinition <SuiteId> <ProjectId> <ModuleId>
:: -- Checks that a project declares a module, and exports:
:: --   GLOBAL_ResolvedProjectModuleDefinitionModuleId   (ModuleIdentifier) module identifier
:: --   GLOBAL_ResolvedProjectModuleDefinitionProjectId  (ProjectIdentifier) project identifier
:: -- Flags:
:: --   --refresh: resolve again even when this pair is already in scope
:: --
:: -- This is what keeps "unity" from running against a dotnet API: a module is
:: -- dispatchable against a project only if Modules.Definitions.csv says so.
:: --
:: -- NOTE: Locals are Export_ rather than Function_ on purpose. With no SETLOCAL,
:: --       a Function_ name here would be the CALLER's variable, and clearing one
:: --       on the way out would blank it under them.
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_Resolved values.

@ECHO OFF

SET "Export_SuiteId=%~1"
SET "Export_ProjectId=%~2"
SET "Export_ModuleId=%~3"

IF NOT DEFINED Export_SuiteId (
    CALL FnEtcLogError FnEtcResolveProjectModuleDefinition "Missing required argument <SuiteId>"
    EXIT /B 1
)

IF NOT DEFINED Export_ProjectId (
    CALL FnEtcLogError FnEtcResolveProjectModuleDefinition "Missing required argument <ProjectId>"
    EXIT /B 1
)

IF NOT DEFINED Export_ModuleId (
    CALL FnEtcLogError FnEtcResolveProjectModuleDefinition "Missing required argument <ModuleId>"
    EXIT /B 1
)

CALL FnEtcFlags %*

SET "GLOBAL_ResolvedProjectModuleDefinitionModuleId="
SET "GLOBAL_ResolvedProjectModuleDefinitionProjectId="

CALL FnEtcDataProjectModuleDefinitions "%Export_SuiteId%"
IF ERRORLEVEL 1 EXIT /B 1

:: The reader exports one list per project, so the membership test is a lookup
:: rather than a scan over every pair in the suite.
CALL SET "Local_ProjectModules=%%GLOBAL_DataProjectModules_%Export_ProjectId%%%"
IF DEFINED Local_ProjectModules SET "Local_ProjectModules=%Local_ProjectModules:~1%"

FOR %%M IN (%Local_ProjectModules%) DO IF /I "%%M"=="%Export_ModuleId%" SET "GLOBAL_ResolvedProjectModuleDefinitionModuleId=%Export_ModuleId%"

IF NOT DEFINED GLOBAL_ResolvedProjectModuleDefinitionModuleId (
    CALL FnEtcLogError FnEtcResolveProjectModuleDefinition "Project %Export_ProjectId% does not declare the %Export_ModuleId% module"
    ECHO   Declared: %Local_ProjectModules%
    SET "Export_SuiteId="
    SET "Export_ProjectId="
    SET "Export_ModuleId="
    SET "Local_ProjectModules="
    EXIT /B 1
)

SET "GLOBAL_ResolvedProjectModuleDefinitionProjectId=%Export_ProjectId%"

SET "Export_SuiteId="
SET "Export_ProjectId="
SET "Export_ModuleId="
SET "Local_ProjectModules="
EXIT /B 0
