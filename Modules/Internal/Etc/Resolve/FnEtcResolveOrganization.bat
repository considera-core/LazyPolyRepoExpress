:: FnEtcResolveOrganization <OrgId>
:: -- Resolves an organization from the data store, and exports:
:: --   GLOBAL_ResolvedOrgId            (OrganizationCommandIdentifier) command identifier
:: --   GLOBAL_ResolvedOrgIdentifier    (OrganizationFriendlyIdentifier) friendly identifier, used as the directory name
:: --   GLOBAL_ResolvedOrgName          (OrganizationFriendlyName) friendly name
:: --   GLOBAL_ResolvedOrgRootPath      (OrganizationRootPath) root path
:: --   GLOBAL_ResolvedOrgDataPath      (Computed) absolute path to the organization's data directory

@ECHO OFF

SET "Function_OrgId=%~1"

IF NOT DEFINED Function_OrgId (
    CALL FnEtcLogError "FnEtcResolveOrganization" "Missing required argument ^<OrgId^>"
    EXIT /B 1
)

IF /I "%GLOBAL_ResolvedOrgId%"=="%Function_OrgId%" EXIT /B 0
SET "GLOBAL_ResolvedOrgId="
SET "GLOBAL_ResolvedOrgIdentifier="
SET "GLOBAL_ResolvedOrgName="
SET "GLOBAL_ResolvedOrgRootPath="
SET "GLOBAL_ResolvedOrgDataPath="

CALL leprechaun function data Organizations
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_Index=0"
FOR %%O IN (%GLOBAL_DataOrgs%) DO (
    IF DEFINED GLOBAL_ResolvedOrgIdentifier EXIT /B 0

    IF /I "%%O"=="%Function_OrgId%" (
        CALL leprechaun function env DataPath
        IF ERRORLEVEL 1 EXIT /B 1

        CALL SET "GLOBAL_ResolvedOrgIdentifier=%%GLOBAL_DataOrg%Local_Index%Identifier%%"
        CALL SET "GLOBAL_ResolvedOrgName=%%GLOBAL_DataOrg%Local_Index%Name%%"
        CALL SET "GLOBAL_ResolvedOrgRootPath=%%GLOBAL_DataOrg%Local_Index%RootPath%%"
        SET "GLOBAL_ResolvedOrgId=%Function_OrgId%"
        SET "GLOBAL_ResolvedOrgDataPath=%GLOBAL_DataPath%\Data\Organizations\%GLOBAL_ResolvedOrgIdentifier%"
        SET "Function_OrgId="
        SET "Local_Index="
        EXIT /B 0
    )
    SET /A Local_Index+=1
)

SET "Function_OrgId="
SET "Local_Index="
EXIT /B 0