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
    IF %Local_Index% GTR %Function_Argc% GOTO ScanDone
    CALL SET "Local_Token=%%Function_Arg%Local_Index%%%"
    FOR %%M IN (%GLOBAL_DataMods%) DO IF /I "%%M"=="%Local_Token%" SET "Function_ModuleIndex=%Local_Index%"
    IF DEFINED Function_ModuleIndex GOTO ScanDone
    SET /A Local_Index+=1
    GOTO ScanModule

:ScanDone
    :: No module anywhere in the positionals: this is an External invocation.
    IF NOT DEFINED Function_ModuleIndex GOTO External

    CALL SET "Function_ModuleId=%%Function_Arg%Function_ModuleIndex%%%"
    SET /A Local_Index=Function_ModuleIndex+1
    IF %Local_Index% GTR %Function_Argc% (
        SET "Function_Error=Module %Function_ModuleId% needs an action"
        GOTO Failure
    )
    CALL SET "Function_ActionId=%%Function_Arg%Local_Index%%%"

    SET /A Function_PrefixLength=Function_ModuleIndex-1
    GOTO Prefix

:Prefix
    IF /I "%Function_EntryId%"=="Global"       GOTO PrefixGlobal
    IF /I "%Function_EntryId%"=="Organization" GOTO PrefixOrganization
    IF /I "%Function_EntryId%"=="Suite"        GOTO PrefixSuite
    IF /I "%Function_EntryId%"=="Project"      GOTO PrefixProject
    SET "Function_Error=Unknown entry point %Function_EntryId%. Expected Global, Organization, Suite or Project"
    GOTO Failure

:PrefixGlobal
    IF %Function_PrefixLength% GTR 3 GOTO PrefixTooLong
    IF %Function_PrefixLength% GEQ 1 SET "Function_OrgId=%Function_Arg1%"
    IF %Function_PrefixLength% GEQ 2 SET "Function_SuiteId=%Function_Arg2%"
    IF %Function_PrefixLength% GEQ 3 SET "Function_ProjectId=%Function_Arg3%"
    GOTO Resolve

:PrefixOrganization
    IF %Function_PrefixLength% GTR 2 GOTO PrefixTooLong
    SET "Function_OrgId=%Function_ValueId%"
    IF %Function_PrefixLength% GEQ 1 SET "Function_SuiteId=%Function_Arg1%"
    IF %Function_PrefixLength% GEQ 2 SET "Function_ProjectId=%Function_Arg2%"
    GOTO Resolve

:PrefixSuite
    IF %Function_PrefixLength% GTR 1 GOTO PrefixTooLong
    SET "Function_SuiteId=%Function_ValueId%"
    IF %Function_PrefixLength% GEQ 1 SET "Function_ProjectId=%Function_Arg1%"
    GOTO Resolve

:PrefixProject
    SET "Function_Error=Project is not a supported entry depth: subprojects are not modelled in the data"
    GOTO Failure

:PrefixTooLong
    SET "Function_Error=Too many names before %Function_ModuleId% for a %Function_EntryId% entry point"
    GOTO Failure

:Resolve
    :: A name given explicitly must exist, and is rejected here rather than
    :: guessed at further down.
    IF DEFINED Function_OrgId (
        CALL FnEtcResolveOrganization "%Function_OrgId%"
        IF ERRORLEVEL 1 GOTO Failure
    )

    IF DEFINED Function_SuiteId (
        CALL FnEtcResolveSuite "%Function_SuiteId%"
        IF ERRORLEVEL 1 GOTO Failure
    )
    GOTO Tail

:Tail
    :: Everything after ACTION is an ARG. An -a list is appended to them, and -p
    :: rides along so the leaf can fan out over the projects it names.
    SET /A Local_Index=Function_ModuleIndex+2
    GOTO TailCollect

:TailCollect
    IF %Local_Index% GTR %Function_Argc% GOTO TailDone
    CALL SET "Local_Token=%%Function_Arg%Local_Index%%%"
    SET "Function_Tail=%Function_Tail% "%Local_Token%""
    SET /A Local_Index+=1
    GOTO TailCollect

