:: FnExternalBootstrapShortcuts [--clean] [-v]
:: -- Regenerates <root>\Bin as one flat directory holding a forwarder for every
:: -- batch script in the Dispatch and Modules trees. Add Bin to PATH and the
:: -- whole command surface resolves by name from anywhere, replacing the
:: -- per-directory symlinks install.ps1 pushes onto PATH today.
:: --
:: -- The namespace is the script's base name, which already encodes it by the
:: -- Naming convention in Docs.md (Fn + Module + Action, PascalCase). The root
:: -- entry point Dispatch\Leprechaun.bat therefore lands as Leprechaun.bat.
:: --
:: -- Forwarders are .bat, not .lnk: cmd.exe resolves a bare command name off
:: -- PATH through PATHEXT, which never contains .LNK, so a Windows shortcut
:: -- sitting on PATH is not callable. A forwarder is, and it CALLs the real
:: -- script at its real path, so %~dp0 inside that script still resolves to its
:: -- own module directory rather than to Bin.
:: --
:: -- Forwarders deliberately do NOT SETLOCAL. CALL does not open a variable
:: -- scope, so readers like FnEtcCsvOrgs that export LPRE_* into their caller
:: -- keep working across the hop; a SETLOCAL here would discard exactly what
:: -- they exist to produce.
:: --
:: -- Every generated file carries the LPRE-GENERATED-SHIM marker on line 2.
:: -- Only marked files are ever rewritten or removed, so anything hand written
:: -- in Bin survives, and a renamed or deleted module does not leave a stale
:: -- command behind.
:: --
:: -- NOTE: Flags are parsed inline rather than through FnEtcFlags. This script
:: --       is what puts FnEtcFlags on PATH in the first place, so it cannot
:: --       depend on resolving a sibling module by name.

@ECHO OFF
SETLOCAL EnableExtensions

:: Resolved before the flag loop below, because SHIFT moves %0 along with the
:: rest of the arguments and %~dp0 stops naming this script after the first one.
:: <root>\Modules\External\Bootstrap\ -> <root>
FOR %%I IN ("%~dp0..\..\..") DO SET "SC_ROOT=%%~fI"
SET "SC_BIN=%SC_ROOT%\Bin"

SET "SC_CLEAN=0"
SET "SC_VERBOSE=0"
SET "SC_RC=0"
SET "SC_WRITTEN=0"
SET "SC_REMOVED=0"

:PARSE
    IF "%~1"=="" GOTO PARSED
    IF /I "%~1"=="--clean"   SET "SC_CLEAN=1"   & SHIFT & GOTO PARSE
    IF /I "%~1"=="-v"        SET "SC_VERBOSE=1" & SHIFT & GOTO PARSE
    IF /I "%~1"=="--verbose" SET "SC_VERBOSE=1" & SHIFT & GOTO PARSE
    ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[E]: unknown flag "%~1"
    EXIT /B 1
:PARSED

IF NOT EXIST "%SC_ROOT%\Dispatch" (
    ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[E]: Dispatch directory not found at %SC_ROOT%\Dispatch
    EXIT /B 1
)
IF NOT EXIST "%SC_ROOT%\Modules" (
    ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[E]: Modules directory not found at %SC_ROOT%\Modules
    EXIT /B 1
)

IF NOT EXIST "%SC_BIN%" MD "%SC_BIN%"
IF NOT EXIST "%SC_BIN%" (
    ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[E]: could not create %SC_BIN%
    EXIT /B 1
)

:: Drop every previously generated forwarder first, so the directory always
:: mirrors the trees exactly rather than accumulating renamed commands.
FOR %%F IN ("%SC_BIN%\*.bat") DO CALL :SWEEP "%%~fF"

IF "%SC_CLEAN%"=="1" (
    ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[I]: removed %SC_REMOVED% shortcut^(s^) from %SC_BIN%
    EXIT /B %SC_RC%
)

FOR /R "%SC_ROOT%\Dispatch" %%F IN (*.bat) DO CALL :EMIT "%%~fF"
FOR /R "%SC_ROOT%\Modules"  %%F IN (*.bat) DO CALL :EMIT "%%~fF"

ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[I]: wrote %SC_WRITTEN% shortcut^(s^) to %SC_BIN%
ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[I]: add %SC_BIN% to PATH
EXIT /B %SC_RC%

:: SWEEP <file> -- delete one Bin entry if it is a forwarder we generated.
:SWEEP
    FINDSTR /X /C:":: LPRE-GENERATED-SHIM" "%~1" >NUL 2>&1 || EXIT /B 0
    DEL /Q "%~1" >NUL 2>&1
    IF EXIST "%~1" (
        ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[E]: could not remove %~1
        SET "SC_RC=1"
        EXIT /B 0
    )
    SET /A SC_REMOVED+=1
    IF "%SC_VERBOSE%"=="1" ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[I]: removed %~nx1
    EXIT /B 0

:: EMIT <file> -- write Bin\<namespace>.bat forwarding to one module script.
:EMIT
    SET "SC_TARGET=%~1"
    SET "SC_NAME=%~n1"
    SET "SC_SHIM=%SC_BIN%\%SC_NAME%.bat"

    :: Two scripts claiming one namespace would make the winner depend on scan
    :: order, so refuse both rather than silently shadowing one.
    IF DEFINED SC_SEEN_%SC_NAME% (
        ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[E]: namespace "%SC_NAME%" is claimed twice, second is %SC_TARGET%
        SET "SC_RC=1"
        EXIT /B 0
    )
    SET "SC_SEEN_%SC_NAME%=1"

    :: SWEEP has already cleared our own output, so anything still here is a
    :: hand written command that happens to share the name.
    IF EXIST "%SC_SHIM%" (
        ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[E]: %SC_SHIM% is not generated, leaving it alone
        SET "SC_RC=1"
        EXIT /B 0
    )

    (
        ECHO :: %SC_NAME% -^> %SC_TARGET%
        ECHO :: LPRE-GENERATED-SHIM
        ECHO :: -- Generated by FnExternalBootstrapShortcuts. Do not edit; edit the
        ECHO :: -- target above and rerun. No SETLOCAL here on purpose, so scripts
        ECHO :: -- that export into their caller still do.
        ECHO.
        ECHO @ECHO OFF
        ECHO CALL "%SC_TARGET%" %%*
        ECHO EXIT /B %%ERRORLEVEL%%
    ) >"%SC_SHIM%"

    IF NOT EXIST "%SC_SHIM%" (
        ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[E]: could not write %SC_SHIM%
        SET "SC_RC=1"
        EXIT /B 0
    )

    SET /A SC_WRITTEN+=1
    IF "%SC_VERBOSE%"=="1" ECHO LeprechaunCLI:FnExternalBootstrapShortcuts[I]: %SC_NAME% -^> %SC_TARGET%
    EXIT /B 0
