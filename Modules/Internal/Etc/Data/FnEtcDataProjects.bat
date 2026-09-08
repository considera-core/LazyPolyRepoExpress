:: FnEtcDataProjects <OrgId> <SuiteId>
:: -- Output:
:: --   Output_Data_Projects                     (ProjectIdentifier[]) space separated identifiers
:: --   Output_Data_ProjectsInternal             (ProjectIdentifier[]) the subset with IsExternal false
:: --   Output_Data_ProjectsExternal             (ProjectIdentifier[]) the subset with IsExternal true
:: --   Output_Data_ProjectsCount                (Computed) number of projects
:: --   Output_Data_ProjectsSuiteId              (FK) the suite these projects were read for
:: --   Output_Data_Project<Index>Id             (ProjectIdentifier) command identifier
:: --   Output_Data_Project<Index>Identifier     (ProjectFriendlyIdentifier) directory name
:: --   Output_Data_Project<Index>FrameworkId    (ProjectFrameworkIdentifier) framework identifier
:: --   Output_Data_Project<Index>Name           (ProjectFriendlyName) friendly name
:: --   Output_Data_Project<Index>Type           (ProjectType) Server, Client or Misc
:: --   Output_Data_Project<Index>Description    (ProjectDescription) description of the project
:: --   Output_Data_Project<Index>RootPath       (ProjectRootPath) root path, relative to the suite
:: --   Output_Data_Project<Index>HomeBranch     (ProjectHomeBranch) the branch considered as the home branch for the project
:: --   Output_Data_Project<Index>IsExternal     (IsExternal) true or false
:: --   Output_Data_Project<Index>SuiteId        (FK) owning suite command identifier

@ECHO OFF

:: INPUT
SET "Input_OrgId=%~1"
SET "Input_SuiteId=%~2"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument ^<OrgId^>" & EXIT /B 1
IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "Missing required argument ^<SuiteId^>" & EXIT /B 1

:: RESOLVE
CALL FnEtcCacheGet "OrgIdentifier[%Input_OrgId%]"
SET "Output_Resolved_OrgIdentifier=%Output_Cache_OrgIdentifier%"
IF NOT DEFINED Output_Resolved_OrgIdentifier CALL FnEtcResolveOrganization "%Input_OrgId%"

CALL FnEtcCacheGet "SuiteIdentifier[%Input_OrgId%][%Input_SuiteId%]"
SET "Output_Resolved_SuiteIdentifier=%Output_Cache_SuiteIdentifier%"
IF NOT DEFINED Output_Resolved_SuiteIdentifier CALL FnEtcResolveSuite "%Input_OrgId%" "%Input_SuiteId%"

:: MAPPING(A: Id, B: Identifier, C: FrameworkId, D: Name, E: Type, F: Description, G: RootPath, H: HomeBranch, I: IsExternal)
SET "Output_Data_Projects="
SET "Output_Data_ProjectsInternal="
SET "Output_Data_ProjectsExternal="
SET "Output_Data_ProjectsCount=0"
SET "Local_DataPath=%~dp0..\..\..\..\Data\Organizations\%Output_Resolved_OrgIdentifier%\Suites\%Output_Resolved_SuiteIdentifier%\Projects.csv"
FOR /F "usebackq skip=1 tokens=1-9 delims=, eol=#" %%a IN ("%Local_DataPath%") DO (
    IF DEFINED Output_Data_Projects CALL SET "Output_Data_Projects=%%Output_Data_Projects%% %%a"
    IF NOT DEFINED Output_Data_Projects SET "Output_Data_Projects=%%a"
    IF /I "%%i"=="true" (
        IF DEFINED Output_Data_ProjectsExternal CALL SET "Output_Data_ProjectsExternal=%%Output_Data_ProjectsExternal%% %%a"
        IF NOT DEFINED Output_Data_ProjectsExternal SET "Output_Data_ProjectsExternal=%%a"
    ) ELSE (
        IF DEFINED Output_Data_ProjectsInternal CALL SET "Output_Data_ProjectsInternal=%%Output_Data_ProjectsInternal%% %%a"
        IF NOT DEFINED Output_Data_ProjectsInternal SET "Output_Data_ProjectsInternal=%%a"
    )
    CALL SET "Output_Data_Project%%Output_Data_ProjectsCount%%Id=%%a"
    CALL SET "Output_Data_Project%%Output_Data_ProjectsCount%%Identifier=%%b"
    CALL SET "Output_Data_Project%%Output_Data_ProjectsCount%%FrameworkId=%%c"
    CALL SET "Output_Data_Project%%Output_Data_ProjectsCount%%Name=%%d"
    CALL SET "Output_Data_Project%%Output_Data_ProjectsCount%%Type=%%e"
    CALL SET "Output_Data_Project%%Output_Data_ProjectsCount%%Description=%%f"
    CALL SET "Output_Data_Project%%Output_Data_ProjectsCount%%RootPath=%%g"
    CALL SET "Output_Data_Project%%Output_Data_ProjectsCount%%HomeBranch=%%h"
    CALL SET "Output_Data_Project%%Output_Data_ProjectsCount%%IsExternal=%%i"
    CALL SET "Output_Data_Project%%Output_Data_ProjectsCount%%SuiteId=%Input_SuiteId%"
    SET /A Output_Data_ProjectsCount+=1
    CALL FnEtcCacheSet "Projects[%Input_OrgId%][%Input_SuiteId%]" "%%Output_Data_Projects%%"
    CALL FnEtcCacheSet "ProjectsInternal[%Input_OrgId%][%Input_SuiteId%]" "%%Output_Data_ProjectsInternal%%"
    CALL FnEtcCacheSet "ProjectsExternal[%Input_OrgId%][%Input_SuiteId%]" "%%Output_Data_ProjectsExternal%%"
    CALL FnEtcCacheSet "ProjectsCount[%Input_OrgId%][%Input_SuiteId%]" "%%Output_Data_ProjectsCount%%"
    CALL FnEtcCacheSet "ProjectId[%Input_OrgId%][%Input_SuiteId%][%%a]" "%%a"
    CALL FnEtcCacheSet "ProjectIdentifier[%Input_OrgId%][%Input_SuiteId%][%%a]" "%%b"
    CALL FnEtcCacheSet "ProjectFrameworkId[%Input_OrgId%][%Input_SuiteId%][%%a]" "%%c"
    CALL FnEtcCacheSet "ProjectName[%Input_OrgId%][%Input_SuiteId%][%%a]" "%%d"
    CALL FnEtcCacheSet "ProjectType[%Input_OrgId%][%Input_SuiteId%][%%a]" "%%e"
    CALL FnEtcCacheSet "ProjectDescription[%Input_OrgId%][%Input_SuiteId%][%%a]" "%%f"
    CALL FnEtcCacheSet "ProjectRootPath[%Input_OrgId%][%Input_SuiteId%][%%a]" "%%g"
    CALL FnEtcCacheSet "ProjectHomeBranch[%Input_OrgId%][%Input_SuiteId%][%%a]" "%%h"
    CALL FnEtcCacheSet "ProjectIsExternal[%Input_OrgId%][%Input_SuiteId%][%%a]" "%%i"
    CALL FnEtcCacheSet "ProjectSuiteId[%Input_OrgId%][%Input_SuiteId%][%%a]" "%Input_SuiteId%"
)

IF NOT DEFINED Output_Data_Projects CALL FnEtcLogWarning %~n0 "No projects found in %Local_DataPath%" & EXIT /B 1

SET "Output_Data_ProjectsSuiteId=%Input_SuiteId%"
EXIT /B 0
