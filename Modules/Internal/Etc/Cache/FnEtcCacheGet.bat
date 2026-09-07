:: FnEtcCacheGet <Name> <Selector?>
:: -- Desc:
:: --   Retrieves the value of the specified cache key.
:: -- Input:
:: --   <Name>                            The name of the cache section.
:: --   <Selector?>                       The optional series of selectors (ex: [org][suite])
:: -- Output:
:: --   Output_Cache_<Name>               The value of the cache key.

@ECHO OFF

:: INPUT
SET "Input_Name=%~1"
SET "Input_Selector=%~2"

IF NOT DEFINED Input_Name CALL FnEtcLogError %~n0 "Missing required argument <Name>" & EXIT /B 1

:: CLEAR
SET "Local_Cache_Key=%Input_Name%%Input_Selector%"
SET "Local_Cache_Value="
SET "Output_Cache_%Input_Name%="

:: MAPPING(G: Key, H: Value)
SET "Local_CachePath=%~dp0..\..\..\..\Cache\Lazy.cache"
FOR /F "tokens=1,2 delims==" %%G IN (%Local_CachePath%) DO (
    IF "%Local_Cache_Key%"=="%%G" (
        CALL SET "Local_Cache_Value=%%H"
        GOTO break
    )
)
:break

IF NOT DEFINED Local_Cache_Value EXIT /B 1
CALL SET "Output_Cache_%Input_Name%=%%Local_Cache_Value%%"
EXIT /B 0