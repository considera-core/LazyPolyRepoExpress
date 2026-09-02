:: FnGitBranch <ProjectId> <...Flags>

@ECHO OFF

SET "Input_ProjectId=%~1"

IF NOT DEFINED Input_ProjectId (
    ECHO "Missing required argument <ProjectId>"
    EXIT /B 1
)

CALL FnEtcFlags %*
CALL FnEtcResolveProject "%Input_ProjectId%"
IF ERRORLEVEL 1 EXIT /B 1

CALL GIT -C "%GLOBAL_ResolvedProjectRootPath%" "branch" "--show-current"