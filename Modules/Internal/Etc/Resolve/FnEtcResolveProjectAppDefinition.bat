:: FnEtcResolveProjectAppDefinition <SuiteId> <ProjectId> <AppId> <Flags...>
:: -- Resolves a suite project app definition from the data store, and exports:
:: --   GLOBAL_ResolvedProjectAppDefinitionAppId                    (AppCommandIdentifier) command identifier
:: --   GLOBAL_ResolvedProjectAppDefinitionProjectId                (ProjectCommandIdentifier) command identifier
:: -- Flags:
:: --   --refresh: forces a reload of the project app data, even if it was already loaded in this scope
:: --   --fuck: resolves the project suite's organization and exports:
:: --     GLOBAL_ResolvedProjectAppDefinitionOrgId                  (FK) owning organization command identifier
:: --     GLOBAL_ResolvedProjectAppDefinitionSuiteId                (FK) owning suite command identifier

@ECHO OFF

SET "Function_SuiteId=%~1"
SET "Function_ProjectId=%~2"
SET "Function_AppId=%~3"

CALL leprechaun function flags %*

IF NOT DEFINED Function_SuiteId (
    CALL leprechaun function log error FnEtcResolveProjectAppDefinition "Missing required argument ^<SuiteId^>"
    EXIT /B 1
)

IF NOT DEFINED Function_ProjectId (
    CALL leprechaun function log error FnEtcResolveProjectAppDefinition "Missing required argument ^<ProjectId^>"
    EXIT /B 1
)

IF NOT DEFINED Function_AppId (
    CALL leprechaun function log error FnEtcResolveProjectAppDefinition "Missing required argument ^<AppId^>"
    EXIT /B 1
)

IF /I "%GLOBAL_ResolvedProjectAppDefinitionAppId%"=="%Function_AppId%" (
    IF NOT DEFINED GLOBAL_FlagRefresh EXIT /B 0
)

SET "GLOBAL_ResolvedProjectAppDefinitionAppId="
SET "GLOBAL_ResolvedProjectAppDefinitionProjectId="
SET "GLOBAL_ResolvedProjectAppDefinitionOrgId="
SET "GLOBAL_ResolvedProjectAppDefinitionSuiteId="

CALL leprechaun function data ProjectAppDefinitions "%Function_SuiteId%" "%Function_ProjectId%"
IF ERRORLEVEL 1 EXIT /B 1

FOR %%A IN (%GLOBAL_DataProjectAppDefinitions%) DO (
    IF DEFINED GLOBAL_ResolvedProjectAppDefinitionAppId EXIT /B 0

    IF /I "%%A"=="<%Function_ProjectId%,%Function_AppId%>" (
        IF DEFINED GLOBAL_FlagFuck (
            CALL leprechaun function resolve Suite "%Function_SuiteId%"
            CALL SET "GLOBAL_ResolvedProjectAppDefinitionOrgId=%%GLOBAL_ResolvedSuiteOrgId%%"
            CALL SET "GLOBAL_ResolvedProjectAppDefinitionSuiteId=%%GLOBAL_ResolvedSuiteId%%"
            IF ERRORLEVEL 1 (
                CALL leprechaun function log warning FnEtcResolveProjectAppDefinition "Failed to resolve suite %Function_SuiteId%"
            )
        )

        SET "GLOBAL_ResolvedProjectAppDefinitionAppId=%Function_AppId%"
        SET "GLOBAL_ResolvedProjectAppDefinitionProjectId=%Function_ProjectId%"
        SET "Function_SuiteId="
        SET "Function_ProjectId="
        SET "Function_AppId="
        EXIT /B 0
    )
)

SET "Function_SuiteId="
SET "Function_ProjectId="
SET "Function_AppId="
EXIT /B 0
