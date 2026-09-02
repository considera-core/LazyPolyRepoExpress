:: FnEtcFlags <Arg[]>
:: leprechaun function flags <Arg[]>
:: -- Converts a leprechaun command line into flag variables in the CALLER's scope.
:: --
:: -- Flag classes:
:: --   LIST    (LPRE_LIST_FLAGS)  consume tokens until the next -flag or end of line
:: --     -p api bff   -> GLOBAL_FlagProjects=api bff  GLOBAL_FlagProjectsCount=2
:: --                     GLOBAL_FlagProjects1=api     GLOBAL_FlagProjects2=bff
:: --   VALUE   (LPRE_VALUE_FLAGS) consume exactly the next token
:: --     --org considera -> GLOBAL_FlagOrg=considera
:: --   BOOLEAN (everything else) set to 1 and appended to GLOBAL_FlagPassthru
:: --     -v -d        -> GLOBAL_FlagVerbose=1 GLOBAL_FlagDryRun=1
:: --
:: -- Positional args:
:: --   GLOBAL_FlagArgc     -> count of positional args
:: --   GLOBAL_FlagArg1..N  -> each positional arg
:: --
:: -- Two namespaces are written for every flag. GLOBAL_Flag<Name> is the one the
:: -- dispatch chain reads; FLAG_<NAME> is kept for the external dispatcher, which
:: -- still reads the older names. Batch variable names are case insensitive and
:: -- the GLOBAL_ form drops separators, so --dry-run sets GLOBAL_Flagdryrun and a
:: -- caller may read it as GLOBAL_FlagDryRun.
:: --
:: -- NOTE: This script deliberately does NOT call SETLOCAL. cmd.exe runs an
:: --       implicit ENDLOCAL when a batch file returns, which would discard
:: --       every flag variable this script exists to produce. Callers are
:: --       expected to SETLOCAL themselves so the flags stay scoped to them.
:: -- NOTE: Callers should NOT enable delayed expansion, or "!" inside an
:: --       argument value is eaten before this script ever sees the value.

@ECHO OFF

IF NOT DEFINED LPRE_LIST_FLAGS SET "LPRE_LIST_FLAGS=projects args"
IF NOT DEFINED LPRE_VALUE_FLAGS SET "LPRE_VALUE_FLAGS=org suite project module action entry env fn id org_id suite_id"
IF NOT DEFINED LPRE_FLAG_ALIASES SET "LPRE_FLAG_ALIASES=p:projects a:args o:org s:suite m:module e:entry v:verbose d:dry_run i:id r:refresh"

:: Clear both namespaces left over from any previous call in this scope.
FOR /F "delims==" %%V IN ('SET FLAG_ 2^>NUL') DO SET "%%V="
FOR /F "delims==" %%V IN ('SET GLOBAL_Flag 2^>NUL') DO SET "%%V="
SET "FLAG_ARGC=0"
SET "FLAG_PASSTHRU="
SET "GLOBAL_FlagArgc=0"
SET "GLOBAL_FlagPassthru="

:PARSE
    :: [%1] rather than "%~1": a literal "" argument must not read as end-of-args,
    :: and it keeps its quotes under %1, so [""] is correctly not equal to [].
    IF [%1]==[] GOTO :PARSE_DONE

    SET "LPRE_TOKEN=%~1"
    IF NOT DEFINED LPRE_TOKEN GOTO :PARSE_POSITIONAL
    IF "%LPRE_TOKEN:~0,2%"=="--" GOTO :PARSE_LONG
    IF "%LPRE_TOKEN:~0,1%"=="-" GOTO :PARSE_SHORT
    GOTO :PARSE_POSITIONAL

:PARSE_LONG
    SET "LPRE_KEY=%LPRE_TOKEN:~2%"
    GOTO :PARSE_FLAG

:PARSE_SHORT
    SET "LPRE_KEY=%LPRE_TOKEN:~1%"
    GOTO :PARSE_FLAG

:PARSE_FLAG
    :: A bare "-" or "--" is not a flag.
    IF NOT DEFINED LPRE_KEY GOTO :PARSE_POSITIONAL
    SET "LPRE_KEY=%LPRE_KEY:-=_%"
    CALL :CANONICALIZE "%LPRE_KEY%"
    SET "LPRE_KEY=%LPRE_CANON%"
    :: GLOBAL_Flag names carry no separators, so --dry-run and DryRun agree.
    SET "LPRE_GKEY=%LPRE_KEY:_=%"

    CALL :IS_LISTED "%LPRE_KEY%" "%LPRE_LIST_FLAGS%"
    IF NOT ERRORLEVEL 1 GOTO :PARSE_LIST

    CALL :IS_LISTED "%LPRE_KEY%" "%LPRE_VALUE_FLAGS%"
    IF NOT ERRORLEVEL 1 GOTO :PARSE_VALUE

    SET "FLAG_%LPRE_KEY%=1"
    SET "GLOBAL_Flag%LPRE_GKEY%=1"
    SET "FLAG_PASSTHRU=%FLAG_PASSTHRU% %LPRE_TOKEN%"
    SET "GLOBAL_FlagPassthru=%GLOBAL_FlagPassthru% %LPRE_TOKEN%"
    SHIFT
    GOTO :PARSE

