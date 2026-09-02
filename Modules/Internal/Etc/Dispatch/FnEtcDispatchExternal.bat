:: FnEtcDispatchExternal <EntryId> <ValueId> <Command...>
:: leprechaun function dispatch-external <EntryId> <ValueId> <Command...>
:: -- Reached when no positional named a module. External projects are separate
:: -- modules with their own commands, so the grammar is shorter than the
:: -- internal one: there is no ACTION, only a COMMAND the project defines.
:: --
:: --   entry        | positionals | meaning
:: --   Global       | 4           | ORG SUITE PROJECT COMMAND
:: --   Global       | 2           | ORG COMMAND              (all suites)
:: --   Organization | 3           | SUITE PROJECT COMMAND
:: --   Organization | 1           | COMMAND                  (all suites)
:: --   Suite        | 2           | PROJECT COMMAND
:: --
:: -- With no PROJECT the command goes to every external project in the suite.

@ECHO OFF
SETLOCAL EnableExtensions
GOTO Constructor

:Main
    IF /I "%Function_EntryId%"=="Global"       GOTO ShapeGlobal
    IF /I "%Function_EntryId%"=="Organization" GOTO ShapeOrganization
    IF /I "%Function_EntryId%"=="Suite"        GOTO ShapeSuite
    SET "Function_Error=Unknown entry point %Function_EntryId%"
    GOTO Failure

:ShapeGlobal
    IF "%Function_Argc%"=="4" (
        SET "Function_OrgId=%Function_Arg1%"
        SET "Function_SuiteId=%Function_Arg2%"
        SET "Function_ProjectId=%Function_Arg3%"
        SET "Function_CommandId=%Function_Arg4%"
        GOTO Shaped
    )
    IF "%Function_Argc%"=="2" (
        SET "Function_OrgId=%Function_Arg1%"
        SET "Function_CommandId=%Function_Arg2%"
        GOTO Shaped
    )
    GOTO BadShape

:ShapeOrganization
    SET "Function_OrgId=%Function_ValueId%"
    IF "%Function_Argc%"=="3" (
        SET "Function_SuiteId=%Function_Arg1%"
        SET "Function_ProjectId=%Function_Arg2%"
        SET "Function_CommandId=%Function_Arg3%"
        GOTO Shaped
    )
    IF "%Function_Argc%"=="1" (
        SET "Function_CommandId=%Function_Arg1%"
        GOTO Shaped
    )
    GOTO BadShape

:ShapeSuite
    SET "Function_SuiteId=%Function_ValueId%"
    IF "%Function_Argc%"=="2" (
        SET "Function_ProjectId=%Function_Arg1%"
        SET "Function_CommandId=%Function_Arg2%"
        GOTO Shaped
    )
    GOTO BadShape

:Shaped
    IF NOT DEFINED Function_CommandId GOTO BadShape

    IF DEFINED Function_SuiteId (
        CALL :OneSuite "%Function_SuiteId%"
        GOTO Destructor
    )

    IF NOT DEFINED Function_OrgId GOTO BadShape

    :: Fanned out here rather than through FnEtcForEachSuite, because the work
    :: per suite is a subroutine in this file and cannot be reached by name. The
    :: FOR list is expanded when the line is parsed, so the reads inside the body
    :: cannot disturb the set being iterated.
    CALL FnEtcDataSuites "%Function_OrgId%"
    IF ERRORLEVEL 1 GOTO Failure

    IF NOT DEFINED GLOBAL_DataSuitesActive (
        SET "Function_Error=No active suites in organization %Function_OrgId%"
        GOTO Failure
    )

    FOR %%S IN (%GLOBAL_DataSuitesActive%) DO (
        CALL :OneSuite "%%S"
        IF ERRORLEVEL 1 SET "Function_ReturnCode=1"
    )
    GOTO Destructor

:BadShape
    SET "Function_Error=Not a valid command for a %Function_EntryId% entry point"
    GOTO Failure

