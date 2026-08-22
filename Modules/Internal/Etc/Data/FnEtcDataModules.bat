:: FnEtcDataModules
:: leprechaun function data Modules
:: -- Reads Data/Modules.csv and exports:
:: --   GLOBAL_DataMods                                             (ModuleIdentifier[]) space separated module command identifiers
:: --   GLOBAL_DataMod<Index>Id                                     (ModuleIdentifier) command identifier

@ECHO OFF

:: CALL leprechaun function flags %*
CALL FnEtcFlags %*
IF DEFINED GLOBAL_FlagRefresh EXIT /B 0

:: CALL leprechaun function env DataPath
CALL FnEtcEnvGetDataPath
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_DataModsFile=%GLOBAL_DataPath%\Modules.csv"
IF NOT EXIST "%Local_DataModsFile%" (
    CALL leprechaun function log error FnEtcDataModules "Modules.csv not found at %Local_DataModsFile%"
    EXIT /B 1
)

FOR /F "delims==" %%V IN ('SET GLOBAL_DataMod 2^>NUL') DO SET "%%V="

:: Extract -> CommandIdentifier
FOR /F "usebackq skip=1 tokens=1 delims=, eol=#" %%A IN ("%Local_DataModsFile%") DO (
    SET "GLOBAL_DataMods=%GLOBAL_DataMods% %%A"
    SET "GLOBAL_DataMods%%AId=%%A"
)

:: Trim if possible
SET "GLOBAL_DataMods=%GLOBAL_DataMods:~1%"
IF NOT DEFINED GLOBAL_DataMods (
    CALL leprechaun function log error FnEtcDataModules "No modules found in %Local_DataModsFile%"
    EXIT /B 1
)

:: Cleanup
SET "Local_DataModsFile="
EXIT /B 0
