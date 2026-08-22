:: FnEtcBootstrapOrganizations [FLAGS...]
:: -- Caches every organization, suite and project into the environment as
:: --   ORGANIZATIONS_COUNT
:: --   ORGANIZATIONS_<i>_COMMAND_IDENTIFIER / _FRIENDLY_IDENTIFIER
:: --   ORGANIZATIONS_<i>_FRIENDLY_NAME / _ROOT_PATH
:: -- then recurses through FnEtcBootstrapSuites.
:: --
:: -- CSV parsing lives in FnEtcCsvOrgs; this script only shapes the cache. The
:: -- dispatch chain queries the FnEtcCsv* readers directly and does not need
:: -- this cache to be warm.
:: --
:: -- NOTE: No SETLOCAL -- this script exists to export ORGANIZATIONS_*.

@ECHO OFF

CALL FnEtcCsvOrgs
IF ERRORLEVEL 1 EXIT /B 1

FOR /F "delims==" %%V IN ('SET ORGANIZATIONS_ 2^>NUL') DO SET "%%V="
SET "ORGANIZATIONS_COUNT=0"
SET "BS_RC=0"
SET "BS_ORGS=%GLOBAL_DataOrgs%"

FOR %%O IN (%BS_ORGS%) DO CALL :ORG "%%O"

SET "BS_ORGS="
EXIT /B %BS_RC%

:ORG
    SET /A ORGANIZATIONS_COUNT+=1
    CALL SET "BS_DIR=%%GLOBAL_ORG_%~1_DIR%%"
    CALL SET "BS_NAME=%%GLOBAL_ORG_%~1_NAME%%"
    CALL SET "BS_ROOT=%%GLOBAL_ORG_%~1_ROOT%%"
    SET "ORGANIZATIONS_%ORGANIZATIONS_COUNT%_COMMAND_IDENTIFIER=%~1"
    SET "ORGANIZATIONS_%ORGANIZATIONS_COUNT%_FRIENDLY_IDENTIFIER=%BS_DIR%"
    SET "ORGANIZATIONS_%ORGANIZATIONS_COUNT%_FRIENDLY_NAME=%BS_NAME%"
    SET "ORGANIZATIONS_%ORGANIZATIONS_COUNT%_ROOT_PATH=%BS_ROOT%"
    CALL FnEtcBootstrapSuites -o "%~1" -i "%ORGANIZATIONS_COUNT%"
    IF ERRORLEVEL 1 SET "BS_RC=1"
    EXIT /B 0
