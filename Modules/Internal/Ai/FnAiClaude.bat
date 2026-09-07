:: FnAiClaude <SuiteId> <ProjectId> --args <Arg[]> <Flag[]>              (single project, base case)
:: FnAiClaude <SuiteId> --projects <ProjectId[]> --args <Arg[]> <Flag[]> (selected projects)
:: FnAiClaude <SuiteId> --args <Arg[]> <Flag[]>                          (all projects)
:: leprechaun function ai claude <SuiteId> <ProjectId> --args <Arg[]> <Flag[]>
:: -- Opens Claude Code in a project, with args as the initial prompt.
:: -- Flags:
:: --   --here:               run in this window instead of spawning a new one
:: --   -v, --verbose:        verbose
:: --   -d, --dry-run:        report what would run, do not run it
:: --
:: -- The reference leaf. All three forms are the same script: called without a
:: -- single project it hands itself to FnEtcForEachProject, and each expansion
:: -- re-enters here with one project, which is the only form that does work.
:: -- FnEtcForEachProject picks the project list, honouring --projects when it is
:: -- set, so both fan out forms are one branch here.
:: --
:: -- ARGS arrive as --args rather than as trailing positionals, which is what
:: -- keeps positional 2 unambiguously a project on the way down.

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    IF DEFINED Input_ProjectId GOTO Base

    :: Fan out. FnEtcForEachProject re-enters this script once per project, so
    :: the recursion terminates at the base case below.
    CALL FnEtcForEachProject "%Input_SuiteId%" FnAiClaude %Input_Tail%
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Destructor

:Base
    CALL FnEtcResolveProject "%Input_SuiteId%" "%Input_ProjectId%"
    IF ERRORLEVEL 1 GOTO Failure

    :: Reported before the directory is checked, so a dry run works on a machine
    :: where the suite is not checked out.
    IF DEFINED Input_DryRun (
        CALL FnEtcLogRun FnAiClaude "fn=FnAiClaude suite=%Input_SuiteId% project=%Input_ProjectId% path=%Output_Resolved_ProjectRootPath% prompt=%Input_Prompt% flags=%Input_Passthru%"
        GOTO Destructor
    )

    IF NOT EXIST "%Output_Resolved_ProjectRootPath%" (
        SET "Input_Error=Project path not found: %Output_Resolved_ProjectRootPath%"
        GOTO Failure
    )

    CALL FnEtcLogInfo FnAiClaude "Running Claude Code for %Input_SuiteId%/%Input_ProjectId% (%Output_Resolved_ProjectName%)"

    IF DEFINED Input_Verbose (
        CALL FnEtcLogDebug FnAiClaude "path %Output_Resolved_ProjectRootPath%"
    )

    IF DEFINED Input_Verbose IF DEFINED Input_Prompt (
        CALL FnEtcLogDebug FnAiClaude "prompt %Input_Prompt%"
    )

    IF DEFINED Input_Here GOTO Here
    GOTO Spawn

:Here
    PUSHD "%Output_Resolved_ProjectRootPath%"
    IF ERRORLEVEL 1 (
        SET "Input_Error=Could not enter %Output_Resolved_ProjectRootPath%"
        GOTO Failure
    )
    CALL claude %Input_Prompt%
    SET "Input_ReturnCode=%ERRORLEVEL%"
    POPD
    GOTO Destructor

:Spawn
    :: A new Windows Terminal tab per project, so a fan out over a whole suite
    :: does not serialise behind one interactive session.
    wt -w 0 -d "%Output_Resolved_ProjectRootPath%" --title "Claude Code - %Input_ProjectId%" cmd /k claude %Input_Prompt%
    IF ERRORLEVEL 1 (
        SET "Input_Error=Could not spawn a window. Is Windows Terminal (wt) installed? Add --here to run in this window instead."
        GOTO Failure
    )
    GOTO Destructor

:Constructor
    SET "Input_Tail="
    SET "Input_Error="
    SET "Input_ReturnCode=0"

    CALL FnEtcFlags %*

    :: Read from the parsed positionals rather than %1 and %2. FnEtcFlags counts
    :: only positionals, so a flag can never be mistaken for the project: in the
    :: fan out form "<suite> --args hello" there simply is no positional 2.
    SET "Input_SuiteId=%GLOBAL_FlagArg1%"
    SET "Input_ProjectId=%GLOBAL_FlagArg2%"

    :: Snapshotted for the same reason: FnEtcResolveProject parses flags of its
    :: own and does not SETLOCAL, so GLOBAL_Flag* is gone by the time the base
    :: case below runs.
    SET "Input_Prompt=%GLOBAL_FlagArgs%"
    SET "Input_DryRun=%GLOBAL_FlagDryRun%"
    SET "Input_Verbose=%GLOBAL_FlagVerbose%"
    SET "Input_Here=%GLOBAL_FlagHere%"
    SET "Input_Passthru=%GLOBAL_FlagPassthru%"

    :: Rebuilt rather than shifted, so the recursion carries its prompt and flags
    :: regardless of the order they were given in. The project is deliberately
    :: left out: FnEtcForEachProject supplies that.
    IF DEFINED Input_Prompt SET "Input_Tail=%Input_Tail% --args %Input_Prompt%"
    IF DEFINED GLOBAL_FlagProjects SET "Input_Tail=%Input_Tail% -p %GLOBAL_FlagProjects%"
    IF DEFINED Input_Passthru SET "Input_Tail=%Input_Tail% %Input_Passthru%"
    IF DEFINED Input_Tail SET "Input_Tail=%Input_Tail:~1%"
    GOTO Validate

:Validate
    IF NOT DEFINED Input_SuiteId (
        SET "Input_Error=Missing required argument <SuiteId>"
        GOTO Failure
    )
    GOTO Main

:Failure
    SET "Input_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Input_Error CALL FnEtcLogError FnAiClaude "%Input_Error%"
    SET "Input_SuiteId="
    SET "Input_ProjectId="
    SET "Input_Tail="
    SET "Input_Error="
    EXIT /B %Input_ReturnCode%
