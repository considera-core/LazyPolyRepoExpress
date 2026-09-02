:: FnEtcDataOrganizations <Flag[]>
:: leprechaun function data Organizations
:: -- Reads Data/Organizations.csv and exports:
:: --   GLOBAL_DataOrgs                     (OrganizationCommandIdentifier[]) space separated command identifiers
:: --   GLOBAL_DataOrgsCount                (Computed) number of organizations
:: --   GLOBAL_DataOrg<Index>Id             (OrganizationCommandIdentifier) command identifier
:: --   GLOBAL_DataOrg<Index>Identifier     (OrganizationFriendlyIdentifier) directory name
:: --   GLOBAL_DataOrg<Index>Name           (OrganizationFriendlyName) friendly name
:: --   GLOBAL_DataOrg<Index>RootPath       (OrganizationRootPath) root path
:: -- Flags:
:: --   --refresh: reread the CSV even when it is already loaded in this scope
:: --
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_DataOrg*.

@ECHO OFF

CALL FnEtcFlags %*

IF DEFINED GLOBAL_DataOrgs IF NOT DEFINED GLOBAL_FlagRefresh EXIT /B 0

CALL FnEtcEnvGetDataPath
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_DataOrgsFile=%GLOBAL_DataPath%\Organizations.csv"
IF NOT EXIST "%Local_DataOrgsFile%" (
    CALL FnEtcLogError FnEtcDataOrganizations "Organizations.csv not found at %Local_DataOrgsFile%"
    SET "Local_DataOrgsFile="
    EXIT /B 1
)

FOR /F "delims==" %%V IN ('SET GLOBAL_DataOrg 2^>NUL') DO SET "%%V="

:: Extract -> CommandIdentifier,FriendlyIdentifier,FriendlyName,Description,RootPath
SET "Local_Index=0"
:: Lowercase loop variables on purpose. FOR variables are case sensitive, so a
:: token range can never claim the %%G of "%%GLOBAL_..." out from under it.
FOR /F "usebackq skip=1 tokens=1-5 delims=, eol=#" %%a IN ("%Local_DataOrgsFile%") DO (
    CALL SET "GLOBAL_DataOrgs=%%GLOBAL_DataOrgs%% %%a"
    CALL SET "GLOBAL_DataOrg%%Local_Index%%Id=%%a"
    CALL SET "GLOBAL_DataOrg%%Local_Index%%Identifier=%%b"
    CALL SET "GLOBAL_DataOrg%%Local_Index%%Name=%%c"
    CALL SET "GLOBAL_DataOrg%%Local_Index%%RootPath=%%e"
    SET /A Local_Index+=1
)

:: A CSV holding only its header is a declared but empty collection, which
:: is valid. Only a missing file is an error, and that was checked above.

IF DEFINED GLOBAL_DataOrgs SET "GLOBAL_DataOrgs=%GLOBAL_DataOrgs:~1%"
SET "GLOBAL_DataOrgsCount=%Local_Index%"

SET "Local_DataOrgsFile="
SET "Local_Index="
EXIT /B 0
