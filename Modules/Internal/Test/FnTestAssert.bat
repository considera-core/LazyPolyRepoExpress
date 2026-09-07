:: FnTestAssert <CHECK>
:: -- Data invariants the command grammar depends on. Each check exits 0 when the
:: -- invariant holds and 1 with an explanation when it does not, so schema.cases
:: -- can assert on them like any other command.
:: --
:: -- Checks:
:: --   suite-ids-unique          no SuiteCommandIdentifier appears in two organizations
:: --   org-dirs                  every OrganizationFriendlyIdentifier has a directory
:: --   suite-dirs                every SuiteFriendlyIdentifier has a directory
:: --   active-suites-scaffolded  every active suite has a Projects.csv
:: --   module-definitions        every module in Modules.Definitions.csv is in Modules.csv
:: --   app-definitions           every project in Apps.Definitions.csv is in Projects.csv
:: --   action-collisions         no project identifier collides with a module action

@ECHO OFF
SETLOCAL EnableExtensions

SET "A_CHECK=%~1"
IF NOT DEFINED A_CHECK GOTO :MISSING_CHECK

CALL FnEtcEnvGetDataPath
IF ERRORLEVEL 1 EXIT /B 1

SET "A_FAIL=0"

IF /I "%A_CHECK%"=="suite-ids-unique" GOTO :SUITE_IDS_UNIQUE
IF /I "%A_CHECK%"=="org-dirs" GOTO :ORG_DIRS
IF /I "%A_CHECK%"=="suite-dirs" GOTO :SUITE_DIRS
IF /I "%A_CHECK%"=="active-suites-scaffolded" GOTO :ACTIVE_SUITES
IF /I "%A_CHECK%"=="module-definitions" GOTO :MODULE_DEFINITIONS
IF /I "%A_CHECK%"=="app-definitions" GOTO :APP_DEFINITIONS
IF /I "%A_CHECK%"=="action-collisions" GOTO :ACTION_COLLISIONS
ECHO LeprechaunCLI:FnTestAssert[E]: Unknown check "%A_CHECK%"
EXIT /B 1

:SUITE_IDS_UNIQUE
    :: The Fn schema takes SUITE without an ORG, which is only sound while suite
    :: command identifiers are globally unique.
    CALL FnEtcCsvOrgs
    IF ERRORLEVEL 1 EXIT /B 1
    SET "A_SEEN="
    FOR %%O IN (%Output_Data_Orgs%) DO CALL :COLLECT_SUITES "%%O"
    GOTO :REPORT

:COLLECT_SUITES
    CALL FnEtcCsvSuites "%~1" >NUL 2>&1
    IF ERRORLEVEL 1 EXIT /B 0
    SET "A_LIST=%LPRE_SUITES%"
    IF NOT DEFINED A_LIST EXIT /B 0
    FOR %%S IN (%A_LIST%) DO CALL :SEEN_SUITE "%%S" "%~1"
    EXIT /B 0

:SEEN_SUITE
    CALL :IS_LISTED "%~1" "%A_SEEN%"
    IF NOT ERRORLEVEL 1 CALL :FAIL "suite id ""%~1"" is declared in more than one organization (again in %~2)"
    SET "A_SEEN=%A_SEEN% %~1"
    EXIT /B 0

:ORG_DIRS
    CALL FnEtcCsvOrgs
    IF ERRORLEVEL 1 EXIT /B 1
    FOR %%O IN (%Output_Data_Orgs%) DO CALL :CHECK_ORG_DIR "%%O"
    GOTO :REPORT

:CHECK_ORG_DIR
    CALL SET "A_DIR=%%GLOBAL_ORG_%~1_DIR%%"
    IF NOT EXIST "%Output_Env_DataPath%\Organizations\%A_DIR%" CALL :FAIL "organization ""%~1"" declares friendly identifier ""%A_DIR%"" but no such directory exists"
    EXIT /B 0

:SUITE_DIRS
    CALL FnEtcCsvOrgs
    IF ERRORLEVEL 1 EXIT /B 1
    SET "A_MODE=dir"
    FOR %%O IN (%Output_Data_Orgs%) DO CALL :WALK_SUITES "%%O"
    GOTO :REPORT

:ACTIVE_SUITES
    :: A suite may be declared before it is scaffolded, but only while inactive.
    CALL FnEtcCsvOrgs
    IF ERRORLEVEL 1 EXIT /B 1
    SET "A_MODE=scaffold"
    FOR %%O IN (%Output_Data_Orgs%) DO CALL :WALK_SUITES "%%O"
    GOTO :REPORT

:WALK_SUITES
    CALL SET "A_ORG_DIR=%%GLOBAL_ORG_%~1_DIR%%"
    CALL FnEtcCsvSuites "%~1" >NUL 2>&1
    IF ERRORLEVEL 1 EXIT /B 0
    SET "A_LIST=%LPRE_SUITES%"
    IF /I "%A_MODE%"=="scaffold" SET "A_LIST=%LPRE_SUITES_ACTIVE%"
    IF NOT DEFINED A_LIST EXIT /B 0
    FOR %%S IN (%A_LIST%) DO CALL :CHECK_SUITE "%%S"
    EXIT /B 0

