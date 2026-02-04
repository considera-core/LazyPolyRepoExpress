@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion
:: The name of the App directory (/Tenant/...projects)
SET "Tenant=SampleTenant"
:: The name of the CSV key
SET "KEY=sample-tenant"
SET "module=%~1"
SET "action=%~2"
SET "arg1=%~3"
SET "arg2=%~4"
SET "arg3=%~5"
CALL fn-dispatch "%TENANT%" "%KEY%" "%module%" "%action%" "%arg1%" "%arg2%" "%arg3%"
IF ERRORLEVEL 1 EXIT /B 1