:: FnEtcConfigGet <Key>
:: -- Attributes:
:: --   PURE: Can only use FnEtcEnvGetConfigPath
:: -- Desc:
:: --   Retrieves the value of the specified configuration key.
:: -- Output:
:: --   Output_Config_Key                   The configuration key that was requested.
:: --   Output_Config_Value                 The value of the configuration key.

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "Input_Key=%~1"

IF NOT DEFINED Input_Key (
    ECHO FnEtcConfigGet[F]: Missing required argument Key
    EXIT /B 1
)

CALL FnEtcEnvGetConfigPath
IF ERRORLEVEL 1 EXIT /B 1

SET "Output_Config_Key=%Input_Key%"
SET "Output_Config_Value="


FOR /F "tokens=1,2 delims==" %%G IN (%Output_Env_ConfigPath%) DO (
    IF NOT DEFINED Output_Config_Value (
        SET "Local_Key=%%G"
        SET "Local_Value=%%H"
        IF "%Input_Key%"=="!Local_Key!" (
            SET "Output_Config_Value=!Local_Value!"
        )
    )
)

ENDLOCAL & SET "Output_Config_Value=%Output_Config_Value%"
EXIT /B 0