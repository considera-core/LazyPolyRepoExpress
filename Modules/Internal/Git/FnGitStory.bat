:: FnGitStory <OrgId> <SuiteId> <ProjectId> <StoryId>
:: -- Input:
:: --   <OrgId>             The ID of the organization
:: --   <SuiteId>           The ID of the suite
:: --   <ProjectId>         The ID of the project
:: --   <StoryId>           The ID of the story
:: -- Output:
:: --   void strout         The result of switching to the story branch

@ECHO OFF

:: INPUT
SET "Input_OrgId=%~1"
SET "Input_SuiteId=%~2"
SET "Input_ProjectId=%~3"
SET "Input_StoryId=%~4"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument <OrgId>. Expected: FnGitStory <OrgId> <SuiteId> <ProjectId> <StoryId>" & EXIT /B 1
IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "Missing required argument <SuiteId>. Expected: FnGitStory <OrgId> <SuiteId> <ProjectId> <StoryId>" & EXIT /B 1
IF NOT DEFINED Input_ProjectId CALL FnEtcLogError %~n0 "Missing required argument <ProjectId>. Expected: FnGitStory <OrgId> <SuiteId> <ProjectId> <StoryId>" & EXIT /B 1
IF NOT DEFINED Input_StoryId CALL FnEtcLogError %~n0 "Missing required argument <StoryId>. Expected: FnGitStory <OrgId> <SuiteId> <ProjectId> <StoryId>" & EXIT /B 1

:: RESOLVE
CALL FnEtcResolveOrganization "%Input_OrgId%"
CALL FnEtcResolveSuite "%Input_OrgId%" "%Input_SuiteId%"
CALL FnEtcResolveProject "%Input_OrgId%" "%Input_SuiteId%" "%Input_ProjectId%"
IF ERRORLEVEL 1 EXIT /B 1

ECHO Switching to story branch for %Input_OrgId%/%Input_SuiteId%/%Input_ProjectId% to work on %Input_StoryId%
CALL FnGitPull "%Input_OrgId%" "%Input_SuiteId%" "%Input_ProjectId%"
git -C "%Output_Resolved_OrgRootPath%\%Output_Resolved_SuiteRootPath%\%Output_Resolved_ProjectRootPath%" switch -c %Input_StoryId%
CALL FnGitPull "%Input_OrgId%" "%Input_SuiteId%" "%Input_ProjectId%"
IF ERRORLEVEL 1 EXIT /B 1

EXIT /B 0