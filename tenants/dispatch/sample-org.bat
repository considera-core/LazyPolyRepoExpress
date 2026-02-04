@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion
SET "project=%~1"
SET "module=%~2"
SET "action=%~3"
SET "arg1=%~4"
SET "arg2=%~5"
IF "%project%"=="hello" (
    ECHO Hello, %USERNAME%. This is LazyPolyRepoExpress.
    ECHO   Usage: sample-org ^<project^> ^<module^> ^<action^> ^<arg1^> ^<arg2^>
    ECHO   Projects: ^(configured in tenants.csv^)
    ECHO   Modules: help, git, ai, app, ide, npm
    EXIT /B 0
)
IF /I "%project%"=="sample-tenant" (
    CALL sample-tenant "%module%" "%action%" "%arg1%" "%arg2%"
) ELSE (
    :: Shift args
    SET "arg2=%arg1%"
    SET "arg1=%action%"
    SET "action=%module%"
    SET "module=%project%"
    CALL sample-tenant "!module!" "!action!" "!arg1!" "!arg2!"
    EXIT /B 0
)
