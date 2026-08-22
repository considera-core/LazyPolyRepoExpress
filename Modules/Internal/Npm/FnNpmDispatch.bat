:: FnNpmDispatch --suite <SUITE> --action <ACTION> [--project <PROJECT>]
::               [-p <PROJECTS...>] [-a <ARGS...>] [FLAGS...]
:: -- Validates the action for the npm module and invokes the leaf function
:: --
:: --   FnNpm<Action> SUITE PROJECT ARGS... FLAGS...          (single project)
:: --   FnNpm<Action> SUITE ARGS... -p PROJECTS... FLAGS...   (selected projects)
:: --   FnNpm<Action> SUITE ARGS... FLAGS...                  (all projects)
:: --
:: -- which is the positional Function Schema from Docs.md. The leaf recurses on
:: -- itself via FnEtcForEachProject until it reaches the single project base case.

@ECHO OFF
:: No EnableDelayedExpansion: FnEtcFlags writes into this scope, and "!" inside a
:: passthrough arg would be eaten before the leaf function ever saw it.
SETLOCAL EnableExtensions

SET "M_MODULE=Npm"
SET "M_LABEL=npm"
:: <action>:<function suffix>
SET "M_ACTIONS=install:Install run:Run build:Build test:Test"

CALL FnEtcFlags %*
IF ERRORLEVEL 1 EXIT /B 1

SET "M_SUITE=%FLAG_SUITE%"
SET "M_ACTION=%FLAG_ACTION%"
SET "M_PROJECT=%FLAG_PROJECT%"
SET "M_PROJECTS=%FLAG_PROJECTS%"
SET "M_ARGS=%FLAG_ARGS%"
SET "M_FLAGS=%FLAG_PASSTHRU%"

IF NOT DEFINED M_SUITE GOTO :MISSING_SUITE
IF NOT DEFINED M_ACTION GOTO :MISSING_ACTION

SET "M_SUFFIX="
FOR %%A IN (%M_ACTIONS%) DO FOR /F "tokens=1,2 delims=:" %%X IN ("%%A") DO IF /I "%%X"=="%M_ACTION%" SET "M_SUFFIX=%%Y"
IF NOT DEFINED M_SUFFIX GOTO :UNKNOWN_ACTION

SET "M_FN=Fn%M_MODULE%%M_SUFFIX%"

SET "M_PROJECT_ARG="
IF DEFINED M_PROJECT SET "M_PROJECT_ARG="%M_PROJECT%""
SET "M_PROJECTS_FLAG="
IF DEFINED M_PROJECTS SET "M_PROJECTS_FLAG=-p %M_PROJECTS%"

:: Under -d the leaf is still called, with -d passed through, so a dry run
:: previews the real fan out. Only when the leaf does not exist yet does this
:: layer report on its behalf, which is what keeps the grammar testable ahead of
:: the leaves being written.
IF NOT DEFINED FLAG_DRY_RUN GOTO :INVOKE
IF NOT EXIST "%~dp0%M_FN%.bat" GOTO :EMIT

:INVOKE
    CALL %M_FN% "%M_SUITE%" %M_PROJECT_ARG% %M_ARGS% %M_PROJECTS_FLAG% %M_FLAGS%
    EXIT /B %ERRORLEVEL%

:EMIT
    ECHO LPRE:EXEC fn=%M_FN% suite=%M_SUITE% project=%M_PROJECT% args=%M_ARGS% projects=%M_PROJECTS% flags=%M_FLAGS%
    EXIT /B 0

:MISSING_SUITE
    ECHO LeprechaunCLI:FnNpmDispatch[E]: Missing required flag --suite ^<SUITE^>
    GOTO :USAGE

:MISSING_ACTION
    ECHO LeprechaunCLI:FnNpmDispatch[E]: Missing action
    GOTO :USAGE

:UNKNOWN_ACTION
    ECHO LeprechaunCLI:FnNpmDispatch[E]: Unknown npm action "%M_ACTION%"
    GOTO :USAGE

:USAGE
    ECHO   Usage: ^<SUITE^> npm ^<ACTION^> ^<ARGS...^> ^<FLAGS...^>
    ECHO          ^<SUITE^> ^<PROJECT^> npm ^<ACTION^> ^<ARGS...^>
    ECHO          ^<SUITE^> npm ^<ACTION^> -p ^<PROJECTS...^>
    ECHO   Actions: install run build test
    EXIT /B 1
