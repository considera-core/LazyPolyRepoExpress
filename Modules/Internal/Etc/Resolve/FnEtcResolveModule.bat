:: FnEtcResolveModule <ModuleId> <Flags...>
:: -- Resolves a module from the data store, and exports:
:: --   GLOBAL_ResolvedModuleId                              (ModuleCommandIdentifier) command identifier
:: --   GLOBAL_ResolvedModuleDataPath                        (Computed) absolute path to the module's data directory
:: -- Flags:
:: --   --refresh: forces a reload of the module data, even if it was already loaded in this scope

@ECHO OFF

SET "Function_ModuleId=%~1"

CALL leprechaun function flags %*

IF NOT DEFINED Function_ModuleId (
    CALL leprechaun function log error FnEtcResolveModule "Missing required argument ^<ModuleId^>"
    EXIT /B 1
)

IF /I "%GLOBAL_ResolvedModuleId%"=="%Function_ModuleId%" (
    IF NOT DEFINED GLOBAL_FlagRefresh EXIT /B 0
)

SET "GLOBAL_ResolvedModuleId="

CALL leprechaun function env DataPath
IF ERRORLEVEL 1 EXIT /B 1

CALL leprechaun function data Modules
IF ERRORLEVEL 1 EXIT /B 1

SET "Local_Index=0"
FOR %%M IN (%GLOBAL_DataModules%) DO (
    IF DEFINED GLOBAL_ResolvedModuleId EXIT /B 0

    IF /I "%%M"=="%Function_ModuleId%" (
        EXIT /B 0
    )

    SET /A Local_Index+=1
)

SET "GLOBAL_ResolvedModuleId=%Function_ModuleId%"
SET "GLOBAL_ResolvedModuleDataPath=%GLOBAL_DataPath%\Data\Modules\%GLOBAL_ResolvedModuleId%\Modules.csv"
SET "Function_ModuleId="
SET "Local_Index="
EXIT /B 0
