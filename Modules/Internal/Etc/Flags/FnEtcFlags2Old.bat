:: FnEtcFlags2 -p <KnownParameter[]> -a <Arg[]>
:: -- Will extract all flags and arguments excluding the known parameters, and return them in the caller's scope.
:: --
:: -- -p declares the parameters that take a value. An entry is either "short" or
:: --    "short:long", and every flag is keyed by its SHORT name, so -o and --org
:: --    both land in Output_FnEtcFlags_Flag_o:
:: --      CALL FnEtcFlags2 -p o:org s:suite p:project -a %*
:: -- -a is the line to parse, and must come last. Every token after it is data,
:: --    so an argument is free to be "-a" or "-p" itself.
:: --
:: -- A token in <Arg[]> is exactly one of three things:
:: --   the value of the parameter before it   -o considera  -> Flag_o=considera
:: --   a flag, if it starts with a dash       -v --dry-run  -> Flag_v=1 Flag_dryrun=1
:: --   a positional argument                  api bff       -> Arg_1=api Arg_2=bff
:: -- A declared parameter takes the next token verbatim, dash or not, so a value
:: -- is never mistaken for the flag that follows it. Undeclared flags are always
:: -- boolean, which is what "excluding the known parameters" buys: the values of
:: -- known parameters are lifted out and never counted as arguments.
:: --
:: -- Outputs, all cleared at the top of every call:
:: --   Output_FnEtcFlags_Flag_<short>   one variable per flag, a bare flag is 1
:: --   Output_FnEtcFlags_Arg_<index>    one variable per positional, 1 based
:: --   Output_FnEtcFlags_ArgCount       how many Arg_<index> there are
:: --   Output_FnEtcFlags_Flags          -o considera -v, canonical short form
:: --   Output_FnEtcFlags_Args           api bff, quoted as the caller wrote it
:: --   Output_FnEtcFlags_FlagPairs      "o=considera" "v=1"
:: --   Output_FnEtcFlags_ArgPairs       "1=api" "2=bff"
:: --   Output_FnEtcFlags_Error          set only on failure, alongside EXIT /B 1
:: --
:: -- Flags and Args are the transfer forms. They hand the line down a level with
:: -- the split already made, and re-parse to themselves:
:: --   CALL FnFooBar %Output_FnEtcFlags_Args% %Output_FnEtcFlags_Flags%
:: -- The pair forms are the tracking forms. They carry every individual variable
:: -- in one token each, so a scope that did not parse can rebuild the whole set
:: -- in one line, with no counter and no second call to this script:
:: --   FOR %%F IN (%Output_FnEtcFlags_FlagPairs%) DO SET "Output_FnEtcFlags_Flag_%%~F"
:: --   FOR %%A IN (%Output_FnEtcFlags_ArgPairs%) DO SET "Output_FnEtcFlags_Arg_%%~A"
:: --
:: -- NOTE: The outputs are written into the CALLER's scope, so the caller is the
:: --       one that has to SETLOCAL if it wants them scoped. A nested parse
:: --       overwrites them, so a caller that parses again mid-scan must snapshot
:: --       what it still needs first.
:: -- NOTE: <Arg[]> is walked with a plain FOR rather than SHIFT, which is what
:: --       keeps this file free of labels. That borrows cmd's set tokenizer, so
:: --       an unquoted token splits on "=", "," and ";" as well as space, and a
:: --       token holding "*" or "?" expands against the current directory when
:: --       it matches a file. Quote such a value at the call site.
:: -- NOTE: Parsing runs under delayed expansion, which eats "!" inside a token.


:: EX: FnEtcFlags2 -p considera consideraweb -a considera consideraweb git branch -V

@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

SET "DEBUG=1"

FOR /F "delims==" %%V IN ('SET Output_FnEtcFlags_ 2^>NUL') DO SET "%%V="
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Output_FnEtcFlags_: NULL"

SET "Local_Mode="
SET "Local_Pending="
SET "Local_KnownParameters="
SET "Local_AllArgs="
SET "Local_Args="
SET "Local_Flags="
SET "Local_ArgCount=0"
SET "Local_Error="

IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_Mode: !Local_Mode!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_Pending: !Local_Pending!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_KnownParameters: !Local_KnownParameters!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_AllArgs: !Local_AllArgs!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_Args: !Local_Args!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_ArgCount: !Local_ArgCount!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_Error: !Local_Error!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "LOOP START"

