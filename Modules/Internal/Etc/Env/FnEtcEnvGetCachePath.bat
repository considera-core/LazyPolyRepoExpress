:: FnEtcEnvGetCachePath

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "Output_Env_CachePath=%~dp0..\..\..\..\Cache\Lazy.cache"

IF NOT EXIST "%Output_Env_CachePath%" (
    CALL FnEtcLogError FnEtcEnvGetCachePath "CachePath file not found at %Output_Env_CachePath%"
    SET "Output_Env_CachePath="
    EXIT /B 1
)

ENDLOCAL & SET "Output_Env_CachePath=%Output_Env_CachePath%"
EXIT /B 0
