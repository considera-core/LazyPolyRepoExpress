:: FnEtcResolveProject <OrgId> <SuiteId> <ProjectId>
:: -- Output:
:: --   Output_Resolved_ProjectId            (ProjectIdentifier) command identifier
:: --   Output_Resolved_ProjectIdentifier    (ProjectFriendlyIdentifier) directory name
:: --   Output_Resolved_ProjectFrameworkId   (ProjectFrameworkIdentifier) framework identifier
:: --   Output_Resolved_ProjectName          (ProjectFriendlyName) friendly name
:: --   Output_Resolved_ProjectType          (ProjectType) Server, Client or Misc
:: --   Output_Resolved_ProjectRootPath      (RootPath) absolute path to the project root
:: --   Output_Resolved_ProjectIsExternal    (IsExternal) true or false
:: --   Output_Resolved_ProjectDataPath      (Computed) absolute path to this project's data directory
:: --   Output_Resolved_ProjectSuiteId       (FK) owning suite command identifier
:: --   Output_Resolved_ProjectOrgId         (FK) owning organization command identifier

@ECHO OFF

:: INPUT
SET "Input_OrgId=%~1"
SET "Input_SuiteId=%~2"
SET "Input_ProjectId=%~3"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument <OrgId>" & EXIT /B 1
IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "Missing required argument <SuiteId>" & EXIT /B 1
IF NOT DEFINED Input_ProjectId CALL FnEtcLogError %~n0 "Missing required argument <ProjectId>" & EXIT /B 1

:: CACHE
CALL FnEtcCacheGet ProjectId "[%Input_OrgId%][%Input_SuiteId%][%Input_ProjectId%]" || CALL FnEtcDataProjects %Input_OrgId% %Input_SuiteId%
CALL FnEtcCacheGet ProjectIdentifier "[%Input_OrgId%][%Input_SuiteId%][%Input_ProjectId%]" || CALL FnEtcDataProjects %Input_OrgId% %Input_SuiteId%
CALL FnEtcCacheGet ProjectFrameworkId "[%Input_OrgId%][%Input_SuiteId%][%Input_ProjectId%]" || CALL FnEtcDataProjects %Input_OrgId% %Input_SuiteId%
CALL FnEtcCacheGet ProjectName "[%Input_OrgId%][%Input_SuiteId%][%Input_ProjectId%]" || CALL FnEtcDataProjects %Input_OrgId% %Input_SuiteId%
CALL FnEtcCacheGet ProjectType "[%Input_OrgId%][%Input_SuiteId%][%Input_ProjectId%]" || CALL FnEtcDataProjects %Input_OrgId% %Input_SuiteId%
CALL FnEtcCacheGet ProjectRootPath "[%Input_OrgId%][%Input_SuiteId%][%Input_ProjectId%]" || CALL FnEtcDataProjects %Input_OrgId% %Input_SuiteId%
CALL FnEtcCacheGet ProjectIsExternal "[%Input_OrgId%][%Input_SuiteId%][%Input_ProjectId%]" || CALL FnEtcDataProjects %Input_OrgId% %Input_SuiteId%

IF DEFINED Output_Cache_ProjectId IF DEFINED Output_Cache_ProjectIdentifier IF DEFINED Output_Cache_ProjectFrameworkId IF DEFINED Output_Cache_ProjectName IF DEFINED Output_Cache_ProjectType IF DEFINED Output_Cache_ProjectRootPath IF DEFINED Output_Cache_ProjectIsExternal (
    CALL SET "Output_Resolved_ProjectId=%Output_Cache_ProjectId%"
    CALL SET "Output_Resolved_ProjectIdentifier=%Output_Cache_ProjectIdentifier%"
    CALL SET "Output_Resolved_ProjectFrameworkId=%Output_Cache_ProjectFrameworkId%"
    CALL SET "Output_Resolved_ProjectName=%Output_Cache_ProjectName%"
    CALL SET "Output_Resolved_ProjectType=%Output_Cache_ProjectType%"
    CALL SET "Output_Resolved_ProjectRootPath=%Output_Cache_ProjectRootPath%"
    CALL SET "Output_Resolved_ProjectIsExternal=%Output_Cache_ProjectIsExternal%"
    EXIT /B 0
)

:: MAPPING
SETLOCAL EnableDelayedExpansion
SET "Local_Index=0"
FOR %%P IN (%Output_Data_Projects%) DO (
    IF NOT DEFINED Output_Resolved_ProjectId (
        IF /I NOT "%Input_ProjectId%"=="%%P" (
            SET /A Local_Index+=1
        ) ELSE (
            CALL SET "Local_ProjectId=%%P"
            CALL SET "Local_ProjectIdentifier=!Output_Data_Project%Local_Index%Identifier!"
            CALL SET "Local_ProjectFrameworkId=!Output_Data_Project%Local_Index%FrameworkId!"
            CALL SET "Local_ProjectName=!Output_Data_Project%Local_Index%Name!"
            CALL SET "Local_ProjectType=!Output_Data_Project%Local_Index%Type!"
            CALL SET "Local_ProjectIsExternal=!Output_Data_Project%Local_Index%IsExternal!"
            CALL SET "Local_ProjectRootPath=!Output_Data_Project%Local_Index%RootPath!"
        )
    )
)

ENDLOCAL ^
    & SET "Output_Resolved_ProjectId=%Local_ProjectId%" ^
    & SET "Output_Resolved_ProjectIdentifier=%Local_ProjectIdentifier%" ^
    & SET "Output_Resolved_ProjectFrameworkId=%Local_ProjectFrameworkId%" ^
    & SET "Output_Resolved_ProjectName=%Local_ProjectName%" ^
    & SET "Output_Resolved_ProjectType=%Local_ProjectType%" ^
    & SET "Output_Resolved_ProjectIsExternal=%Local_ProjectIsExternal%" ^
    & SET "Output_Resolved_ProjectRootPath=%Local_ProjectRootPath%"

IF NOT DEFINED Output_Resolved_ProjectId CALL FnEtcLogError %~n0 "Unknown project %Input_ProjectId%" & EXIT /B 1

EXIT /B 0
