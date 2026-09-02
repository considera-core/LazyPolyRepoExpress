:: FnEtcResolveSuite <SuiteId> <Flag[]>
:: leprechaun function resolve Suite <SuiteId> <Flag[]>
:: -- Resolves a suite from the data store, and exports:
:: --   GLOBAL_ResolvedSuiteId              (SuiteCommandIdentifier) command identifier
:: --   GLOBAL_ResolvedSuiteIdentifier      (SuiteFriendlyIdentifier) directory name
:: --   GLOBAL_ResolvedSuiteName            (SuiteFriendlyName) friendly name
:: --   GLOBAL_ResolvedSuiteRootPath        (SuiteRootPath) absolute path to the suite root
:: --   GLOBAL_ResolvedSuiteActive          (SuiteIsActive) true or false
:: --   GLOBAL_ResolvedSuiteDataPath        (Computed) absolute path to this suite's data directory
:: --   GLOBAL_ResolvedSuiteOrgId           (FK) owning organization command identifier
:: -- Flags:
:: --   --refresh: resolve again even when this suite is already in scope
:: --
:: -- A suite is named without its organization, so finding one means scanning
:: -- each organization's Suites.csv in turn. The Docs.md schema group enforces
:: -- that suite identifiers are unique across organizations, which is what makes
:: -- the first match the only match.
:: --
:: -- NOTE: Locals are Export_ rather than Function_ on purpose. With no
:: --       SETLOCAL, a Function_ name here would be the CALLER's variable,
:: --       and clearing one on the way out would blank it under them.
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_ResolvedSuite values.

@ECHO OFF

SET "Export_SuiteId=%~1"

IF NOT DEFINED Export_SuiteId (
    CALL FnEtcLogError FnEtcResolveSuite "Missing required argument <SuiteId>"
    EXIT /B 1
)

CALL FnEtcFlags %*

IF /I "%GLOBAL_ResolvedSuiteId%"=="%Export_SuiteId%" IF NOT DEFINED GLOBAL_FlagRefresh (
    SET "Export_SuiteId="
    EXIT /B 0
)

SET "GLOBAL_ResolvedSuiteId="
SET "GLOBAL_ResolvedSuiteIdentifier="
SET "GLOBAL_ResolvedSuiteName="
SET "GLOBAL_ResolvedSuiteRootPath="
SET "GLOBAL_ResolvedSuiteActive="
SET "GLOBAL_ResolvedSuiteDataPath="
SET "GLOBAL_ResolvedSuiteOrgId="

CALL FnEtcEnvGetDataPath
IF ERRORLEVEL 1 EXIT /B 1

CALL FnEtcDataOrganizations
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_SuiteOrgs=%GLOBAL_DataOrgs%"
FOR %%O IN (%Local_SuiteOrgs%) DO CALL :Org "%%O"

IF NOT DEFINED GLOBAL_ResolvedSuiteId (
    CALL FnEtcLogError FnEtcResolveSuite "Unknown suite %Export_SuiteId%"
    SET "Export_SuiteId="
    SET "Local_SuiteOrgs="
    SET "Local_SuiteIndex="
    EXIT /B 1
)

SET "Export_SuiteId="
SET "Local_SuiteOrgs="
SET "Local_SuiteIndex="
EXIT /B 0

:Org
    IF DEFINED GLOBAL_ResolvedSuiteId EXIT /B 0

    :: Each org's read clobbers GLOBAL_DataSuite*, so the match has to be taken
    :: before moving on to the next organization.
    CALL FnEtcDataSuites "%~1"
    IF ERRORLEVEL 1 EXIT /B 0

    SET "Local_SuiteIndex=0"
    FOR %%S IN (%GLOBAL_DataSuites%) DO CALL :Row "%~1" "%%S"
    EXIT /B 0

:Row
    IF DEFINED GLOBAL_ResolvedSuiteId EXIT /B 0
    IF /I NOT "%~2"=="%Export_SuiteId%" GOTO RowNext

    CALL SET "GLOBAL_ResolvedSuiteIdentifier=%%GLOBAL_DataSuite%Local_SuiteIndex%Identifier%%"
    CALL SET "GLOBAL_ResolvedSuiteName=%%GLOBAL_DataSuite%Local_SuiteIndex%Name%%"
    CALL SET "GLOBAL_ResolvedSuiteRootPath=%%GLOBAL_DataSuite%Local_SuiteIndex%RootPath%%"
    CALL SET "GLOBAL_ResolvedSuiteActive=%%GLOBAL_DataSuite%Local_SuiteIndex%Active%%"
    SET "GLOBAL_ResolvedSuiteOrgId=%~1"
    SET "GLOBAL_ResolvedSuiteId=%Export_SuiteId%"

    :: FnEtcDataSuites resolved this organization on the way in, so the org
    :: directory name is already in scope.
    SET "GLOBAL_ResolvedSuiteDataPath=%GLOBAL_DataPath%\Organizations\%GLOBAL_ResolvedOrgIdentifier%\Suites\%GLOBAL_ResolvedSuiteIdentifier%"
    EXIT /B 0

:RowNext
    SET /A Local_SuiteIndex+=1
    EXIT /B 0
