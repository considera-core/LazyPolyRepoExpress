:: FnEtcEnvGetDataPath
:: -- Output:
:: --   Output_Env_DataPath                     (string) resolved path to the Data directory

@ECHO OFF

:: <root>\Modules\Internal\Etc\Env\ -> <root>\Data
FOR %%I IN ("%~dp0..\..\..\..\Data") DO SET "Output_Env_DataPath=%%~fI"

IF NOT EXIST "%Output_Env_DataPath%" (
    CALL FnEtcLogError %~n0 "Data directory not found at %Output_Env_DataPath%"
    SET "Output_Env_DataPath="
    EXIT /B 1
)

EXIT /B 0