:PARSE_VALUE
    SHIFT
    IF [%1]==[] GOTO :MISSING_VALUE
    SET "FLAG_%LPRE_KEY%=%~1"
    SET "GLOBAL_Flag%LPRE_GKEY%=%~1"
    SHIFT
    GOTO :PARSE

:PARSE_LIST
    SET "LPRE_LIST_KEY=%LPRE_KEY%"
    SET "LPRE_LIST_GKEY=%LPRE_GKEY%"
    SET "LPRE_LIST_VALUE="
    SET "LPRE_LIST_N=0"

:PARSE_LIST_LOOP
    SHIFT
    IF [%1]==[] GOTO :PARSE_LIST_STORE
    SET "LPRE_PEEK=%~1"
    IF NOT DEFINED LPRE_PEEK GOTO :PARSE_LIST_STORE
    :: A list stops at the next flag, so "-p api bff -v" gives exactly two projects.
    IF "%LPRE_PEEK:~0,1%"=="-" GOTO :PARSE_LIST_STORE
    SET /A LPRE_LIST_N+=1
    SET "FLAG_%LPRE_LIST_KEY%_%LPRE_LIST_N%=%~1"
    SET "GLOBAL_Flag%LPRE_LIST_GKEY%%LPRE_LIST_N%=%~1"
    SET "LPRE_LIST_VALUE=%LPRE_LIST_VALUE% %~1"
    GOTO :PARSE_LIST_LOOP

:PARSE_LIST_STORE
    IF "%LPRE_LIST_N%"=="0" GOTO :MISSING_LIST_VALUE
    :: Drop the leading separator space so the joined form iterates cleanly.
    SET "LPRE_LIST_VALUE=%LPRE_LIST_VALUE:~1%"
    SET "FLAG_%LPRE_LIST_KEY%=%LPRE_LIST_VALUE%"
    SET "FLAG_%LPRE_LIST_KEY%_COUNT=%LPRE_LIST_N%"
    SET "GLOBAL_Flag%LPRE_LIST_GKEY%=%LPRE_LIST_VALUE%"
    SET "GLOBAL_Flag%LPRE_LIST_GKEY%Count=%LPRE_LIST_N%"
    GOTO :PARSE

:PARSE_POSITIONAL
    SET /A FLAG_ARGC+=1
    SET /A GLOBAL_FlagArgc+=1
    SET "FLAG_ARG_%FLAG_ARGC%=%~1"
    SET "GLOBAL_FlagArg%GLOBAL_FlagArgc%=%~1"
    SHIFT
    GOTO :PARSE

:MISSING_VALUE
    CALL FnEtcLogError FnEtcFlags "Missing value for flag %LPRE_KEY%"
    CALL :CLEANUP
    EXIT /B 1

:MISSING_LIST_VALUE
    CALL FnEtcLogError FnEtcFlags "Flag %LPRE_LIST_KEY% requires at least one value"
    CALL :CLEANUP
    EXIT /B 1

:PARSE_DONE
    IF DEFINED FLAG_PASSTHRU SET "FLAG_PASSTHRU=%FLAG_PASSTHRU:~1%"
    IF DEFINED GLOBAL_FlagPassthru SET "GLOBAL_FlagPassthru=%GLOBAL_FlagPassthru:~1%"
    CALL :CLEANUP
    EXIT /B 0

:CANONICALIZE
    :: Maps a short flag name onto its long name; unknown names pass through.
    SET "LPRE_CANON=%~1"
    FOR %%A IN (%LPRE_FLAG_ALIASES%) DO FOR /F "tokens=1,2 delims=:" %%X IN ("%%A") DO IF /I "%%X"=="%~1" SET "LPRE_CANON=%%Y"
    EXIT /B 0

:IS_LISTED
    FOR %%K IN (%~2) DO IF /I "%%K"=="%~1" EXIT /B 0
    EXIT /B 1

:CLEANUP
    SET "LPRE_TOKEN="
    SET "LPRE_KEY="
    SET "LPRE_GKEY="
    SET "LPRE_CANON="
    SET "LPRE_PEEK="
    SET "LPRE_LIST_KEY="
    SET "LPRE_LIST_GKEY="
    SET "LPRE_LIST_VALUE="
    SET "LPRE_LIST_N="
    EXIT /B 0
