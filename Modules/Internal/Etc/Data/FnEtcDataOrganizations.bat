:: FnEtcDataOrganizations
:: leprechaun function data Organizations
:: -- Reads Data/Organizations.csv and exports:
:: --   GLOBAL_DataOrgs                                             (OrganizationCommandIdentifier[]) space separated organization command identifiers
:: --   GLOBAL_DataOrg<Index>Id                                     (OrganizationCommandIdentifier) command identifier
:: --   GLOBAL_DataOrg<Index>Identifier                             (OrganizationFriendlyIdentifier) friendly identifier, used as the directory name
:: --   GLOBAL_DataOrg<Index>Name                                   (OrganizationFriendlyName) friendly name
:: --   GLOBAL_DataOrg<Index>RootPath                               (OrganizationRootPath) root path

@ECHO OFF

CALL leprechaun function env DataPath
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_DataOrgsFile=%GLOBAL_DataPath%\Organizations.csv"
IF NOT EXIST "%Local_DataOrgsFile%" (
    CALL leprechaun function log error FnEtcDataOrganizations "Organizations.csv not found at %Local_DataOrgsFile%"
    EXIT /B 1
)

FOR /F "delims==" %%V IN ('SET GLOBAL_DataOrg 2^>NUL') DO SET "%%V="

:: Extract -> CommandIdentifier,FriendlyIdentifier,FriendlyName,Description,RootPath
SET "Local_Index=0"
FOR /F "usebackq skip=1 tokens=1-5 delims=, eol=#" %%A IN ("%Local_DataOrgsFile%") DO (
    CALL SET "GLOBAL_DataOrgs=%%GLOBAL_DataOrgs%% %%A"
    CALL SET "GLOBAL_DataOrg%%Local_Index%%Id=%%A"
    CALL SET "GLOBAL_DataOrg%%Local_Index%%Identifier=%%B"
    CALL SET "GLOBAL_DataOrg%%Local_Index%%Name=%%C"
    CALL SET "GLOBAL_DataOrg%%Local_Index%%RootPath=%%E"
    SET /A Local_Index+=1
)

:: Trim if possible
SET "GLOBAL_DataOrgs=%GLOBAL_DataOrgs:~1%"
IF NOT DEFINED GLOBAL_DataOrgs (
    CALL leprechaun function log error FnEtcDataOrganizations "No organizations found in %Local_DataOrgsFile%"
    SET "Local_DataOrgsFile="
    EXIT /B 1
)

:: Cleanup
SET "Local_DataOrgsFile="
SET "Local_Index="
EXIT /B 0
