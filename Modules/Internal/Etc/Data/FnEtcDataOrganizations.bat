:: FnEtcDataOrganizations
:: -- Output:
:: --   Output_Data_Orgs                        (OrganizationCommandIdentifier[]) space separated command identifiers
:: --   Output_Data_OrgsCount               (Computed) number of organizations
:: --   Output_Data_Org<Index>Id            (OrganizationCommandIdentifier) command identifier
:: --   Output_Data_Org<Index>Identifier    (OrganizationFriendlyIdentifier) directory name
:: --   Output_Data_Org<Index>Name          (OrganizationFriendlyName) friendly name
:: --   Output_Data_Org<Index>Description   (OrganizationDescription) description
:: --   Output_Data_Org<Index>RootPath      (OrganizationRootPath) root path

@ECHO OFF

:: MAPPING(A: Id, B: Identifier, C: Name, D: Description, E: RootPath)
SET "Output_Data_Orgs="
SET "Output_Data_OrgsCount=0"
SET "Local_DataPath=%~dp0..\..\..\..\Data\Organizations.csv"
FOR /F "usebackq skip=1 tokens=1-5 delims=, eol=#" %%a IN ("%Local_DataPath%") DO (
    IF DEFINED Output_Data_Orgs CALL SET "Output_Data_Orgs=%%Output_Data_Orgs%% %%a"
    IF NOT DEFINED Output_Data_Orgs SET "Output_Data_Orgs=%%a"
    CALL SET "Output_Data_Org%%Output_Data_OrgsCount%%Id=%%a"
    CALL SET "Output_Data_Org%%Output_Data_OrgsCount%%Identifier=%%b"
    CALL SET "Output_Data_Org%%Output_Data_OrgsCount%%Name=%%c"
    CALL SET "Output_Data_Org%%Output_Data_OrgsCount%%Description=%%d"
    CALL SET "Output_Data_Org%%Output_Data_OrgsCount%%RootPath=%%e"
    SET /A Output_Data_OrgsCount+=1
    CALL FnEtcCacheSet "Orgs" "%%Output_Data_Orgs%%"
    CALL FnEtcCacheSet "OrgId[%%a]" "%%a"
    CALL FnEtcCacheSet "OrgIdentifier[%%a]" "%%b"
    CALL FnEtcCacheSet "OrgName[%%a]" "%%c"
    CALL FnEtcCacheSet "OrgDescription[%%a]" "%%d"
    CALL FnEtcCacheSet "OrgRootPath[%%a]" "%%e"
)

EXIT /B 0
