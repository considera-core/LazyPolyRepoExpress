:: FnEtcResolveProject <SuiteId> <ProjectId> <Flag[]>
:: leprechaun function resolve Project <SuiteId> <ProjectId>
:: -- Resolves a suite project from the data store, and exports:
:: --   GLOBAL_ResolvedProjectId            (ProjectIdentifier) command identifier
:: --   GLOBAL_ResolvedProjectIdentifier    (ProjectFriendlyIdentifier) directory name
:: --   GLOBAL_ResolvedProjectFrameworkId   (ProjectFrameworkIdentifier) framework identifier
:: --   GLOBAL_ResolvedProjectName          (ProjectFriendlyName) friendly name
:: --   GLOBAL_ResolvedProjectType          (ProjectType) Server, Client or Misc
:: --   GLOBAL_ResolvedProjectRootPath      (Computed) absolute path to the project root
:: --   GLOBAL_ResolvedProjectIsExternal    (IsExternal) true or false
:: --   GLOBAL_ResolvedProjectDataPath      (Computed) absolute path to this project's data directory
:: --   GLOBAL_ResolvedProjectSuiteId       (FK) owning suite command identifier
:: --   GLOBAL_ResolvedProjectOrgId         (FK) owning organization command identifier
:: -- Flags:
:: --   --refresh: resolve again even when this project is already in scope
:: --
:: -- RootPath is computed, not read: Projects.csv holds a path relative to the
:: -- suite, which is joined to the suite root and the drive the CLI lives on. It
:: -- is not checked for existence, so a dry run works on a machine where the
:: -- suite is not checked out; callers doing real work check.
:: --
:: -- NOTE: Locals are Export_ rather than Function_ on purpose. With no
:: --       SETLOCAL, a Function_ name here would be the CALLER's variable,
:: --       and clearing one on the way out would blank it under them.
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_ResolvedProject values.

@ECHO OFF

SET "Export_SuiteId=%~1"
SET "Export_ProjectId=%~2"

IF NOT DEFINED Export_SuiteId (
    CALL FnEtcLogError FnEtcResolveProject "Missing required argument <SuiteId>"
    EXIT /B 1
)

IF NOT DEFINED Export_ProjectId (
    CALL FnEtcLogError FnEtcResolveProject "Missing required argument <ProjectId>"
    EXIT /B 1
)

CALL FnEtcFlags %*

IF /I "%GLOBAL_ResolvedProjectId%"=="%Export_ProjectId%" IF /I "%GLOBAL_ResolvedProjectSuiteId%"=="%Export_SuiteId%" IF NOT DEFINED GLOBAL_FlagRefresh (
    SET "Export_SuiteId="
    SET "Export_ProjectId="
    EXIT /B 0
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

CALL FnEtcEnvGetRootRepoPath
IF ERRORLEVEL 1 EXIT /B 1

:: Reads the suite and its organization on the way in, so the suite root and
:: both directory names are in scope by the time a row matches.
CALL FnEtcDataProjects "%Export_SuiteId%"
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_ProjectIndex=0"
FOR %%P IN (%GLOBAL_DataProjects%) DO CALL :Row "%%P"

IF NOT DEFINED GLOBAL_ResolvedProjectId (
    CALL FnEtcLogError FnEtcResolveProject "Unknown project %Export_ProjectId% in suite %Export_SuiteId%"
    ECHO   Projects: %GLOBAL_DataProjects%
    SET "Export_SuiteId="
    SET "Export_ProjectId="
    SET "Local_ProjectIndex="
    EXIT /B 1
)

SET "Export_SuiteId="
SET "Export_ProjectId="
SET "Local_ProjectIndex="
SET "Local_ProjectRel="
SET "Local_ProjectDrive="
EXIT /B 0

:Row
    IF DEFINED GLOBAL_ResolvedProjectId EXIT /B 0
    IF /I NOT "%~1"=="%Export_ProjectId%" GOTO RowNext

    CALL SET "GLOBAL_ResolvedProjectIdentifier=%%GLOBAL_DataProject%Local_ProjectIndex%Identifier%%"
    CALL SET "GLOBAL_ResolvedProjectFrameworkId=%%GLOBAL_DataProject%Local_ProjectIndex%FrameworkId%%"
    CALL SET "GLOBAL_ResolvedProjectName=%%GLOBAL_DataProject%Local_ProjectIndex%Name%%"
    CALL SET "GLOBAL_ResolvedProjectType=%%GLOBAL_DataProject%Local_ProjectIndex%Type%%"
    CALL SET "GLOBAL_ResolvedProjectIsExternal=%%GLOBAL_DataProject%Local_ProjectIndex%IsExternal%%"
    CALL SET "Local_ProjectRel=%%GLOBAL_DataProject%Local_ProjectIndex%RootPath%%"

    SET "GLOBAL_ResolvedProjectId=%Export_ProjectId%"
    SET "GLOBAL_ResolvedProjectSuiteId=%Export_SuiteId%"
    SET "GLOBAL_ResolvedProjectOrgId=%GLOBAL_ResolvedSuiteOrgId%"
    SET "GLOBAL_ResolvedProjectDataPath=%GLOBAL_ResolvedSuiteDataPath%"

    :: Suite root and project root are stored with forward slashes and no drive.
    FOR %%I IN ("%GLOBAL_RootRepoPath%") DO SET "Local_ProjectDrive=%%~dI"
    SET "Local_ProjectRel=%GLOBAL_ResolvedSuiteRootPath%%Local_ProjectRel%"
    SET "Local_ProjectRel=%Local_ProjectRel:/=\%"
    SET "GLOBAL_ResolvedProjectRootPath=%Local_ProjectDrive%%Local_ProjectRel%"
    EXIT /B 0

:RowNext
    SET /A Local_ProjectIndex+=1
    EXIT /B 0
