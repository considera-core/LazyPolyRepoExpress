:: FnEtcResolveSuite <SuiteId> <Flags...>
:: -- Resolves a suite from the data store, and exports:
:: --   GLOBAL_ResolvedSuiteId              (SuiteCommandIdentifier) command identifier
:: --   GLOBAL_ResolvedSuiteIdentifier      (SuiteFriendlyIdentifier) friendly identifier, used as the directory name
:: --   GLOBAL_ResolvedSuiteName            (SuiteFriendlyName) friendly name
:: --   GLOBAL_ResolvedSuiteRootPath        (SuiteRootPath) absolute path to the suite's root directory
:: --   GLOBAL_ResolvedSuiteDataPath        (Computed) absolute path to the suite's data directory
:: --   GLOBAL_ResolvedSuiteOrgId           (FK) owning organization command identifier
:: -- Flags:
:: --   --refresh: forces a reload of the suite data, even if it was already loaded in this scope

@ECHO OFF

SET "Function_SuiteId=%~1"

CALL leprechaun function flags %*

IF NOT DEFINED Function_SuiteId (
    CALL FnEtcLogError "FnEtcResolveSuite" "Missing required argument ^<SuiteId^>"
    EXIT /B 1
)

IF /I "%GLOBAL_ResolvedSuiteId%"=="%Function_SuiteId%" (
    IF NOT DEFINED GLOBAL_FlagRefresh EXIT /B 0
)

SET "GLOBAL_ResolvedSuiteId="
SET "GLOBAL_ResolvedSuiteIdentifier="
SET "GLOBAL_ResolvedSuiteName="
SET "GLOBAL_ResolvedSuiteRootPath="
SET "GLOBAL_ResolvedSuiteDataPath="
SET "GLOBAL_ResolvedSuiteOrgId="

CALL leprechaun function data Suites
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_Index=0"
FOR %%S IN (%GLOBAL_DataSuites%) DO (
    IF DEFINED GLOBAL_ResolvedSuiteId EXIT /B 0

    IF /I "%%S"=="%Function_SuiteId%" (
        CALL leprechaun function env DataPath
        IF ERRORLEVEL 1 EXIT /B 1

        CALL leprechaun function resolve Organization "%GLOBAL_ResolvedSuiteOrgId%"
        IF ERRORLEVEL 1 EXIT /B 1

        CALL SET "GLOBAL_ResolvedSuiteIdentifier=%%GLOBAL_DataSuite%%Local_Index%%Identifier%%"
        CALL SET "GLOBAL_ResolvedSuiteName=%%GLOBAL_DataSuite%%Local_Index%%Name%%"
        CALL SET "GLOBAL_ResolvedSuiteRootPath=%%GLOBAL_DataSuite%%Local_Index%%RootPath%%"
        CALL SET "GLOBAL_ResolvedSuiteOrgId=%%GLOBAL_DataSuite%%Local_Index%%OrgId%%"
        SET "GLOBAL_ResolvedSuiteId=%Function_SuiteId%"
        SET "GLOBAL_ResolvedSuiteDataPath=%GLOBAL_DataPath%\Data\Organizations\%GLOBAL_ResolvedOrgIdentifier%\Suites\%GLOBAL_ResolvedSuiteIdentifier%"
        SET "Function_SuiteId="
        SET "Local_Index="
        EXIT /B 0
    )

    SET /A Local_Index+=1
)

IF NOT DEFINED GLOBAL_ResolvedSuiteId (
    CALL FnEtcLogError "FnEtcResolveSuite" "Unknown suite ""%Function_SuiteId%"""
    ECHO   Suites: %GLOBAL_DataSuites%
    SET "Function_SuiteId="
    EXIT /B 1
)

SET "Function_SuiteId="
SET "Local_Index="
EXIT /B 0
