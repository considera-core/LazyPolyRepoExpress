:: FnEtcEnvGetDataPath
:: leprechaun function env DataPath
:: -- Resolves the Data directory and exports GLOBAL_DataPath.
:: --
:: -- Self locating from %~dp0. The Bin forwarders CALL this script at its real
:: -- path and do not SETLOCAL, so %~dp0 still names this directory across the
:: -- hop and the export still reaches the original caller.
:: --
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_DataPath.

@ECHO OFF

:: <root>\Modules\Internal\Etc\Env\ -> <root>\Data
FOR %%I IN ("%~dp0..\..\..\..\Data") DO SET "GLOBAL_DataPath=%%~fI"

IF NOT EXIST "%GLOBAL_DataPath%" (
    CALL FnEtcLogError FnEtcEnvGetDataPath "Data directory not found at %GLOBAL_DataPath%"
    SET "GLOBAL_DataPath="
    EXIT /B 1
)

EXIT /B 0
