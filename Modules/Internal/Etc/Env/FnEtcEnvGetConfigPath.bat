:: FnEtcEnvGetConfigPath

@ECHO OFF

SET "Output_Env_ConfigPath=%~dp0..\..\..\..\Config\Lazy.config"

IF NOT EXIST "%Output_Env_ConfigPath%" (
    CALL FnEtcLogError FnEtcEnvGetConfigPath "Config file not found at %Output_Env_ConfigPath%"
    SET "Output_Env_ConfigPath="
    EXIT /B 1
)

EXIT /B 0
