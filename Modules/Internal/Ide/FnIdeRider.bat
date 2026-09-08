:: FnIdeRider <OrgId> <SuiteId> <ProjectId>
:: -- Input:
:: --   <OrgId>             The ID of the organization
:: --   <SuiteId>           The ID of the suite
:: --   <ProjectId>         The ID of the project
:: -- Output:
:: --   void strout

@ECHO OFF

:: INPUT
SET "Input_OrgId=%~1"
SET "Input_SuiteId=%~2"
SET "Input_ProjectId=%~3"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument <OrgId>. Expected FnIdeRider <OrgId> <SuiteId> <ProjectId>" & EXIT /B 1
IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "Missing required argument <SuiteId>. Expected FnIdeRider <OrgId> <SuiteId> <ProjectId>" & EXIT /B 1
IF NOT DEFINED Input_ProjectId CALL FnEtcLogError %~n0 "Missing required argument <ProjectId>. Expected FnIdeRider <OrgId> <SuiteId> <ProjectId>" & EXIT /B 1

:: RESOLVE
CALL FnEtcResolveOrganization "%Input_OrgId%"
CALL FnEtcResolveSuite "%Input_OrgId%" "%Input_SuiteId%"
CALL FnEtcResolveProject "%Input_OrgId%" "%Input_SuiteId%" "%Input_ProjectId%"
IF ERRORLEVEL 1 EXIT /B 1

ECHO Opening Rider IDE for %Input_OrgId%/%Input_SuiteId%/%Input_ProjectId%
CALL rider64.exe "%Output_Resolved_OrgRootPath%\%Output_Resolved_SuiteRootPath%\%Output_Resolved_ProjectRootPath%"
IF ERRORLEVEL 1 EXIT /B 1

EXIT /B 0