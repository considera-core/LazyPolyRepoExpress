:: VanguardConfig(
::  function: get | set | del | list  **required
::  key: string  **get or set or del required
::  value: string  **set required
:: )

@ECHO OFF

SETLOCAL ENABLEDELAYEDEXPANSION

SET function=%~1
SET key=%~2
SET value=%~3

REM Set configPath relative to the script location
SET "scriptDir=%~dp0"
REM Remove trailing backslash if present
IF "%scriptDir:~-1%"=="\" SET "scriptDir=%scriptDir:~0,-1%"
SET "configPath=%scriptDir%\..\config"
REM Normalize the path
FOR %%I IN ("%configPath%") DO SET "configPath=%%~fI"
SET configFile=%configPath%\lazy.config
SET configFileStatic=%configPath%\lazy.static.config
SET configFileTemp=%configPath%\lazy.config.tmp
SET configFileRes=%configPath%\lazy.config.res
SET configFileDefault=%configPath%\lazy.default.config
SET added=0

IF "%function%"=="new" (
    COPY %configFileDefault% %configFile% > NUL
    EXIT /B 0
)

IF "%function%"=="get" (
    FOR /F "tokens=1,2 delims==" %%G IN (%configFile%) DO (
        SET fKey=%%G
        SET fValue=%%H
        IF "%key%"=="!fKey!" (
            ECHO !fValue!
            EXIT /B 0
        )
    )
    EXIT /B 1
) 

IF "%function%"=="list" (
    FOR /F "tokens=1,2 delims==" %%G IN (%configFile%) DO ECHO %%G
    EXIT /B 0
) 

IF "%function%"=="set" (
    IF "%value%"=="" (
        ECHO Value expected.
        EXIT /B 1
    )
    FOR /F "tokens=1,2 delims==" %%G IN (%configFile%) DO (
        FOR /F "tokens=* delims= " %%a IN ("%%G") DO SET "fKey=%%a"
        FOR /F "tokens=* delims= " %%b IN ("%%H") DO SET "fValue=%%b"
        IF /I "%key%"=="!fKey!" (
            >> "%configFileRes%" ECHO !fKey!=%value%
            SET "added=1"
        ) ELSE (
            >> "%configFileRes%" ECHO !fKey!=!fValue!
        )
    )
    IF !added!==0 (
        >> "%configFileRes%" ECHO %key%=%value%
    )
    COPY /Y "%configFileRes%" "%configFile%" > NUL
    DEL "%configFileRes%"
    EXIT /B 0
)

IF "%function%"=="del" (
    FOR /F "tokens=1,2 delims==" %%G IN (%configFile%) DO (
        SET "fKey=%%G"
        CALL SET "fValue=%%H"
        IF NOT "%key%"=="!fKey!" (
            ECHO !fKey!=!fValue! >> %configFileRes%
        ) 
    )
    COPY %configFileRes% %configFile% > NUL
    DEL %configFileRes%
    EXIT /B 0
)

IF "%function%"=="static" (
    IF "%key%"=="get" (
        FOR /F "tokens=1,2 delims==" %%G IN (%configFileStatic%) DO (
            SET fKey=%%G
            SET fValue=%%H
            IF "%value%"=="!fKey!" (
                ECHO !fValue!
                EXIT /B 0
            )
        )
    )
    IF "%key%"=="list" (
        FOR /F "tokens=1,2 delims==" %%G IN (%configFileStatic%) DO ECHO %%G
        EXIT /B 0
    ) 
    IF "%key%"=="dict" (
        FOR /F "tokens=1,2 delims==" %%G IN (%configFileStatic%) DO ECHO %%G %%H
        EXIT /B 0
    ) 
    EXIT /B 1
) 

echo Usage for Config helper script:
echo   Usages: 
echo     ^|^| fn-config [function] [key?] [value?]
echo     ^|^| fn-config get [key]
echo     ^|^| fn-config list
echo     ^|^| fn-config set [key] [value]
echo     ^|^| fn-config del [key]
echo     ^|^| fn-config new
echo     ^|^| fn-config static get [key]
echo     ^|^| fn-config static list
echo   Options:
echo     ^|^| function: get ^| list ^| set ^| del ^| new
echo   What:
echo     ^|^| get: outputs the value from the provided key.
echo     ^|^| list: outputs the list of keys in the config.
echo     ^|^| new: restores the default config.
echo   Notes:
echo     ^|^| There are no confirmations for any of the commands.
exit /B 0