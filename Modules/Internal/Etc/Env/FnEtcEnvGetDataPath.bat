:: FnEtcEnvGetDataPath
:: -- Resolves the v2 Data directory and sets GLOBAL_DataPath.
:: --
:: -- Self-locating from %~dp0 rather than going through fn-config, because
:: -- "fn-config get RootRepoPath" returns the repository root while every
:: -- consumer of it uses the value as if it were the v2 directory.
:: --
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_DataPath.

@ECHO OFF

:: <v2>/Modules/Internal/Etc/ -> <v2>/Data
FOR %%I IN ("%~dp0..\..\..\Data") DO SET "GLOBAL_DataPath=%%~fI"

IF NOT EXIST "%GLOBAL_DataPath%" (
    ECHO LeprechaunCLI:FnEtcEnvGetDataPath[E]: Data directory not found at %GLOBAL_DataPath%
    EXIT /B 1
)

EXIT /B 0
