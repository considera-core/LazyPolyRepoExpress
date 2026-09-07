:: FnUnityDispatch <SuiteId> <ProjectId> <ActionId> <Arg[]> <Flag[]>
:: leprechaun function unity dispatch <SuiteId> <ProjectId> <ActionId> <Arg[]> <Flag[]>
:: -- Validates the action for the unity module and invokes the leaf function:
:: --
:: --   FnUnity<Action> SuiteId ProjectId --args ARGS... FLAGS...   (single project)
:: --   FnUnity<Action> SuiteId --projects P... --args ARGS...      (selected projects)
:: --   FnUnity<Action> SuiteId --args ARGS... FLAGS...             (all projects)
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
    CALL FnEtcResolveSuite "%Input_SuiteId%"
    IF ERRORLEVEL 1 GOTO Failure

    IF DEFINED Input_ProjectId (
        CALL FnEtcResolveProject "%Input_SuiteId%" "%Input_ProjectId%"
        IF ERRORLEVEL 1 GOTO Failure
    )

    :: Docs.md keeps the grammar testable ahead of the leaves being written, so a
    :: dry run reports the call it would have made rather than failing on a file
    :: that is not there yet. Outside a dry run a missing leaf is a real error.
    IF NOT EXIST "%~dp0Fn%Input_Pascal%%Input_Suffix%.bat" GOTO Missing

    CALL leprechaun function %Input_Module% %Input_Suffix% "%Input_SuiteId%" %Input_ProjectArg% %Input_Tail%
    IF ERRORLEVEL 1 GOTO Failure

    GOTO Destructor

:Missing
    CALL FnEtcLogRun FnUnityDispatch "fn=Fn%Input_Pascal%%Input_Suffix% suite=%Input_SuiteId% project=%Input_ProjectId% args=%Input_Args% projects=%Input_Projects% flags=%Input_Passthru%"
    IF DEFINED Input_DryRun GOTO Destructor
    SET "Input_Error=Not implemented yet: Fn%Input_Pascal%%Input_Suffix%"
    GOTO Failure

:Constructor
    SET "Input_Module=unity"
    SET "Input_Pascal=Unity"
    :: <action>:<function suffix>
    SET "Input_Actions=open:Open build:Build"

    SET "Input_Args="
    SET "Input_Tail="
    SET "Input_Suffix="
    SET "Input_ProjectArg="
    SET "Input_Error="
    SET "Input_ReturnCode=0"

    CALL FnEtcFlags %*

    :: Snapshot at once. The resolvers below parse flags of their own and do not
    :: SETLOCAL, so reading GLOBAL_Flag* after one of them would find it cleared.
    :: Positionals are read rather than %1..%3 so a flag can never be mistaken
    :: for a name: an absent project arrives as "" and simply is not defined.
    SET "Input_SuiteId=%GLOBAL_FlagArg1%"
    SET "Input_ProjectId=%GLOBAL_FlagArg2%"
    SET "Input_ActionId=%GLOBAL_FlagArg3%"
    SET "Input_Argc=%GLOBAL_FlagArgc%"
    SET "Input_Prompt=%GLOBAL_FlagArgs%"
    SET "Input_Projects=%GLOBAL_FlagProjects%"
    SET "Input_Passthru=%GLOBAL_FlagPassthru%"
    SET "Input_DryRun=%GLOBAL_FlagDryRun%"

    SET "Local_Index=4"
    GOTO CollectArgs

:CollectArgs
    :: Everything after the action is an ARG.
    IF %Local_Index% GTR %Input_Argc% GOTO CollectedArgs
    CALL SET "Local_Token=%%GLOBAL_FlagArg%Local_Index%%%"
    SET "Input_Args=%Input_Args% %Local_Token%"
    SET /A Local_Index+=1
    GOTO CollectArgs

:CollectedArgs
    IF DEFINED Input_Prompt SET "Input_Args=%Input_Args% %Input_Prompt%"
    IF DEFINED Input_Args SET "Input_Args=%Input_Args:~1%"
    GOTO Validate

:Validate
    IF NOT DEFINED Input_SuiteId (
        SET "Input_Error=Missing required argument <SuiteId>"
        GOTO Failure
    )

    IF NOT DEFINED Input_ActionId (
        SET "Input_Error=Missing action for the %Input_Module% module"
        GOTO Usage
    )

    FOR %%A IN (%Input_Actions%) DO FOR /F "tokens=1,2 delims=:" %%X IN ("%%A") DO IF /I "%%X"=="%Input_ActionId%" SET "Input_Suffix=%%Y"

    IF NOT DEFINED Input_Suffix (
        SET "Input_Error=Unknown %Input_Module% action %Input_ActionId%"
        GOTO Usage
    )

    :: An empty project or arg list is omitted rather than passed as "", so the
    :: leaf sees one of its three documented forms and --args never arrives bare.
    IF DEFINED Input_ProjectId SET "Input_ProjectArg="%Input_ProjectId%""
    IF DEFINED Input_Args SET "Input_Tail=%Input_Tail% --args %Input_Args%"
    IF DEFINED Input_Projects SET "Input_Tail=%Input_Tail% -p %Input_Projects%"
    IF DEFINED Input_Passthru SET "Input_Tail=%Input_Tail% %Input_Passthru%"
    IF DEFINED Input_Tail SET "Input_Tail=%Input_Tail:~1%"
    GOTO Main

:Usage
    CALL FnEtcLogError FnUnityDispatch "%Input_Error%"
    SET "Input_Error="
    ECHO   Usage: ^<SUITE^> unity ^<ACTION^> ^<ARGS...^> ^<FLAGS...^>
    ECHO          ^<SUITE^> ^<PROJECT^> unity ^<ACTION^> ^<ARGS...^>
    ECHO          ^<SUITE^> unity ^<ACTION^> -p ^<PROJECTS...^>
    ECHO   Actions: open build
    GOTO Failure

:Failure
    SET "Input_ReturnCode=1"
    GOTO Destructor

:Destructor
    :: GOTO takes no arguments, so the return code travels in a variable. A
    :: called function that already logged its own failure leaves Input_Error
    :: empty, which is what keeps one fault from being reported at every layer.
    IF DEFINED Input_Error CALL FnEtcLogError FnUnityDispatch "%Input_Error%"
    EXIT /B %Input_ReturnCode%
