:: FnEtcDataModules <Flag[]>
:: leprechaun function data Modules
:: -- Reads Data/Modules.csv and exports:
:: --   GLOBAL_DataMods                     (ModuleIdentifier[]) space separated module identifiers
:: --   GLOBAL_DataMod<Index>Id             (ModuleIdentifier) module identifier
:: -- Flags:
:: --   --refresh: reread the CSV even when it is already loaded in this scope
:: --
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_DataMod*.

@ECHO OFF

CALL FnEtcFlags %*

:: Memoized: a warm list is reused unless --refresh asks for a reread.
IF DEFINED GLOBAL_DataMods IF NOT DEFINED GLOBAL_FlagRefresh EXIT /B 0

CALL FnEtcEnvGetDataPath
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_DataModsFile=%GLOBAL_DataPath%\Modules.csv"
IF NOT EXIST "%Local_DataModsFile%" (
    CALL FnEtcLogError FnEtcDataModules "Modules.csv not found at %Local_DataModsFile%"
    SET "Local_DataModsFile="
    EXIT /B 1
)

FOR /F "delims==" %%V IN ('SET GLOBAL_DataMod 2^>NUL') DO SET "%%V="

:: Extract -> ModuleIdentifier
:: CALL SET, because a plain SET inside a FOR body would expand the accumulator
:: once at block parse time and leave only the last row behind.
SET "Local_Index=0"
FOR /F "usebackq skip=1 tokens=1 delims=, eol=#" %%a IN ("%Local_DataModsFile%") DO (
    CALL SET "GLOBAL_DataMods=%%GLOBAL_DataMods%% %%a"
    CALL SET "GLOBAL_DataMod%%Local_Index%%Id=%%a"
    SET /A Local_Index+=1
)

:: A CSV holding only its header is a declared but empty collection, which
:: is valid. Only a missing file is an error, and that was checked above.

:: Trim the leading separator so the joined form iterates cleanly.
IF DEFINED GLOBAL_DataMods SET "GLOBAL_DataMods=%GLOBAL_DataMods:~1%"
SET "GLOBAL_DataModsCount=%Local_Index%"

SET "Local_DataModsFile="
SET "Local_Index="
EXIT /B 0
