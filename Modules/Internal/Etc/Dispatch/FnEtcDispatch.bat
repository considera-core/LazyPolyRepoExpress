:: FnEtcDispatch <EntryId> <Command...>                     when <EntryId> is Global
:: FnEtcDispatch <EntryId> <ValueId> <Command...>            otherwise
:: leprechaun function dispatch <EntryId> <ValueId> <Command...>
:: -- Front door for every entry script. Applies the Docs.md grammar.
:: --
:: -- Step 1: find MODULE. Scan the positionals left to right for the first token
:: -- that names a module in Data/Modules.csv. That token is MODULE, the next is
:: -- ACTION, and the rest are ARGS. No module means the invocation is External.
:: --
:: -- Step 2: read the prefix by length. Everything before MODULE is the prefix;
:: -- its meaning comes from its length plus the depth of the entry point, so no
:: -- name lookup is needed to tell an ORG from a SUITE:
:: --
:: --   prefix | Global            | Organization  | Suite
:: --   0      | all organizations | all suites    | all projects
:: --   1      | ORG               | SUITE         | PROJECT
:: --   2      | ORG SUITE         | SUITE PROJECT | (error)
:: --   3      | ORG SUITE PROJECT | (error)       | (error)
:: --
:: -- Step 3: fan out. An absent SUITE means every active suite; an absent ORG
:: -- means every organization. The fan out over PROJECTS happens further down,
:: -- inside the leaf, so this layer always hands off exactly one suite at a time.
:: --
:: -- This is the one layer whose arity is genuinely variable, so it parses with
:: -- FnEtcFlags rather than reading fixed positionals. Everything below it takes
:: -- a fixed shape and stays positional.

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    CALL FnEtcDataModules
    IF ERRORLEVEL 1 GOTO Failure

    SET "Local_Index=1"
    GOTO ScanModule

:ScanModule
    IF %Local_Index% GTR %Input_Argc% GOTO ScanDone
    CALL SET "Local_Token=%%Input_Arg%Local_Index%%%"
    FOR %%M IN (%Output_Data_Mods%) DO IF /I "%%M"=="%Local_Token%" SET "Input_ModuleIndex=%Local_Index%"
    IF DEFINED Input_ModuleIndex GOTO ScanDone
    SET /A Local_Index+=1
    GOTO ScanModule

:ScanDone
    :: No module anywhere in the positionals: this is an External invocation.
    IF NOT DEFINED Input_ModuleIndex GOTO External

    CALL SET "Input_ModuleId=%%Input_Arg%Input_ModuleIndex%%%"
    SET /A Local_Index=Input_ModuleIndex+1
    IF %Local_Index% GTR %Input_Argc% (
        SET "Input_Error=Module %Input_ModuleId% needs an action"
        GOTO Failure
    )
    CALL SET "Input_ActionId=%%Input_Arg%Local_Index%%%"

    SET /A Input_PrefixLength=Input_ModuleIndex-1
    GOTO Prefix

:Prefix
    IF /I "%Input_EntryId%"=="Global"       GOTO PrefixGlobal
    IF /I "%Input_EntryId%"=="Organization" GOTO PrefixOrganization
    IF /I "%Input_EntryId%"=="Suite"        GOTO PrefixSuite
    IF /I "%Input_EntryId%"=="Project"      GOTO PrefixProject
    SET "Input_Error=Unknown entry point %Input_EntryId%. Expected Global, Organization, Suite or Project"
    GOTO Failure

:PrefixGlobal
    IF %Input_PrefixLength% GTR 3 GOTO PrefixTooLong
    IF %Input_PrefixLength% GEQ 1 SET "Input_OrgId=%Input_Arg1%"
    IF %Input_PrefixLength% GEQ 2 SET "Input_SuiteId=%Input_Arg2%"
    IF %Input_PrefixLength% GEQ 3 SET "Input_ProjectId=%Input_Arg3%"
    GOTO Resolve

:PrefixOrganization
    IF %Input_PrefixLength% GTR 2 GOTO PrefixTooLong
    SET "Input_OrgId=%Input_ValueId%"
    IF %Input_PrefixLength% GEQ 1 SET "Input_SuiteId=%Input_Arg1%"
    IF %Input_PrefixLength% GEQ 2 SET "Input_ProjectId=%Input_Arg2%"
    GOTO Resolve

:PrefixSuite
    IF %Input_PrefixLength% GTR 1 GOTO PrefixTooLong
    SET "Input_SuiteId=%Input_ValueId%"
    IF %Input_PrefixLength% GEQ 1 SET "Input_ProjectId=%Input_Arg1%"
    GOTO Resolve

:PrefixProject
    SET "Input_Error=Project is not a supported entry depth: subprojects are not modelled in the data"
    GOTO Failure

:PrefixTooLong
    SET "Input_Error=Too many names before %Input_ModuleId% for a %Input_EntryId% entry point"
    GOTO Failure

