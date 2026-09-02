:: FnEtcResolveOrganization <OrgId> <Flag[]>
:: leprechaun function resolve Organization <OrgId>
:: -- Resolves an organization from the data store, and exports:
:: --   GLOBAL_ResolvedOrgId            (OrganizationCommandIdentifier) command identifier
:: --   GLOBAL_ResolvedOrgIdentifier    (OrganizationFriendlyIdentifier) directory name
:: --   GLOBAL_ResolvedOrgName          (OrganizationFriendlyName) friendly name
:: --   GLOBAL_ResolvedOrgRootPath      (OrganizationRootPath) root path
:: --   GLOBAL_ResolvedOrgDataPath      (Computed) absolute path to this org's data directory
:: -- Flags:
:: --   --refresh: resolve again even when this organization is already in scope
:: --
:: -- NOTE: Locals are Export_ rather than Function_ on purpose. With no
:: --       SETLOCAL, a Function_ name here would be the CALLER's variable,
:: --       and clearing one on the way out would blank it under them.
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_ResolvedOrg values.
:: -- NOTE: The row is read in a CALLed subroutine rather than inline in the FOR
:: --       body. A FOR body is parsed once, so %Local_OrgIndex% inside it would
:: --       expand to its value before the first iteration and every row would
:: --       read as row 0. Each CALL is parsed afresh, so the index is live.

@ECHO OFF

SET "Export_OrgId=%~1"

IF NOT DEFINED Export_OrgId (
    CALL FnEtcLogError FnEtcResolveOrganization "Missing required argument <OrgId>"
    EXIT /B 1
)

CALL FnEtcFlags %*

IF /I "%GLOBAL_ResolvedOrgId%"=="%Export_OrgId%" IF NOT DEFINED GLOBAL_FlagRefresh (
    SET "Export_OrgId="
    EXIT /B 0
)

SET "GLOBAL_ResolvedOrgId="
SET "GLOBAL_ResolvedOrgIdentifier="
SET "GLOBAL_ResolvedOrgName="
SET "GLOBAL_ResolvedOrgRootPath="
SET "GLOBAL_ResolvedOrgDataPath="

CALL FnEtcEnvGetDataPath
IF ERRORLEVEL 1 EXIT /B 1

CALL FnEtcDataOrganizations
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_OrgIndex=0"
FOR %%O IN (%GLOBAL_DataOrgs%) DO CALL :Row "%%O"

IF NOT DEFINED GLOBAL_ResolvedOrgId (
    CALL FnEtcLogError FnEtcResolveOrganization "Unknown organization %Export_OrgId%"
    ECHO   Organizations: %GLOBAL_DataOrgs%
    SET "Export_OrgId="
    SET "Local_OrgIndex="
    EXIT /B 1
)

SET "Export_OrgId="
SET "Local_OrgIndex="
EXIT /B 0

:Row
    IF DEFINED GLOBAL_ResolvedOrgId EXIT /B 0
    IF /I NOT "%~1"=="%Export_OrgId%" GOTO RowNext

    CALL SET "GLOBAL_ResolvedOrgIdentifier=%%GLOBAL_DataOrg%Local_OrgIndex%Identifier%%"
    CALL SET "GLOBAL_ResolvedOrgName=%%GLOBAL_DataOrg%Local_OrgIndex%Name%%"
    CALL SET "GLOBAL_ResolvedOrgRootPath=%%GLOBAL_DataOrg%Local_OrgIndex%RootPath%%"
    SET "GLOBAL_ResolvedOrgId=%Export_OrgId%"
    SET "GLOBAL_ResolvedOrgDataPath=%GLOBAL_DataPath%\Organizations\%GLOBAL_ResolvedOrgIdentifier%"
    EXIT /B 0

:RowNext
    SET /A Local_OrgIndex+=1
    EXIT /B 0
