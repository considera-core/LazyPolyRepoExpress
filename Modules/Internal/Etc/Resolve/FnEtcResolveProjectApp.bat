:: FnEtcResolveProjectApp <SuiteId> <ProjectId> <AppId> <Flags...>
:: -- Resolves a suite project app from the data store, and exports:
:: --   GLOBAL_ResolvedProjectAppId             (AppCommandIdentifier) command identifier
:: --   GLOBAL_ResolvedProjectAppLabel          (AppFriendlyName) friendly name
:: --   GLOBAL_ResolvedProjectAppDescription    (AppFriendlyDescription) friendly description
:: --   GLOBAL_ResolvedProjectAppProjectId      (FK) owning suite project command identifier
:: -- Flags:
:: --   --refresh: forces a reload of the project app data, even if it was already loaded in this scope
:: --   --org: resolves the project suite's organization and exports:
:: --     GLOBAL_ResolvedProjectAppOrgId        (FK) owning organization command identifier
:: --     GLOBAL_ResolvedProjectAppSuiteId      (FK) owning suite command identifier

@ECHO OFF

SET "Function_SuiteId=%~1"
SET "Function_ProjectId=%~2"
SET "Function_AppId=%~3"
SET "Function_Index=0"

IF NOT DEFINED Function_SuiteId (
    CALL FnEtcLogError "FnEtcResolveProjectApp" "Missing required argument ^<SuiteId^>"
    EXIT /B 1
)

IF NOT DEFINED Function_ProjectId (
    CALL FnEtcLogError "FnEtcResolveProjectApp" "Missing required argument ^<ProjectId^>"
    EXIT /B 1
)

IF NOT DEFINED Function_AppId (
    CALL FnEtcLogError "FnEtcResolveProjectApp" "Missing required argument ^<AppId^>"
    EXIT /B 1
)

IF /I "%GLOBAL_ResolvedProjectAppId%"=="%Function_AppId%" (
    CALL FnEtcFlags %*
    IF NOT DEFINED GLOBAL_FlagRefresh EXIT /B 0
)

SET "GLOBAL_ResolvedProjectAppId="
CALL FnEtcCsvProjectApps "%Function_SuiteId%" "%Function_ProjectId%"
IF ERRORLEVEL 1 EXIT /B 1

FOR %%A IN (%GLOBAL_DataProjectApps%) DO (
    IF DEFINED GLOBAL_ResolvedProjectAppId EXIT /B 0

    IF /I "%%A"=="%Function_AppId%" (
        SET "GLOBAL_ResolvedProjectAppId=%Function_AppId%"
        CALL SET "GLOBAL_ResolvedProjectAppLabel=%%GLOBAL_PROJECTAPP_%Function_AppId%_NAME%%"
        CALL SET "GLOBAL_ResolvedProjectAppDescription=%%GLOBAL_PROJECTAPP_%Function_AppId%_DESCRIPTION%%"
        CALL SET "GLOBAL_ResolvedProjectAppProjectId=%%GLOBAL_PROJECTAPP_%Function_AppId%_PROJECTID%%"
        EXIT /B 0
    )

    SET /A Function_Index+=1
)

SET "Function_Index="
EXIT /B 0