:: FnEtcResolveProjectModuleDefinition <SuiteId> <ProjectId> <ModuleId> <Flags...>
:: leprechaun function resolve ProjectModuleDefinition <SuiteId> <ProjectId> <ModuleId> <Flags...>
:: -- Resolves a suite project module definition from the data store, and exports:
:: --   GLOBAL_ResolvedProjectModuleDefinitionModuleId              (ModuleCommandIdentifier) command identifier
:: --   GLOBAL_ResolvedProjectModuleDefinitionProjectId             (ProjectCommandIdentifier) command identifier
:: -- Flags:
:: --   --refresh:                                                  (GLOBAL_FlagRefresh) forces a reload of the project module data, even if it was already loaded in this scope
:: --   --fuck:                                                     (GLOBAL_FlagOrg) resolves the project suite's organization and exports:
:: --     GLOBAL_ResolvedProjectModuleDefinitionOrgId               (FK) owning organization command identifier
:: --     GLOBAL_ResolvedProjectModuleDefinitionSuiteId             (FK) owning suite command identifier

@ECHO OFF

SET "Function_SuiteId=%~1"
SET "Function_ProjectId=%~2"
SET "Function_ModuleId=%~3"

CALL leprechaun function flags %*
SET "Local_FlagRefresh=%GLOBAL_FlagRefresh%"
SET "Local_FlagFuck=%GLOBAL_FlagFuck%"

IF NOT DEFINED Function_SuiteId (
    CALL leprechaun function log error FnEtcResolveProjectModuleDefinition "Missing required argument ^<SuiteId^>"
    GOTO Destructor 1
)

IF NOT DEFINED Function_ProjectId (
    CALL leprechaun function log error FnEtcResolveProjectModuleDefinition "Missing required argument ^<ProjectId^>"
    GOTO Destructor 1
)

IF NOT DEFINED Function_ModuleId (
    CALL leprechaun function log error FnEtcResolveProjectModuleDefinition "Missing required argument ^<ModuleId^>"
    GOTO Destructor 1
)

IF /I "%GLOBAL_ResolvedProjectModuleDefinitionModuleId%"=="%Function_ModuleId%" (
    IF NOT DEFINED Local_FlagRefresh GOTO Destructor 0
)

SET "GLOBAL_ResolvedProjectModuleDefinitionModuleId="
SET "GLOBAL_ResolvedProjectModuleDefinitionProjectId="
SET "GLOBAL_ResolvedProjectModuleDefinitionOrgId="
SET "GLOBAL_ResolvedProjectModuleDefinitionSuiteId="

CALL leprechaun function data ProjectModuleDefinitions "%Function_SuiteId%" "%Function_ProjectId%"
IF ERRORLEVEL 1 GOTO Destructor 1

FOR %%M IN (%GLOBAL_DataProjectModuleDefinitions%) DO (
    IF DEFINED GLOBAL_ResolvedProjectModuleDefinitionModuleId EXIT /B 0

    IF /I "%%M"=="<%Function_ProjectId%,%Function_ModuleId%>" (
        SET "GLOBAL_ResolvedProjectModuleDefinitionModuleId=%Function_ModuleId%"
        SET "GLOBAL_ResolvedProjectModuleDefinitionProjectId=%Function_ProjectId%"

        IF DEFINED GLOBAL_FlagFuck (
            CALL leprechaun function resolve Suite "%Function_SuiteId%"
            CALL SET "GLOBAL_ResolvedProjectModuleDefinitionOrgId=%%GLOBAL_ResolvedSuiteOrgId%%"
            CALL SET "GLOBAL_ResolvedProjectModuleDefinitionSuiteId=%%GLOBAL_ResolvedSuiteId%%"
            IF ERRORLEVEL 1 (
                CALL leprechaun function log warning FnEtcResolveProjectModuleDefinition "Failed to resolve suite %Function_SuiteId%"
            )
        )

        GOTO Destructor 0
    )
)

:Destructor
    SET "Function_SuiteId="
    SET "Function_ProjectId="
    SET "Function_ModuleId="
    SET "Local_FlagRefresh="
    SET "Local_FlagFuck="
    EXIT /B %~1
