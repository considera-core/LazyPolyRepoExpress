:: FnAiClaude <SuiteId> <ProjectId> --args <Arg[]> <Flag[]>                     (single project, base case)
:: FnAiClaude <SuiteId> --projects <ProjectId[]> --args <Arg[]> <Flag[]>        (selected projects)
:: FnAiClaude <SuiteId> --args <Arg[]> <Flag[]>                                 (all projects)
:: leprechaun function ai claude <SuiteId> <ProjectId> --args <Arg[]> <Flag[]>
:: leprechaun function ai claude <SuiteId> --projects <ProjectId[]> --args <Arg[]> <Flag[]>
:: leprechaun function ai claude <SuiteId> --args <Arg[]> <Flag[]>
:: -- Opens Claude Code in a project, with args as the initial prompt.
:: -- Flags:
:: --   --here:                                                     run in this window instead of spawning a new one
:: --   -v,--verbose:                                               verbose
:: --   -d,--dry-run:                                               report what would run, do not run it

@ECHO OFF
SETLOCAL EnableExtensions

SET "Function_SuiteId=%~1"
SET "Function_ProjectId=%~2"

CALL leprechaun function flags %*
SET "Local_FlagHere=%GLOBAL_FlagHere%"
SET "Local_FlagVerbose=%GLOBAL_FlagVerbose%"
SET "Local_FlagDryRun=%GLOBAL_FlagDryRun%"
SET "Local_FlagProjects=%GLOBAL_FlagProjects%"
SET "Local_FlagArgs=%GLOBAL_FlagArgs%"

IF NOT DEFINED Function_SuiteId (
    CALL leprechaun function log error FnAiClaude "Missing required argument ^<SuiteId^>"
    EXIT /B 1
)

SET "Local_Args=%*"
SHIFT

IF NOT DEFINED Function_ProjectId (
    IF DEFINED Local_FlagProjects (
        CALL leprechaun function for Projects FnAiClaude --projects "%Local_FlagProjects%" "%Local_Args%"
        GOTO DESTRUCTOR 0
    )

    CALL leprechaun function for Projects FnAiClaude "%Function_SuiteId%" "%Local_Args%"
    GOTO DESTRUCTOR 0
)

:: Base
CALL leprechaun function resolve Project "%Function_SuiteId%" "%Function_ProjectId%"
IF ERRORLEVEL 1 GOTO DESTRUCTOR 1

:: IF DEFINED FLAG_DRY_RUN (
::     CALL leprechaun function log run FnAiClaude "suite=%Function_SuiteId% project=%Function_ProjectId% path=%GLOBAL_ResolvedProjectRootPath% prompt=%GLOBAL_FlagArgs_1% flags=%GLOBAL_FlagArgs%"
::     EXIT /B 0
:: )

IF NOT EXIST "%GLOBAL_ResolvedProjectRootPath%" (
    CALL leprechaun function log error FnAiClaude "Project path not found: %GLOBAL_ResolvedProjectRootPath%"
    GOTO DESTRUCTOR 1
)

CALL lprechaun function log info FnAiClaude "Running Claude Code for Claude Code for %Function_SuiteId%/%Function_ProjectId% (%GLOBAL_ResolvedProjectName%)"

IF DEFINED GLOBAL_FlagsVerbose (
    CALL leprechaun function log debug "path %GLOBAL_ResolvedProjectRootPath%"
)

IF DEFINED GLOBAL_FlagsVerbose IF DEFINED AI_ARGS (
    CALL leprechaun function log debug "prompt %GLOBAL_FlagArgs%"
)

IF DEFINED GLOBAL_FlagsHere (
    :: Run here
    PUSHD "%GLOBAL_ResolvedProjectRootPath%" || GOTO :HandleNoPath
    CALL claude %Local_FlagArgs%
    POPD
    GOTO Destructor %ERRORLEVEL%
)

:: A new Windows Terminal tab per project, so a fan out over a whole suite
:: does not serialise behind one interactive session.
wt -w 0 -d "%GLOBAL_ResolvedProjectPath%" --title "Claude Code - %Function_ProjectId%" cmd /k claude %Local_FlagArgs%
IF ERRORLEVEL 1 (
    CALL leprechaun function log error FnAiClaude "Could not spawn a window. Is Windows Terminal (wt) installed?"
    ECHO   Add the --here flag to run in this window instead.
    GOTO Destructor 1
)

GOTO Destructor 0

:HandleNoPath
    CALL leprechaun function log error FnAiClaude "Project path not found: %GLOBAL_ResolvedProjectPath%"
    GOTO DESTRUCTOR 1

:Destructor
    SET "Function_SuiteId="
    SET "Function_ProjectId="
    SET "Local_Args="
    SET "Local_FlagHere="
    SET "Local_FlagVerbose="
    SET "Local_FlagDryRun="
    SET "Local_FlagProjects="
    SET "Local_FlagArgs="
    EXIT /B %~1
