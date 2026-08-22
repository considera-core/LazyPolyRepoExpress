:: FnEtcDispatch <EntryId> <ValueId> <Command>
:: FnEtcDispatch <EntryId> <Command> if <EntryId> is global
:: -- Front door for every entry script. Applies the Docs.md grammar:
:: -- EntryId:
:: ---  Global | Organization | Suite | Project
:: -- Lookup table:
:: --   +--------+---------------------+---------------+--------------+-----------------+
:: --   | prefix | Global              | Organization  | Suite        | Project         |
:: --   +--------+---------------------+---------------+--------------+-----------------+
:: --   | 0      | all organizations   | all suites    | all projects | all subprojects |
:: --   | 1      | ORG                 | SUITE         | PROJECT      | SUBPROJECT      |
:: --   | 2      | ORG SUITE           | SUITE PROJECT | (error)      | (error)         |
:: --   | 3      | ORG SUITE PROJECT   | (error)       | (error)      | (error)         |
:: --   +--------+---------------------+---------------+--------------+-----------------+

@ECHO OFF
SETLOCAL EnableExtensions

SET "Function_EntryId=%~1"
SET "Function_ValueId=%~2"
SET "Function_Command=%~3"

IF NOT DEFINED Function_EntryId (
    CALL leprechaun function log error FnEtcDispatch "Missing required argument ^<EntryId^>"
    EXIT /B 1
)

IF NOT DEFINED Function_ValueId (
    CALL leprechaun function log error FnEtcDispatch "Missing required argument ^<ValueId ^| Command^>"
    EXIT /B 1
)

IF DEFINED Function_Command (
    :: Organization | Suite | Project
    IF /I "%Function_EntryId%"=="Organization" (
        CALL leprechaun function for Suites FnEtcDispatch "%Function_ValueId%" "%Function_Command%"
        GOTO Destructor 0
    )

    IF /I "%Function_EntryId%"=="Suite" (
        CALL leprechaun function for Projects FnEtcDispatch "%Function_ValueId%" "%Function_Command%"
        GOTO Destructor 0
    )

    IF /I "%Function_EntryId%"=="Project" (
        CALL leprechaun function resolve Project "%Function_ValueId%"

        IF NOT DEFINED GLOBAL_ResolvedProjectId (
            CALL leprechaun function log error FnEtcDispatch "Failed to resolve project %Function_ValueId%"
            GOTO Destructor 1
        )

        IF /I "%GLOBAL_ResolvedProjectIsExternal%"=="True" (
            CALL leprechaun function log info FnEtcDispatch "Project %Function_ValueId% is external; using external dispatch"
            CALL leprechaun function dispatch-external "%Function_EntryId%" "%Function_ValueId%" "%Function_Command%"
            GOTO Destructor 0
        )
        CALL leprechaun function dispatch-internal "%Function_EntryId%" "%Function_ValueId%" "%Function_Command%"
        GOTO Destructor 0
    )
    GOTO Destructor 0
)

:: Global
IF /I "%Function_EntryId%"=="Global" (
    SET "Function_Command=%Function_ValueId%"
    SET "Function_ValueId="
    CALL leprechaun function for Organizations FnEtcDispatch "%Function_Command%"
    GOTO Destructor 0
)

GOTO Destructor 0

:HandleValidate
    CALL leprechaun function
    GOTO HandleValidateReturn

:HandleExecute
    GOTO Destructor 0

:Destructor
    SET "Function_EntryId="
    SET "Function_ValueId="
    SET "Function_Command="
    EXIT /B %~1
