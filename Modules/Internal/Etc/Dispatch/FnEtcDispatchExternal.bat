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
    IF /I "%Input_EntryId%"=="Global"       GOTO ShapeGlobal
    IF /I "%Input_EntryId%"=="Organization" GOTO ShapeOrganization
    IF /I "%Input_EntryId%"=="Suite"        GOTO ShapeSuite
    SET "Input_Error=Unknown entry point %Input_EntryId%"
    GOTO Failure

:ShapeGlobal
    IF "%Input_Argc%"=="4" (
        SET "Input_OrgId=%Input_Arg1%"
        SET "Input_SuiteId=%Input_Arg2%"
        SET "Input_ProjectId=%Input_Arg3%"
        SET "Input_CommandId=%Input_Arg4%"
        GOTO Shaped
    )
    IF "%Input_Argc%"=="2" (
        SET "Input_OrgId=%Input_Arg1%"
        SET "Input_CommandId=%Input_Arg2%"
        GOTO Shaped
    )
    GOTO BadShape

:ShapeOrganization
    SET "Input_OrgId=%Input_ValueId%"
    IF "%Input_Argc%"=="3" (
        SET "Input_SuiteId=%Input_Arg1%"
        SET "Input_ProjectId=%Input_Arg2%"
        SET "Input_CommandId=%Input_Arg3%"
        GOTO Shaped
    )
    IF "%Input_Argc%"=="1" (
        SET "Input_CommandId=%Input_Arg1%"
        GOTO Shaped
    )
    GOTO BadShape

:ShapeSuite
    SET "Input_SuiteId=%Input_ValueId%"
    IF "%Input_Argc%"=="2" (
        SET "Input_ProjectId=%Input_Arg1%"
        SET "Input_CommandId=%Input_Arg2%"
        GOTO Shaped
    )
    GOTO BadShape

:Shaped
    IF NOT DEFINED Input_CommandId GOTO BadShape

    IF DEFINED Input_SuiteId (
        CALL :OneSuite "%Input_SuiteId%"
        GOTO Destructor
    )

    IF NOT DEFINED Input_OrgId GOTO BadShape

    :: Fanned out here rather than through FnEtcForEachSuite, because the work
    :: per suite is a subroutine in this file and cannot be reached by name. The
    :: FOR list is expanded when the line is parsed, so the reads inside the body
    :: cannot disturb the set being iterated.
    CALL FnEtcDataSuites "%Input_OrgId%"
    IF ERRORLEVEL 1 GOTO Failure

    IF NOT DEFINED Output_Data_SuitesActive (
        SET "Input_Error=No active suites in organization %Input_OrgId%"
        GOTO Failure
    )

    FOR %%S IN (%Output_Data_SuitesActive%) DO (
        CALL :OneSuite "%%S"
        IF ERRORLEVEL 1 SET "Input_ReturnCode=1"
    )
    GOTO Destructor

:BadShape
    SET "Input_Error=Not a valid command for a %Input_EntryId% entry point"
    GOTO Failure

:Constructor
    SET "Input_EntryId=%~1"
    SET "Input_ValueId=%~2"
    SET "Input_Command="
    SET "Input_OrgId="
    SET "Input_SuiteId="
    SET "Input_ProjectId="
    SET "Input_CommandId="
    SET "Input_Tail="
    SET "Input_Error="
    SET "Input_ReturnCode=0"

    SHIFT
    SHIFT
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
    IF NOT DEFINED Input_EntryId (
        SET "Input_Error=Missing required argument <EntryId>"
        GOTO Failure
    )

    CALL FnEtcFlags %Input_Command%
    IF ERRORLEVEL 1 GOTO Failure

    :: Snapshotted at once, for the same reason as FnEtcDispatch: the readers
    :: below parse flags of their own and do not SETLOCAL.
    SET "Input_Argc=%GLOBAL_FlagArgc%"
    SET "Input_Arg1=%GLOBAL_FlagArg1%"
    SET "Input_Arg2=%GLOBAL_FlagArg2%"
    SET "Input_Arg3=%GLOBAL_FlagArg3%"
    SET "Input_Arg4=%GLOBAL_FlagArg4%"
    IF DEFINED GLOBAL_FlagArgs SET "Input_Tail=%Input_Tail% %GLOBAL_FlagArgs%"
    IF DEFINED GLOBAL_FlagPassthru SET "Input_Tail=%Input_Tail% %GLOBAL_FlagPassthru%"
    SET "Input_DryRun=%GLOBAL_FlagDryRun%"
    IF DEFINED Input_Tail SET "Input_Tail=%Input_Tail:~1%"
    GOTO Main

:OneSuite
    CALL FnEtcDataProjects "%~1"
    IF ERRORLEVEL 1 EXIT /B 1

    IF NOT DEFINED Input_ProjectId GOTO AllExternal
    CALL :OneProject "%~1" "%Input_ProjectId%"
    EXIT /B %ERRORLEVEL%

:AllExternal
    IF NOT DEFINED Output_Data_ProjectsExternal EXIT /B 0
    FOR %%P IN (%Output_Data_ProjectsExternal%) DO (
        CALL :OneProject "%~1" "%%P"
        IF ERRORLEVEL 1 SET "Input_ReturnCode=1"
    )
    EXIT /B 0

:OneProject
    CALL FnEtcResolveProject "%~1" "%~2"
    IF ERRORLEVEL 1 EXIT /B 1

    IF /I NOT "%Output_Resolved_ProjectIsExternal%"=="true" (
        CALL FnEtcLogError FnEtcDispatchExternal "Project %~2 is not external, so it has no commands of its own"
        ECHO   External projects: %Output_Data_ProjectsExternal%
        SET "Input_ReturnCode=1"
        EXIT /B 1
    )

    :: An external project declares its own dispatcher. Report a missing one the
    :: same way a missing leaf is reported, so the grammar stays testable ahead
    :: of those scripts being written.
    WHERE Fn%~2Dispatch >NUL 2>&1
    IF ERRORLEVEL 1 (
        CALL FnEtcLogRun FnEtcDispatchExternal "fn=Fn%~2Dispatch suite=%~1 project=%~2 command=%Input_CommandId% flags=%Input_Tail%"
        IF DEFINED Input_DryRun EXIT /B 0
        CALL FnEtcLogError FnEtcDispatchExternal "Not implemented yet: Fn%~2Dispatch"
        SET "Input_ReturnCode=1"
        EXIT /B 1
    )

    CALL Fn%~2Dispatch "%~1" "%Input_CommandId%" %Input_Tail%
    IF ERRORLEVEL 1 SET "Input_ReturnCode=1"
    EXIT /B 0

:Failure
    SET "Input_ReturnCode=1"
    GOTO Destructor

:Destructor
    IF DEFINED Input_Error CALL FnEtcLogError FnEtcDispatchExternal "%Input_Error%"
    IF DEFINED Input_Error (
        ECHO   Internal: ^<MODULE^> ^<ACTION^> ^<ARGS...^> ^<FLAGS...^>
        ECHO   External: ^<PROJECT^> ^<COMMAND^>
    )
    EXIT /B %Input_ReturnCode%
