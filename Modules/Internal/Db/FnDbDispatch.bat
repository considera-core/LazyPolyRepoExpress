:: FnDbDispatch <SuiteId> <ProjectId> <ActionId> <Arg[]> <Flag[]>
:: leprechaun function db dispatch <SuiteId> <ProjectId> <ActionId> <Arg[]> <Flag[]>
:: -- Validates the action for the db module and invokes the leaf function:
:: --
:: --   FnDb<Action> SuiteId ProjectId --args ARGS... FLAGS...   (single project)
:: --   FnDb<Action> SuiteId --projects P... --args ARGS...      (selected projects)
:: --   FnDb<Action> SuiteId --args ARGS... FLAGS...             (all projects)
:: --
:: -- which is the Function Schema from Docs.md. <ProjectId> may be empty, which
:: -- is the fan out form: the leaf recurses through FnEtcForEachProject until it
:: -- reaches the single project base case, which is the only form that works.
:: --
:: -- The <action>:<FunctionSuffix> map lives here rather than in the router, so
:: -- the action list and the resolved function name cannot drift apart. Only the
:: -- two SET lines below differ between one module dispatcher and the next.

@ECHO OFF
:: No EnableDelayedExpansion: a "!" inside a passthrough arg would be eaten
:: before the leaf function ever saw it.
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    CALL FnEtcResolveSuite "%Function_SuiteId%"
    IF ERRORLEVEL 1 GOTO Failure

    IF DEFINED Function_ProjectId (
        CALL FnEtcResolveProject "%Function_SuiteId%" "%Function_ProjectId%"
        IF ERRORLEVEL 1 GOTO Failure
    )

    :: Docs.md keeps the grammar testable ahead of the leaves being written, so a
    :: dry run reports the call it would have made rather than failing on a file
    :: that is not there yet. Outside a dry run a missing leaf is a real error.
    IF NOT EXIST "%~dp0Fn%Function_Pascal%%Function_Suffix%.bat" GOTO Missing

    CALL leprechaun function %Function_Module% %Function_Suffix% "%Function_SuiteId%" %Function_ProjectArg% %Function_Tail%
    IF ERRORLEVEL 1 GOTO Failure

    GOTO Destructor

:Missing
    CALL FnEtcLogRun FnDbDispatch "fn=Fn%Function_Pascal%%Function_Suffix% suite=%Function_SuiteId% project=%Function_ProjectId% args=%Function_Args% projects=%Function_Projects% flags=%Function_Passthru%"
    IF DEFINED Function_DryRun GOTO Destructor
    SET "Function_Error=Not implemented yet: Fn%Function_Pascal%%Function_Suffix%"
    GOTO Failure

:Constructor
    SET "Function_Module=db"
    SET "Function_Pascal=Db"
    :: <action>:<function suffix>
    SET "Function_Actions=migrate:Migrate seed:Seed reset:Reset"

    SET "Function_Args="
    SET "Function_Tail="
    SET "Function_Suffix="
    SET "Function_ProjectArg="
    SET "Function_Error="
    SET "Function_ReturnCode=0"

    CALL FnEtcFlags %*

    :: Snapshot at once. The resolvers below parse flags of their own and do not
    :: SETLOCAL, so reading GLOBAL_Flag* after one of them would find it cleared.
    :: Positionals are read rather than %1..%3 so a flag can never be mistaken
    :: for a name: an absent project arrives as "" and simply is not defined.
    SET "Function_SuiteId=%GLOBAL_FlagArg1%"
    SET "Function_ProjectId=%GLOBAL_FlagArg2%"
    SET "Function_ActionId=%GLOBAL_FlagArg3%"
    SET "Function_Argc=%GLOBAL_FlagArgc%"
    SET "Function_Prompt=%GLOBAL_FlagArgs%"
    SET "Function_Projects=%GLOBAL_FlagProjects%"
    SET "Function_Passthru=%GLOBAL_FlagPassthru%"
    SET "Function_DryRun=%GLOBAL_FlagDryRun%"

    SET "Local_Index=4"
    GOTO CollectArgs

:CollectArgs
    :: Everything after the action is an ARG.
    IF %Local_Index% GTR %Function_Argc% GOTO CollectedArgs
    CALL SET "Local_Token=%%GLOBAL_FlagArg%Local_Index%%%"
    SET "Function_Args=%Function_Args% %Local_Token%"
    SET /A Local_Index+=1
    GOTO CollectArgs

:CollectedArgs
    IF DEFINED Function_Prompt SET "Function_Args=%Function_Args% %Function_Prompt%"
    IF DEFINED Function_Args SET "Function_Args=%Function_Args:~1%"
    GOTO Validate

:Validate
    IF NOT DEFINED Function_SuiteId (
        SET "Function_Error=Missing required argument <SuiteId>"
        GOTO Failure
    )

    IF NOT DEFINED Function_ActionId (
        SET "Function_Error=Missing action for the %Function_Module% module"
        GOTO Usage
    )

    FOR %%A IN (%Function_Actions%) DO FOR /F "tokens=1,2 delims=:" %%X IN ("%%A") DO IF /I "%%X"=="%Function_ActionId%" SET "Function_Suffix=%%Y"

    IF NOT DEFINED Function_Suffix (
        SET "Function_Error=Unknown %Function_Module% action %Function_ActionId%"
        GOTO Usage
    )

    :: An empty project or arg list is omitted rather than passed as "", so the
    :: leaf sees one of its three documented forms and --args never arrives bare.
    IF DEFINED Function_ProjectId SET "Function_ProjectArg="%Function_ProjectId%""
    IF DEFINED Function_Args SET "Function_Tail=%Function_Tail% --args %Function_Args%"
    IF DEFINED Function_Projects SET "Function_Tail=%Function_Tail% -p %Function_Projects%"
    IF DEFINED Function_Passthru SET "Function_Tail=%Function_Tail% %Function_Passthru%"
    IF DEFINED Function_Tail SET "Function_Tail=%Function_Tail:~1%"
    GOTO Main

:Usage
    CALL FnEtcLogError FnDbDispatch "%Function_Error%"
    SET "Function_Error="
    ECHO   Usage: ^<SUITE^> db ^<ACTION^> ^<ARGS...^> ^<FLAGS...^>
    ECHO          ^<SUITE^> ^<PROJECT^> db ^<ACTION^> ^<ARGS...^>
    ECHO          ^<SUITE^> db ^<ACTION^> -p ^<PROJECTS...^>
    ECHO   Actions: migrate seed reset
    GOTO Failure

:Failure
    SET "Function_ReturnCode=1"
    GOTO Destructor

:Destructor
    :: GOTO takes no arguments, so the return code travels in a variable. A
    :: called function that already logged its own failure leaves Function_Error
    :: empty, which is what keeps one fault from being reported at every layer.
    IF DEFINED Function_Error CALL FnEtcLogError FnDbDispatch "%Function_Error%"
    EXIT /B %Function_ReturnCode%