:Resolve
    :: A name given explicitly must exist, and is rejected here rather than
    :: guessed at further down.
    IF DEFINED Input_OrgId (
        CALL FnEtcResolveOrganization "%Input_OrgId%"
        IF ERRORLEVEL 1 GOTO Failure
    )

    IF DEFINED Input_SuiteId (
        CALL FnEtcResolveSuite "%Input_SuiteId%"
        IF ERRORLEVEL 1 GOTO Failure
    )
    GOTO Tail

:Tail
    :: Everything after ACTION is an ARG. An -a list is appended to them, and -p
    :: rides along so the leaf can fan out over the projects it names.
    SET /A Local_Index=Input_ModuleIndex+2
    GOTO TailCollect

:TailCollect
    IF %Local_Index% GTR %Input_Argc% GOTO TailDone
    CALL SET "Local_Token=%%Input_Arg%Local_Index%%%"
    SET "Input_Tail=%Input_Tail% "%Local_Token%""
    SET /A Local_Index+=1
    GOTO TailCollect

:TailDone
    IF DEFINED Input_Args SET "Input_Tail=%Input_Tail% --args %Input_Args%"
    IF DEFINED Input_Projects SET "Input_Tail=%Input_Tail% -p %Input_Projects%"
    IF DEFINED Input_Passthru SET "Input_Tail=%Input_Tail% %Input_Passthru%"
    IF DEFINED Input_Tail SET "Input_Tail=%Input_Tail:~1%"
    GOTO Fanout

:Fanout
    :: One suite at a time, always. The iterators supply the missing name and
    :: leave the argument order untouched, because FnEtcDispatchInternal takes
    :: SuiteId first and FnEtcForEachSuite supplies exactly that.
    IF DEFINED Input_SuiteId (
        CALL FnEtcDispatchInternal "%Input_SuiteId%" "%Input_ProjectId%" "%Input_ModuleId%" "%Input_ActionId%" %Input_Tail%
        IF ERRORLEVEL 1 GOTO Failure
        GOTO Destructor
    )

    IF DEFINED Input_OrgId (
        CALL FnEtcForEachSuite "%Input_OrgId%" FnEtcDispatchInternal "%Input_ProjectId%" "%Input_ModuleId%" "%Input_ActionId%" %Input_Tail%
        IF ERRORLEVEL 1 GOTO Failure
        GOTO Destructor
    )

    CALL FnEtcForEachOrganization FnEtcForEachSuite FnEtcDispatchInternal "%Input_ProjectId%" "%Input_ModuleId%" "%Input_ActionId%" %Input_Tail%
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Destructor

:External
    CALL FnEtcDispatchExternal "%Input_EntryId%" "%Input_ValueId%" %Input_Command%
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Destructor

:Constructor
    SET "Input_EntryId=%~1"
    SET "Input_ValueId="
    SET "Input_Command="
    SET "Input_OrgId="
    SET "Input_SuiteId="
    SET "Input_ProjectId="
    SET "Input_ModuleId="
    SET "Input_ActionId="
    SET "Input_ModuleIndex="
    SET "Input_PrefixLength=0"
    SET "Input_Tail="
    SET "Input_Error="
    SET "Input_ReturnCode=0"

    IF NOT DEFINED Input_EntryId (
        SET "Input_Error=Missing required argument <EntryId>"
        GOTO Failure
    )

    :: Global names nothing, so its command starts one token earlier.
    SHIFT
    IF /I NOT "%Input_EntryId%"=="Global" (
        SET "Input_ValueId=%~1"
        SHIFT
    )
    GOTO Collect

:Collect
    IF [%1]==[] GOTO Collected
    SET "Input_Command=%Input_Command% %1"
    SHIFT
    GOTO Collect

:Collected
    IF DEFINED Input_Command SET "Input_Command=%Input_Command:~1%"
    GOTO Validate

:Validate
    IF NOT DEFINED Input_Command (
        SET "Input_Error=Missing required argument <Command>"
        GOTO Failure
    )

    CALL FnEtcFlags %Input_Command%
    IF ERRORLEVEL 1 GOTO Failure

    :: Snapshot at once. Every reader below calls FnEtcFlags for its own --refresh
    :: flag, and the readers deliberately do not SETLOCAL, so a nested parse would
    :: otherwise clear GLOBAL_Flag* out from under this scope mid-scan.
    SET "Input_Argc=%GLOBAL_FlagArgc%"
    SET "Input_Args=%GLOBAL_FlagArgs%"
    SET "Input_Projects=%GLOBAL_FlagProjects%"
    SET "Input_Passthru=%GLOBAL_FlagPassthru%"
    SET "Local_Index=1"
    GOTO Snapshot

:Snapshot
    IF %Local_Index% GTR %Input_Argc% GOTO SnapshotDone
    CALL SET "Local_Token=%%GLOBAL_FlagArg%Local_Index%%%"
    SET "Input_Arg%Local_Index%=%Local_Token%"
    SET /A Local_Index+=1
    GOTO Snapshot

:SnapshotDone
    IF "%Input_Argc%"=="0" (
        SET "Input_Error=Missing required argument <Module>"
        GOTO Failure
    )
    GOTO Main

:Failure
    SET "Input_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Input_Error CALL FnEtcLogError FnEtcDispatch "%Input_Error%"
    EXIT /B %Input_ReturnCode%
