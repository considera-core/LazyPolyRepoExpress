:: FnEtcFlags -p <KnownParameter[]> -a <Arg[]>
:: -- Will extract all flags and arguments excluding the known parameters, and return them in the caller's scope.
:: --
:: -- -p declares the parameters that take a value. An entry is either "short" or
:: --    "short:long", and every flag is keyed by its SHORT name, so -o and --org
:: --    both land in Output_FnEtcFlags_Flag_o:
:: --      CALL FnEtcFlags -p o:org s:suite p:project -a %*
:: -- -a is the line to parse, and must come last. Every token after it is data,
:: --    so an argument is free to be "-a" or "-p" itself.
:: -- Output:
:: --   Output_FnEtcFlags_Args          (Arg[]) space separated arguments


:: EX: FnEtcFlags -p considera consideraweb -a considera consideraweb git branch -V

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

FOR /F "delims==" %%V IN ('SET Output_FnEtcFlags_ 2^>NUL') DO SET "%%V="
CALL FnEtcLogDebug %~n0 "@SET Output_FnEtcFlags_* NULL"

SET "Local_Mode="
SET "Local_KnownParameters="
SET "Local_AllArgs="
SET "Local_Args="
SET "Local_Error="

CALL FnEtcLogDebug %~n0 "SET Local_Mode: !Local_Mode!"
CALL FnEtcLogDebug %~n0 "SET Local_KnownParameters: !Local_KnownParameters!"
CALL FnEtcLogDebug %~n0 "SET Local_AllArgs: !Local_AllArgs!"
CALL FnEtcLogDebug %~n0 "SET Local_Args: !Local_Args!"
CALL FnEtcLogDebug %~n0 "SET Local_Error: !Local_Error!"
CALL FnEtcLogDebug %~n0 "LOOP START"

FOR %%T IN (%*) DO (
    SET "Local_Token=%%~T"
    CALL FnEtcLogDebug %~n0 "- SET Local_Token: !Local_Token!"
    
    IF NOT DEFINED Local_Mode (
        IF /I "!Local_Token!"=="-p" SET "Local_Mode=KnownParameters"
        IF /I "!Local_Token!"=="-a" SET "Local_Mode=AllArgs"
        CALL FnEtcLogDebug %~n0 "-- [UNDEFINED] SET Local_Mode: !Local_Mode!"
    ) ELSE IF "!Local_Mode!"=="KnownParameters" (
        CALL FnEtcLogDebug %~n0 "-- [KNOWN]"

        IF /I "!Local_Token!"=="-a" (
            SET "Local_Mode=AllArgs"
            CALL FnEtcLogDebug %~n0 "--- [KNOWN] SET Local_Mode: AllArgs"
        ) ELSE (
            SET "Local_KnownParameters=!Local_KnownParameters! %%T"
            CALL FnEtcLogDebug %~n0 "--- [KNOWN] SET Local_KnownParameters: !Local_KnownParameters!"
        )
    ) ELSE (
        CALL FnEtcLogDebug %~n0 "-- [ARG]"

        SET "Local_AllArgs=!Local_AllArgs! %%T"
        CALL FnEtcLogDebug %~n0 "--- [ARG] SET Local_AllArgs: !Local_AllArgs!"
    )
)

CALL FnEtcLogDebug %~n0 "- LOOP RES START"
CALL FnEtcLogDebug %~n0 "-- SET Local_Mode: !Local_Mode!"
CALL FnEtcLogDebug %~n0 "-- SET Local_KnownParameters: !Local_KnownParameters!"
CALL FnEtcLogDebug %~n0 "-- SET Local_AllArgs: !Local_AllArgs!"
CALL FnEtcLogDebug %~n0 "-- SET Local_Args: !Local_Args!"
CALL FnEtcLogDebug %~n0 "-- SET Local_Error: !Local_Error!"
CALL FnEtcLogDebug %~n0 "- LOOP RES END"
CALL FnEtcLogDebug %~n0 "LOOP END"

IF NOT "!Local_Mode!"=="AllArgs" SET "Local_Error=Missing required argument -a <Arg[]>"
CALL FnEtcLogDebug %~n0 "SET Local_Error: !Local_Error!"


:: Local_Args becomes the list of arguments that are not known parameters
:: (basically remove known parameters from Local_AllArgs).
:: -- Matching is a whole token, not a substring, so removing "considera" no longer
:: --   eats the "considera" inside "consideraweb".
:: -- Each known parameter is consumed at most once, so an argument that repeats an
:: --   already consumed value (git commit -m considera) survives.
SET "Local_KnownCount=0"
FOR %%K IN (!Local_KnownParameters!) DO (
    SET "Local_KnownToken=%%~K"
    IF DEFINED Local_KnownToken (
        SET /A Local_KnownCount+=1
        SET "Local_Known_!Local_KnownCount!=%%~K"
        SET "Local_KnownUsed_!Local_KnownCount!="
    )
)

SET "Local_Args="
FOR %%T IN (!Local_AllArgs!) DO (
    SET "Local_Token=%%~T"
    SET "Local_Match="
    FOR /L %%I IN (1,1,!Local_KnownCount!) DO (
        IF NOT DEFINED Local_Match IF NOT DEFINED Local_KnownUsed_%%I IF /I "!Local_Known_%%I!"=="!Local_Token!" (
            SET "Local_KnownUsed_%%I=1"
            SET "Local_Match=1"
        )
    )
    IF NOT DEFINED Local_Match SET "Local_Args=!Local_Args! %%T"
)

:: Drop the separator the accumulator was built with, so Args starts on a token.
IF DEFINED Local_Args SET "Local_Args=!Local_Args:~1!"


:: One line, because the values are read out of the inner scope while the line is
:: parsed and written to the outer one once ENDLOCAL has run.
ENDLOCAL & SET "Output_FnEtcFlags_Args=%Local_Args%" & SET "Output_FnEtcFlags_Error=%Local_Error%"

IF DEFINED Output_FnEtcFlags_Error CALL FnEtcLogError FnEtcFlags "%Output_FnEtcFlags_Error%"
IF DEFINED Output_FnEtcFlags_Error EXIT /B 1

CALL FnEtcLogInfo FnEtcFlags "Outputted Args: %Output_FnEtcFlags_Args%"
CALL FnEtcLogDebug FnEtcFlags "SET Output_FnEtcFlags_Args: %Output_FnEtcFlags_Args%"
EXIT /B 0
