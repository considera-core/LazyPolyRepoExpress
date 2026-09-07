:: FnEtcResolveSuite <OrgId> <SuiteId>
:: -- Output:
:: --   Output_Resolved_SuiteId              (SuiteCommandIdentifier) command identifier
:: --   Output_Resolved_SuiteIdentifier      (SuiteFriendlyIdentifier) directory name
:: --   Output_Resolved_SuiteName            (SuiteFriendlyName) friendly name
:: --   Output_Resolved_SuiteRootPath        (SuiteRootPath) absolute path to the suite root
:: --   Output_Resolved_SuiteActive          (SuiteIsActive) true or false
:: --   Output_Resolved_SuiteOrgId           (FK) owning organization command identifier
:: -- Dependencies:
:: --   FnEtcDataSuites
:: --     FnEtcResolveOrganization
:: -- Actions (Optional):
:: --   refresh: resolve again even when this suite is already in scope

@ECHO OFF

:: INPUT
SET "Input_OrgId=%~1"
SET "Input_SuiteId=%~2"

IF NOT DEFINED Input_OrgId CALL FnEtcLogError %~n0 "Missing required argument <OrgId>" & EXIT /B 1
IF NOT DEFINED Input_SuiteId CALL FnEtcLogError %~n0 "Missing required argument <SuiteId>" & EXIT /B 1

:: CACHE
CALL FnEtcCacheGet SuiteId "[%Input_OrgId%][%Input_SuiteId%]" || CALL FnEtcDataSuites %Input_OrgId%
CALL FnEtcCacheGet SuiteIdentifier "[%Input_OrgId%][%Input_SuiteId%]" || CALL FnEtcDataSuites %Input_OrgId%
CALL FnEtcCacheGet SuiteName "[%Input_OrgId%][%Input_SuiteId%]" || CALL FnEtcDataSuites %Input_OrgId%
CALL FnEtcCacheGet SuiteRootPath "[%Input_OrgId%][%Input_SuiteId%]" || CALL FnEtcDataSuites %Input_OrgId%
CALL FnEtcCacheGet SuiteActive "[%Input_OrgId%][%Input_SuiteId%]" || CALL FnEtcDataSuites %Input_OrgId%

IF DEFINED Output_Cache_SuiteId IF DEFINED Output_Cache_SuiteIdentifier IF DEFINED Output_Cache_SuiteName IF DEFINED Output_Cache_SuiteRootPath IF DEFINED Output_Cache_SuiteActive (
    SET "Output_Resolved_SuiteId=%Output_Cache_SuiteId%"
    SET "Output_Resolved_SuiteIdentifier=%Output_Cache_SuiteIdentifier%"
    SET "Output_Resolved_SuiteName=%Output_Cache_SuiteName%"
    SET "Output_Resolved_SuiteRootPath=%Output_Cache_SuiteRootPath%"
    SET "Output_Resolved_SuiteActive=%Output_Cache_SuiteActive%"
    SET "Output_Resolved_SuiteOrgId=%Output_Resolved_OrgId%"
    EXIT /B 0
)

:: MAPPING
SETLOCAL EnableDelayedExpansion
SET "Local_Index=0"
FOR %%S IN (%Output_Data_Suites%) DO (
    IF NOT DEFINED Output_Resolved_SuiteId (
        IF /I NOT "%Input_SuiteId%"=="%%S" (
            SET /A Local_Index+=1
        ) ELSE (
            CALL SET "Local_SuiteId=%%S"
            CALL SET "Local_SuiteIdentifier=!Output_Data_Suite%Local_Index%Identifier!"
            CALL SET "Local_SuiteName=!Output_Data_Suite%Local_Index%Name!"
            CALL SET "Local_SuiteRootPath=!Output_Data_Suite%Local_Index%RootPath!"
            CALL SET "Local_SuiteActive=!Output_Data_Suite%Local_Index%Active!"
            CALL SET "Local_SuiteOrgId=%Output_Resolved_OrgId%"
        )
    )
)

ENDLOCAL ^
    & SET "Output_Resolved_SuiteId=%Local_SuiteId%" ^
    & SET "Output_Resolved_SuiteIdentifier=%Local_SuiteIdentifier%" ^
    & SET "Output_Resolved_SuiteName=%Local_SuiteName%" ^
    & SET "Output_Resolved_SuiteRootPath=%Local_SuiteRootPath%" ^
    & SET "Output_Resolved_SuiteActive=%Local_SuiteActive%" ^
    & SET "Output_Resolved_SuiteOrgId=%Local_SuiteOrgId%"

IF NOT DEFINED Output_Resolved_SuiteId CALL FnEtcLogError %~n0 "Unknown suite %Input_SuiteId%" & EXIT /B 1

EXIT /B 0
