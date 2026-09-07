:: FnEtcResolveSuiteApp <OrgId> <SuiteId> <AppId>
:: -- Outputs:
:: --   Output_Resolved_SuiteAppId             (AppCommandIdentifier) command identifier
:: --   Output_Resolved_SuiteAppLabel          (AppFriendlyName) friendly name
:: --   Output_Resolved_SuiteAppDescription    (AppFriendlyDescription) friendly description
:: --   Output_Resolved_SuiteAppSuiteId      (FK) owning suite project command identifier

@ECHO OFF

:: INPUT
SET "Input_OrgId=%~1"
SET "Input_SuiteId=%~2"
SET "Input_AppId=%~3"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument <OrgId>" & EXIT /B 1
IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "Missing required argument <SuiteId>" & EXIT /B 1
IF NOT DEFINED Input_AppId CALL FnEtcLogError %~n0 "Missing required argument <AppId>" & EXIT /B 1

:: CACHE
CALL FnEtcCacheGet "SuiteAppId[%Input_OrgId%][%Input_SuiteId%][%Input_AppId%]" || CALL FnEtcDataSuiteApps %Input_OrgId% %Input_SuiteId%
CALL FnEtcCacheGet "SuiteAppLabel[%Input_OrgId%][%Input_SuiteId%][%Input_AppId%]" || CALL FnEtcDataSuiteApps %Input_OrgId% %Input_SuiteId%
CALL FnEtcCacheGet "SuiteAppDescription[%Input_OrgId%][%Input_SuiteId%][%Input_AppId%]" || CALL FnEtcDataSuiteApps %Input_OrgId% %Input_SuiteId%
CALL FnEtcCacheGet "SuiteAppSuiteId[%Input_OrgId%][%Input_SuiteId%][%Input_AppId%]" || CALL FnEtcDataSuiteApps %Input_OrgId% %Input_SuiteId%

IF DEFINED Output_Cache_SuiteAppId IF DEFINED Output_Cache_SuiteAppLabel IF DEFINED Output_Cache_SuiteAppDescription IF DEFINED Output_Cache_SuiteAppSuiteId (
    SET "Output_Resolved_SuiteAppId=%Output_Cache_SuiteAppId%"
    SET "Output_Resolved_SuiteAppLabel=%Output_Cache_SuiteAppLabel%"
    SET "Output_Resolved_SuiteAppDescription=%Output_Cache_SuiteAppDescription%"
    SET "Output_Resolved_SuiteAppSuiteId=%Output_Cache_SuiteAppSuiteId%"
    EXIT /B 0
)

:: MAPPING
SETLOCAL EnableDelayedExpansion
SET "Local_Index=0"
FOR %%A IN (%Output_Data_SuiteApps%) DO (
    IF NOT DEFINED Output_Resolved_SuiteAppId (
        IF /I NOT "%Input_AppId%"=="%%A" (
            SET /A Local_Index+=1
        ) ELSE (
            CALL SET "Local_SuiteAppId=%Input_AppId%"
            CALL SET "Local_SuiteAppLabel=!Output_Data_SuiteApp%Local_Index%Label!"
            CALL SET "Local_SuiteAppDescription=!Output_Data_SuiteApp%Local_Index%Description!"
            CALL SET "Local_SuiteAppSuiteId=%Input_SuiteId%"
        )
    )
)

ENDLOCAL ^
    & SET "Output_Resolved_SuiteAppId=%Local_SuiteAppId%" ^
    & SET "Output_Resolved_SuiteAppLabel=%Local_SuiteAppLabel%" ^
    & SET "Output_Resolved_SuiteAppDescription=%Local_SuiteAppDescription%" ^
    & SET "Output_Resolved_SuiteAppSuiteId=%Local_SuiteAppSuiteId%"

IF NOT DEFINED Output_Resolved_SuiteAppId CALL FnEtcLogWarning %~n0 "Failed to resolve suite app with AppId: %Input_AppId%" & EXIT /B 1

EXIT /B 0
