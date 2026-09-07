:: FnEtcCacheSet <Key> <Value>
:: -- Desc:
:: --   Sets the value of the specified cache key.
:: -- Input:
:: --   Input_Key                          The cache key to set.
:: --   Input_Value                        The value to set for the cache key.
:: -- Output: void

@ECHO OFF

:: INPUT
SET "Input_Key=%~1"
SET "Input_Value=%~2"

IF NOT DEFINED Input_Key CALL FnEtcLogError %~n0 "Missing required argument <Key>" & EXIT /B 1
:: IF NOT DEFINED Input_Value CALL FnEtcLogError %~n0 "Missing required argument <Value>" & EXIT /B 1

:: MAPPING(%%X: Key, %%Y: Value)
SET "Local_Saved="
SET "Local_CachePath=%~dp0..\..\..\..\Cache\Lazy.cache"
FOR /F "tokens=1,2 delims==" %%X IN (%Local_CachePath%) DO (
    IF "%%X"=="%Input_Key%" (
        >> "%Local_CachePath%.tmp" ECHO %%X=%Input_Value%
        SET "Local_Saved=1"
    ) ELSE (
        >> "%Local_CachePath%.tmp" ECHO %%X=%%Y
    )
)

IF NOT DEFINED Local_Saved (
    >> "%Local_CachePath%.tmp" ECHO %Input_Key%=%Input_Value%
)

COPY /Y "%Local_CachePath%.tmp" "%Local_CachePath%" > NUL
DEL "%Local_CachePath%.tmp" > NUL
EXIT /B 0