:TailDone
    IF DEFINED Function_Args SET "Function_Tail=%Function_Tail% --args %Function_Args%"
    IF DEFINED Function_Projects SET "Function_Tail=%Function_Tail% -p %Function_Projects%"
    IF DEFINED Function_Passthru SET "Function_Tail=%Function_Tail% %Function_Passthru%"
    IF DEFINED Function_Tail SET "Function_Tail=%Function_Tail:~1%"
    GOTO Fanout

:Fanout
    :: One suite at a time, always. The iterators supply the missing name and
    :: leave the argument order untouched, because FnEtcDispatchInternal takes
    :: SuiteId first and FnEtcForEachSuite supplies exactly that.
    IF DEFINED Function_SuiteId (
        CALL FnEtcDispatchInternal "%Function_SuiteId%" "%Function_ProjectId%" "%Function_ModuleId%" "%Function_ActionId%" %Function_Tail%
        IF ERRORLEVEL 1 GOTO Failure
        GOTO Destructor
    )

    IF DEFINED Function_OrgId (
        CALL FnEtcForEachSuite "%Function_OrgId%" FnEtcDispatchInternal "%Function_ProjectId%" "%Function_ModuleId%" "%Function_ActionId%" %Function_Tail%
        IF ERRORLEVEL 1 GOTO Failure
        GOTO Destructor
    )

    CALL FnEtcForEachOrganization FnEtcForEachSuite FnEtcDispatchInternal "%Function_ProjectId%" "%Function_ModuleId%" "%Function_ActionId%" %Function_Tail%
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Destructor

:External
    CALL FnEtcDispatchExternal "%Function_EntryId%" "%Function_ValueId%" %Function_Command%
    IF ERRORLEVEL 1 GOTO Failure
    GOTO Destructor

:Constructor
    SET "Function_EntryId=%~1"
    SET "Function_ValueId="
    SET "Function_Command="
    SET "Function_OrgId="
    SET "Function_SuiteId="
    SET "Function_ProjectId="
    SET "Function_ModuleId="
    SET "Function_ActionId="
    SET "Function_ModuleIndex="
    SET "Function_PrefixLength=0"
    SET "Function_Tail="
    SET "Function_Error="
    SET "Function_ReturnCode=0"

    IF NOT DEFINED Function_EntryId (
        SET "Function_Error=Missing required argument <EntryId>"
        GOTO Failure
    )

    :: Global names nothing, so its command starts one token earlier.
    SHIFT
    IF /I NOT "%Function_EntryId%"=="Global" (
        SET "Function_ValueId=%~1"
        SHIFT
    )
    GOTO Collect

:Collect
    IF [%1]==[] GOTO Collected
    SET "Function_Command=%Function_Command% %1"
    SHIFT
    GOTO Collect

:Collected
    IF DEFINED Function_Command SET "Function_Command=%Function_Command:~1%"
    GOTO Validate

:Validate
    IF NOT DEFINED Function_Command (
        SET "Function_Error=Missing required argument <Command>"
        GOTO Failure
    )

    CALL FnEtcFlags %Function_Command%
    IF ERRORLEVEL 1 GOTO Failure

    :: Snapshot at once. Every reader below calls FnEtcFlags for its own --refresh
    :: flag, and the readers deliberately do not SETLOCAL, so a nested parse would
    :: otherwise clear GLOBAL_Flag* out from under this scope mid-scan.
    SET "Function_Argc=%GLOBAL_FlagArgc%"
    SET "Function_Args=%GLOBAL_FlagArgs%"
    SET "Function_Projects=%GLOBAL_FlagProjects%"
    SET "Function_Passthru=%GLOBAL_FlagPassthru%"
    SET "Local_Index=1"
    GOTO Snapshot

:Snapshot
    IF %Local_Index% GTR %Function_Argc% GOTO SnapshotDone
    CALL SET "Local_Token=%%GLOBAL_FlagArg%Local_Index%%%"
    SET "Function_Arg%Local_Index%=%Local_Token%"
    SET /A Local_Index+=1
    GOTO Snapshot

:SnapshotDone
    IF "%Function_Argc%"=="0" (
        SET "Function_Error=Missing required argument <Module>"
        GOTO Failure
    )
    GOTO Main

:Failure
    SET "Function_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Function_Error CALL FnEtcLogError FnEtcDispatch "%Function_Error%"
    EXIT /B %Function_ReturnCode%
