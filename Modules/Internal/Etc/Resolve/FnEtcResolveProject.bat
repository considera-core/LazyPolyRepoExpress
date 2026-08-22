:: FnEtcResolveProject <SuiteId> <ProjectId> <Flags...>
:: -- Resolves a suite project from the data store, and exports:
:: --   GLOBAL_ResolvedProjectId                                    (ProjectCommandIdentifier) command identifier
:: --   GLOBAL_ResolvedProjectIdentifier                            (ProjectFriendlyIdentifier) friendly identifier, used as the directory name
:: --   GLOBAL_ResolvedProjectFrameworkId                           (ProjectFramework) framework identifier
:: --   GLOBAL_ResolvedProjectName                                  (ProjectFriendlyName) friendly name
:: --   GLOBAL_ResolvedProjectType                                  (ProjectType) Server|Client|Misc
:: --   GLOBAL_ResolvedProjectRootPath                              (ProjectRootPath) absolute path to the project's root directory
:: --   GLOBAL_ResolvedProjectIsExternal                            (ProjectIsExternal) true|false
:: --   GLOBAL_ResolvedProjectDataPath                              (Computed) absolute path to the project's data directory
:: --   GLOBAL_ResolvedProjectSuiteId                               (FK) owning suite command identifier
:: -- Flags:
:: --   --refresh: forces a reload of the project data, even if it was already loaded in this scope
:: --   --fuck: resolves the project suite's organization and exports:
:: --     GLOBAL_ResolvedProjectOrgId                               (FK) owning organization command identifier

@ECHO OFF

SET "Function_SuiteId=%~1"
SET "Function_ProjectId=%~2"

CALL leprechaun function flags %*

IF NOT DEFINED Function_SuiteId (
    CALL FnEtcLogError "FnEtcResolveProject" "Missing required argument ^<SuiteId^>"
    EXIT /B 1
)

IF NOT DEFINED Function_ProjectId (
    CALL FnEtcLogError "FnEtcResolveProject" "Missing required argument ^<ProjectId^>"
    EXIT /B 1
)

IF /I "%GLOBAL_ResolvedProjectId%"=="%Function_ProjectId%" (
    IF NOT DEFINED GLOBAL_FlagRefresh EXIT /B 0
)

SET "GLOBAL_ResolvedProjectId="
SET "GLOBAL_ResolvedProjectIdentifier="
SET "GLOBAL_ResolvedProjectFrameworkId="
SET "GLOBAL_ResolvedProjectName="
SET "GLOBAL_ResolvedProjectType="
SET "GLOBAL_ResolvedProjectRootPath="
SET "GLOBAL_ResolvedProjectIsExternal="
SET "GLOBAL_ResolvedProjectDataPath="
SET "GLOBAL_ResolvedProjectSuiteId="
SET "GLOBAL_ResolvedProjectOrgId="

CALL leprechaun function data Projects "%Function_SuiteId%"
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_Index=0"
FOR %%P IN (%GLOBAL_DataProjects%) DO (
    IF DEFINED GLOBAL_ResolvedProjectId EXIT /B 0

    IF /I "%%P"=="%Function_ProjectId%" (
        CALL leprechaun function env DataPath
        IF ERRORLEVEL 1 EXIT /B 1

        CALL SET "GLOBAL_ResolvedProjectIdentifier=%%GLOBAL_DataProject%%Local_Index%%Identifier%%"
        CALL SET "GLOBAL_ResolvedProjectLabel=%%GLOBAL_DataProject%%Local_Index%%Label%%"
        CALL SET "GLOBAL_ResolvedProjectRootPath=%%GLOBAL_DataProject%%Local_Index%%Root%%"
        CALL SET "GLOBAL_ResolvedProjectType=%%GLOBAL_DataProject%%Local_Index%%Type%%"
        CALL SET "GLOBAL_ResolvedProjectIsExternal=%%GLOBAL_DataProject%%Local_Index%%IsExternal%%"
        CALL SET "GLOBAL_ResolvedProjectSuiteId=%%GLOBAL_DataProject%%Local_Index%%SuiteId%%"
        IF DEFINED GLOBAL_FlagFuck (
            CALL leprechaun function resolve Suite "%Function_SuiteId%"
            CALL SET "GLOBAL_ResolvedProjectOrgId=%%GLOBAL_ResolvedSuiteOrgId%%"
            IF ERRORLEVEL 1 (
                CALL leprechaun function log warning FnEtcResolveProject "Failed to resolve suite %Function_SuiteId%"
            )
        )
        SET "GLOBAL_ResolvedProjectId=%Function_ProjectId%"
        SET "GLOBAL_ResolvedProjectDataPath=%GLOBAL_DataPath%\Data\Organizations\%GLOBAL_ResolvedOrgIdentifier%\Suites\%GLOBAL_ResolvedSuiteIdentifier%"
        SET "Function_SuiteId="
        SET "Function_ProjectId="
        SET "Local_Index="
        EXIT /B 0
    )

    SET /A Local_Index+=1
)

SET "Function_SuiteId="
SET "Function_ProjectId="
SET "Local_Index="
EXIT /B 0