:Constructor
    SET "Function_EntryId=%~1"
    SET "Function_ValueId=%~2"
    SET "Function_Command="
    SET "Function_OrgId="
    SET "Function_SuiteId="
    SET "Function_ProjectId="
    SET "Function_CommandId="
    SET "Function_Tail="
    SET "Function_Error="
    SET "Function_ReturnCode=0"

    SHIFT
    SHIFT
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
    IF NOT DEFINED Function_EntryId (
        SET "Function_Error=Missing required argument <EntryId>"
        GOTO Failure
    )

    CALL FnEtcFlags %Function_Command%
    IF ERRORLEVEL 1 GOTO Failure

    :: Snapshotted at once, for the same reason as FnEtcDispatch: the readers
    :: below parse flags of their own and do not SETLOCAL.
    SET "Function_Argc=%GLOBAL_FlagArgc%"
    SET "Function_Arg1=%GLOBAL_FlagArg1%"
    SET "Function_Arg2=%GLOBAL_FlagArg2%"
    SET "Function_Arg3=%GLOBAL_FlagArg3%"
    SET "Function_Arg4=%GLOBAL_FlagArg4%"
    IF DEFINED GLOBAL_FlagArgs SET "Function_Tail=%Function_Tail% %GLOBAL_FlagArgs%"
    IF DEFINED GLOBAL_FlagPassthru SET "Function_Tail=%Function_Tail% %GLOBAL_FlagPassthru%"
    SET "Function_DryRun=%GLOBAL_FlagDryRun%"
    IF DEFINED Function_Tail SET "Function_Tail=%Function_Tail:~1%"
    GOTO Main

:OneSuite
    CALL FnEtcDataProjects "%~1"
    IF ERRORLEVEL 1 EXIT /B 1

    IF NOT DEFINED Function_ProjectId GOTO AllExternal
    CALL :OneProject "%~1" "%Function_ProjectId%"
    EXIT /B %ERRORLEVEL%

:AllExternal
    IF NOT DEFINED GLOBAL_DataProjectsExternal EXIT /B 0
    FOR %%P IN (%GLOBAL_DataProjectsExternal%) DO (
        CALL :OneProject "%~1" "%%P"
        IF ERRORLEVEL 1 SET "Function_ReturnCode=1"
    )
    EXIT /B 0

:OneProject
    CALL FnEtcResolveProject "%~1" "%~2"
    IF ERRORLEVEL 1 EXIT /B 1

    IF /I NOT "%GLOBAL_ResolvedProjectIsExternal%"=="true" (
        CALL FnEtcLogError FnEtcDispatchExternal "Project %~2 is not external, so it has no commands of its own"
        ECHO   External projects: %GLOBAL_DataProjectsExternal%
        SET "Function_ReturnCode=1"
        EXIT /B 1
    )

    :: An external project declares its own dispatcher. Report a missing one the
    :: same way a missing leaf is reported, so the grammar stays testable ahead
    :: of those scripts being written.
    WHERE Fn%~2Dispatch >NUL 2>&1
    IF ERRORLEVEL 1 (
        CALL FnEtcLogRun FnEtcDispatchExternal "fn=Fn%~2Dispatch suite=%~1 project=%~2 command=%Function_CommandId% flags=%Function_Tail%"
        IF DEFINED Function_DryRun EXIT /B 0
        CALL FnEtcLogError FnEtcDispatchExternal "Not implemented yet: Fn%~2Dispatch"
        SET "Function_ReturnCode=1"
        EXIT /B 1
    )

    CALL Fn%~2Dispatch "%~1" "%Function_CommandId%" %Function_Tail%
    IF ERRORLEVEL 1 SET "Function_ReturnCode=1"
    EXIT /B 0

:Failure
    SET "Function_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Function_Error CALL FnEtcLogError FnEtcDispatchExternal "%Function_Error%"
    IF DEFINED Function_Error (
        ECHO   Internal: ^<MODULE^> ^<ACTION^> ^<ARGS...^> ^<FLAGS...^>
        ECHO   External: ^<PROJECT^> ^<COMMAND^>
    )
    EXIT /B %Function_ReturnCode%
