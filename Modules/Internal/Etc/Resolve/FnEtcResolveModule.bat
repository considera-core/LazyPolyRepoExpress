:: FnEtcResolveModule <ModuleId> <Flag[]>
:: leprechaun function resolve Module <ModuleId>
:: -- Resolves a module from the data store, and exports:
:: --   GLOBAL_ResolvedModuleId         (ModuleIdentifier) module identifier
:: -- Flags:
:: --   --refresh: resolve again even when this module is already in scope
:: --
:: -- An unknown module is an error. This is the check that decides an invocation
:: -- is Internal rather than External, so it has to be exact.
:: --
:: -- NOTE: Locals are Export_ rather than Function_ on purpose. With no
:: --       SETLOCAL, a Function_ name here would be the CALLER's variable,
:: --       and clearing one on the way out would blank it under them.
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_ResolvedModuleId.

@ECHO OFF

SET "Export_ModuleId=%~1"

IF NOT DEFINED Export_ModuleId (
    CALL FnEtcLogError FnEtcResolveModule "Missing required argument <ModuleId>"
    EXIT /B 1
)

CALL FnEtcFlags %*

IF /I "%GLOBAL_ResolvedModuleId%"=="%Export_ModuleId%" IF NOT DEFINED GLOBAL_FlagRefresh (
    SET "Export_ModuleId="
    EXIT /B 0
)

SET "GLOBAL_ResolvedModuleId="

CALL FnEtcDataModules
IF ERRORLEVEL 1 EXIT /B 1

FOR %%M IN (%GLOBAL_DataMods%) DO IF /I "%%M"=="%Export_ModuleId%" SET "GLOBAL_ResolvedModuleId=%Export_ModuleId%"

IF NOT DEFINED GLOBAL_ResolvedModuleId (
    CALL FnEtcLogError FnEtcResolveModule "Unknown module %Export_ModuleId%"
    ECHO   Modules: %GLOBAL_DataMods%
    SET "Export_ModuleId="
    EXIT /B 1
)

SET "Export_ModuleId="
EXIT /B 0