:CHECK_SUITE
    CALL SET "A_DIR=%%GLOBAL_SUITE_%~1_DIR%%"
    SET "A_PATH=%Output_Env_DataPath%\Organizations\%A_ORG_DIR%\Suites\%A_DIR%"
    IF /I "%A_MODE%"=="scaffold" GOTO :CHECK_SUITE_SCAFFOLD
    IF NOT EXIST "%A_PATH%" CALL :FAIL "suite ""%~1"" declares friendly identifier ""%A_DIR%"" but no such directory exists"
    EXIT /B 0

:CHECK_SUITE_SCAFFOLD
    IF NOT EXIST "%A_PATH%\Projects.csv" CALL :FAIL "active suite ""%~1"" has no Projects.csv"
    EXIT /B 0

:MODULE_DEFINITIONS
    CALL FnEtcCsvModules
    IF ERRORLEVEL 1 EXIT /B 1
    SET "A_MODULES=%LPRE_MODULES%"
    FOR /R "%Output_Env_DataPath%\Organizations" %%F IN (Modules.Definitions.csv) DO IF EXIST "%%F" CALL :CHECK_MODULE_DEFS "%%F"
    GOTO :REPORT

:CHECK_MODULE_DEFS
    FOR /F "usebackq skip=1 tokens=1,2 delims=, eol=#" %%A IN ("%~1") DO CALL :CHECK_MODULE_DEF "%%A" "%%B"
    EXIT /B 0

:CHECK_MODULE_DEF
    CALL :IS_LISTED "%~2" "%A_MODULES%"
    IF ERRORLEVEL 1 CALL :FAIL "project ""%~1"" enables module ""%~2"" which is not in Modules.csv"
    EXIT /B 0

:APP_DEFINITIONS
    FOR /R "%Output_Env_DataPath%\Organizations" %%F IN (Apps.Definitions.csv) DO IF EXIST "%%F" CALL :CHECK_APP_DEFS "%%F"
    GOTO :REPORT

:CHECK_APP_DEFS
    SET "A_PROJECTS_CSV=%~dp1Projects.csv"
    IF NOT EXIST "%A_PROJECTS_CSV%" EXIT /B 0
    SET "A_KNOWN="
    FOR /F "usebackq skip=1 tokens=1 delims=, eol=#" %%A IN ("%A_PROJECTS_CSV%") DO CALL :ADD_KNOWN "%%A"
    FOR /F "usebackq skip=1 tokens=1,2 delims=, eol=#" %%A IN ("%~1") DO CALL :CHECK_APP_DEF "%%A" "%%B"
    EXIT /B 0

:ADD_KNOWN
    SET "A_KNOWN=%A_KNOWN% %~1"
    EXIT /B 0

:CHECK_APP_DEF
    CALL :IS_LISTED "%~2" "%A_KNOWN%"
    IF ERRORLEVEL 1 CALL :FAIL "app ""%~1"" references project ""%~2"" which is not in Projects.csv"
    EXIT /B 0

:ACTION_COLLISIONS
    :: A leaf Fn reads positional 2 as PROJECT when it names a project in the
    :: suite, so a project must never share a name with one of its module actions.
    CALL FnEtcCsvOrgs
    IF ERRORLEVEL 1 EXIT /B 1
    SET "A_ACTIONS=run launch validate list claude login whoami env migrate seed reset branch branches pull home story code jetbrains rider webstorm install build test restore pack push init plan apply open tree path"
    FOR %%O IN (%Output_Data_Orgs%) DO CALL :WALK_ORG_COLLISIONS "%%O"
    GOTO :REPORT

:WALK_ORG_COLLISIONS
    CALL FnEtcCsvSuites "%~1" >NUL 2>&1
    IF ERRORLEVEL 1 EXIT /B 0
    SET "A_LIST=%LPRE_SUITES%"
    IF NOT DEFINED A_LIST EXIT /B 0
    FOR %%S IN (%A_LIST%) DO CALL :WALK_SUITE_COLLISIONS "%~1" "%%S"
    EXIT /B 0

:WALK_SUITE_COLLISIONS
    CALL FnEtcCsvProjects "%~1" "%~2" >NUL 2>&1
    IF ERRORLEVEL 1 EXIT /B 0
    SET "A_PLIST=%GLOBAL_PROJECTS%"
    IF NOT DEFINED A_PLIST EXIT /B 0
    FOR %%P IN (%A_PLIST%) DO CALL :CHECK_COLLISION "%%P" "%~2"
    EXIT /B 0

:CHECK_COLLISION
    CALL :IS_LISTED "%~1" "%A_ACTIONS%"
    IF NOT ERRORLEVEL 1 CALL :FAIL "project ""%~1"" in suite ""%~2"" collides with a module action name"
    EXIT /B 0

:FAIL
    ECHO LeprechaunCLI:FnTestAssert[E]: %~1
    SET "A_FAIL=1"
    EXIT /B 0

:IS_LISTED
    IF "%~1"=="" EXIT /B 1
    FOR %%K IN (%~2) DO IF /I "%%K"=="%~1" EXIT /B 0
    EXIT /B 1

:REPORT
    IF "%A_FAIL%"=="1" EXIT /B 1
    ECHO LeprechaunCLI:FnTestAssert[I]: %A_CHECK% ok
    EXIT /B 0

:MISSING_CHECK
    ECHO LeprechaunCLI:FnTestAssert[E]: Missing required argument ^<CHECK^>
    EXIT /B 1