FOR %%T IN (%*) DO (
    SET "Local_Token=%%~T"
    IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "- SET Local_Token: !Local_Token!"
    
    IF NOT DEFINED Local_Mode (
        IF /I "!Local_Token!"=="-p" SET "Local_Mode=KnownParameters"
        IF /I "!Local_Token!"=="-a" SET "Local_Mode=AllArgs"
        IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "-- [UNDEFINED] SET Local_Mode: !Local_Mode!"
    ) ELSE IF "!Local_Mode!"=="KnownParameters" (
        IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "-- [KNOWN]"

        IF /I "!Local_Token!"=="-a" (
            SET "Local_Mode=AllArgs"
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "--- [KNOWN] SET Local_Mode: AllArgs"
        ) ELSE (
            SET "Local_KnownParameters=!Local_KnownParameters! %%T"
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "--- [KNOWN] SET Local_KnownParameters: !Local_KnownParameters!"
        )
    ) ELSE (
        IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "-- [ARG]"

        SET "Local_Name="
        IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "--- [ARG] SET Local_Name: !Local_Name!"

        IF "!Local_Token:~0,2!"=="--" SET "Local_Name=!Local_Token:~2!"
        IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "--- [ARG] SET Local_Name: !Local_Name!"

        IF NOT "!Local_Token:~0,2!"=="--" IF "!Local_Token:~0,1!"=="-" SET "Local_Name=!Local_Token:~1!"
        IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "--- [ARG] SET Local_Name: !Local_Name!"

        IF DEFINED Local_Name SET "Local_Name=!Local_Name:-=!"
        IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "--- [ARG] SET Local_Name: !Local_Name!"

        IF DEFINED Local_Pending (
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "--- [ARG] [PENDING]"

            SET "Local_FlagPairs=!Local_FlagPairs! !Local_Pending!^=!Local_Token!"
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "---- [ARG] [PENDING] SET Local_FlagPairs: !Local_FlagPairs!"

            SET "Local_Flags=!Local_Flags! -!Local_Pending! %%T"
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "---- [ARG] [PENDING] SET Local_Flags: !Local_Flags!"

            SET "Local_Pending="
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "---- [ARG] [PENDING] SET Local_Pending: !Local_Pending!"

        ) ELSE IF DEFINED Local_Name (
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "--- [ARG] [NAME]"

            REM The inner FOR is what makes Local_Param_<name> readable by a name
            REM that is only known at run time.
            SET "Local_Short="
            FOR /F "delims=" %%N IN ("!Local_Name!") DO SET "Local_Short=!Local_Param_%%N!"
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "---- [ARG] [NAME] SET Local_Short: !Local_Short!"

            IF DEFINED Local_Short (
                SET "Local_Pending=!Local_Short!"
                IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "----- [ARG] [NAME] SET Local_Pending: !Local_Pending!"
            ) ELSE (
                SET "Local_FlagPairs=!Local_FlagPairs! !Local_Name!^=1"
                IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "----- [ARG] [NAME] SET Local_FlagPairs: !Local_FlagPairs!"
                SET "Local_Flags=!Local_Flags! -!Local_Name!"
                IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "----- [ARG] [NAME] SET Local_Flags: !Local_Flags!"
            )

        ) ELSE (
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "--- [ARG] [POSITIONAL]"

            SET /A Local_ArgCount+=1
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "---- [ARG] [POSITIONAL] SET Local_ArgCount: !Local_ArgCount!"

            SET "Local_ArgPairs=!Local_ArgPairs! !Local_ArgCount!^=!Local_Token!"
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "---- [ARG] [POSITIONAL] SET Local_ArgPairs: !Local_ArgPairs!"

            SET "Local_Args=!Local_Args! %%T"
            IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "---- [ARG] [POSITIONAL] SET Local_Args: !Local_Args!"
        )
    )
)

IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "- LOOP RES START"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "-- SET Local_Mode: !Local_Mode!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "-- SET Local_Pending: !Local_Pending!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "-- SET Local_Flags: !Local_Flags!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "-- SET Local_FlagPairs: !Local_FlagPairs!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "-- SET Local_Args: !Local_Args!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "-- SET Local_ArgPairs: !Local_ArgPairs!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "-- SET Local_ArgCount: !Local_ArgCount!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "-- SET Local_Error: !Local_Error!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "- LOOP RES END"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "LOOP END"

IF NOT "!Local_Mode!"=="Arguments" SET "Local_Error=Missing required argument -a <Arg[]>"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_Error: !Local_Error!"

IF DEFINED Local_Pending SET "Local_Error=Parameter -!Local_Pending! is missing its value"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_Error: !Local_Error!"

:: Drop the separator every accumulator was built with, so each one starts on a
:: token and iterates cleanly.
IF DEFINED Local_Flags SET "Local_Flags=!Local_Flags:~1!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_Flags: !Local_Flags!"

IF DEFINED Local_FlagPairs SET "Local_FlagPairs=!Local_FlagPairs:~1!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_FlagPairs: !Local_FlagPairs!"

IF DEFINED Local_Args SET "Local_Args=!Local_Args:~1!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_Args: !Local_Args!"

IF DEFINED Local_ArgPairs SET "Local_ArgPairs=!Local_ArgPairs:~1!"
IF DEFINED DEBUG CALL FnEtcLogDebug FnEtcFlags2 "SET Local_ArgPairs: !Local_ArgPairs!"

:: One line, because the values are read out of the inner scope while the line is
:: parsed and written to the outer one once ENDLOCAL has run.
ENDLOCAL & SET "Output_FnEtcFlags_Flags=%Local_Flags%" & SET "Output_FnEtcFlags_FlagPairs=%Local_FlagPairs%" & SET "Output_FnEtcFlags_Args=%Local_Args%" & SET "Output_FnEtcFlags_ArgPairs=%Local_ArgPairs%" & SET "Output_FnEtcFlags_Error=%Local_Error%"

:: Each pair is already "<name>=<value>", so SET takes it whole and the index
:: never has to be counted twice.
SET "Output_FnEtcFlags_ArgCount=0"
FOR %%F IN (%Output_FnEtcFlags_FlagPairs%) DO SET "Output_FnEtcFlags_Flag_%%~F"
FOR %%A IN (%Output_FnEtcFlags_ArgPairs%) DO ( SET "Output_FnEtcFlags_Arg_%%~A" & SET /A Output_FnEtcFlags_ArgCount+=1 )

IF DEFINED Output_FnEtcFlags_Error CALL FnEtcLogError FnEtcFlags2 "%Output_FnEtcFlags_Error%"
IF DEFINED Output_FnEtcFlags_Error EXIT /B 1
EXIT /B 0
