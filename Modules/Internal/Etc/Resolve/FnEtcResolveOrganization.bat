:: FnEtcResolveOrganization <OrgId>
:: -- Output:
:: --   Output_Resolved_OrgId            (OrganizationCommandIdentifier) command identifier
:: --   Output_Resolved_OrgIdentifier    (OrganizationFriendlyIdentifier) directory name
:: --   Output_Resolved_OrgName          (OrganizationFriendlyName) friendly name
:: --   Output_Resolved_OrgRootPath      (OrganizationRootPath) root path

@ECHO OFF

:: INPUT
SET "Input_OrgId=%~1"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument <OrgId>" & EXIT /B 1

:: CACHE
CALL FnEtcCacheGet OrgId "[%Input_OrgId%]" || CALL FnEtcDataOrganizations
CALL FnEtcCacheGet OrgIdentifier "[%Input_OrgId%]" || CALL FnEtcDataOrganizations
CALL FnEtcCacheGet OrgName "[%Input_OrgId%]" || CALL FnEtcDataOrganizations
CALL FnEtcCacheGet OrgDescription "[%Input_OrgId%]" || CALL FnEtcDataOrganizations
CALL FnEtcCacheGet OrgRootPath "[%Input_OrgId%]" || CALL FnEtcDataOrganizations

IF DEFINED Output_Cache_OrgId IF DEFINED Output_Cache_OrgIdentifier IF DEFINED Output_Cache_OrgName IF DEFINED Output_Cache_OrgDescription IF DEFINED Output_Cache_OrgRootPath (
    SET "Output_Resolved_OrgId=%Output_Cache_OrgId%"
    SET "Output_Resolved_OrgIdentifier=%Output_Cache_OrgIdentifier%"
    SET "Output_Resolved_OrgName=%Output_Cache_OrgName%"
    SET "Output_Resolved_OrgDescription=%Output_Cache_OrgDescription%"
    SET "Output_Resolved_OrgRootPath=%Output_Cache_OrgRootPath%"
    EXIT /B 0
)

:: MAPPING
SETLOCAL EnableDelayedExpansion
SET "Local_Index=0"
FOR %%O IN (%Output_Data_Orgs%) DO (
    IF NOT DEFINED Output_Resolved_OrgId (
        IF /I NOT "%Input_OrgId%"=="%%O" (
            SET /A Local_Index+=1
        ) ELSE (
            CALL SET "Local_OrgId=%%O"
            CALL SET "Local_OrgIdentifier=!Output_Data_Org%Local_Index%Identifier!"
            CALL SET "Local_OrgName=!Output_Data_Org%Local_Index%Name!"
            CALL SET "Local_OrgDescription=!Output_Data_Org%Local_Index%Description!"
            CALL SET "Local_OrgRootPath=!Output_Data_Org%Local_Index%RootPath!"
        )
    )
)

ENDLOCAL ^
    & SET "Output_Resolved_OrgId=%Local_OrgId%" ^
    & SET "Output_Resolved_OrgIdentifier=%Local_OrgIdentifier%" ^
    & SET "Output_Resolved_OrgName=%Local_OrgName%" ^
    & SET "Output_Resolved_OrgDescription=%Local_OrgDescription%" ^
    & SET "Output_Resolved_OrgRootPath=%Local_OrgRootPath%"

IF NOT DEFINED Output_Resolved_OrgId CALL FnEtcLogError %~n0 "Unknown organization %Input_OrgId%" & EXIT /B 1

EXIT /B 0
