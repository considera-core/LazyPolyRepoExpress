:: FnEtcConfigSet <Key> <Value>
:: -- Attributes:
:: --   PURE: Can only use FnEtcEnvGetConfigPath
:: -- Desc:
:: --   Sets the value of the specified configuration key.
:: -- Input:
:: --   Input_Key                          The configuration key to set.
:: --   Input_Value                        The value to set for the configuration key.
:: -- Output: void

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

:: INPUT
SET "Input_Key=%~1"
SET "Input_Value=%~2"

IF NOT DEFINED Input_Key CALL FnEtcLogFatal %~n0 "Missing required argument Key" & EXIT /B 1

:: RESOLVE
CALL FnEtcLogDebug %~n0 "Resolving config path..."
CALL FnEtcEnvGetConfigPath
IF ERRORLEVEL 1 EXIT /B 1
CALL FnEtcLogDebug %~n0 "Resolved config path (Output_Env_ConfigPath): %Output_Env_ConfigPath%"

:: MAPPING
SET "Local_Saved="
FOR /F "tokens=1,2 delims==" %%G IN (%Output_Env_ConfigPath%) DO (
    CALL FnEtcLogDebug %~n0 "Processing line: %%G=%%H"
    FOR /F "tokens=* delims= " %%A IN ("%%G") DO SET "Local_Key=%%A"
    FOR /F "tokens=* delims= " %%B IN ("%%H") DO SET "Local_Value=%%B"
    IF "%Input_Key%"=="!Local_Key!" (
        CALL FnEtcLogDebug %~n0 "Updating config for key: %Input_Key% ^= %Input_Value%"
        >> "%Output_Env_ConfigPath%.tmp" ECHO !Local_Key!=!Input_Value!
        SET "Local_Saved=1"
    ) ELSE (
        CALL FnEtcLogDebug %~n0 "Keeping existing config for key: !Local_Key! ^= !Local_Value!"
        >> "%Output_Env_ConfigPath%.tmp" ECHO !Local_Key!=!Local_Value!
    )
)

IF NOT DEFINED Local_Saved (
    CALL FnEtcLogDebug %~n0 "Adding new config entry for key: %Input_Key% ^= %Input_Value%"
    >> "%Output_Env_ConfigPath%.tmp" ECHO %Input_Key%=%Input_Value%
)


CALL FnEtcLogDebug %~n0 "Copying and deleting temporary file: %Output_Env_ConfigPath%.tmp"
COPY /Y "%Output_Env_ConfigPath%.tmp" "%Output_Env_ConfigPath%" > NUL
DEL "%Output_Env_ConfigPath%.tmp" > NUL
EXIT /B 0
