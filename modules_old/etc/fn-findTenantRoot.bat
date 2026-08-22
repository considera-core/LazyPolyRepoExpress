:: ================================================================
:: fn-findTenantRoot ALIAS
:: Returns:
::   ERRORLEVEL 0 if found, (FOUND_TENANT_DISPLAY & SELECTED_TENANT_ROOT)
::   ERRORLEVEL 1 if not found
:: ================================================================
@ECHO OFF
SET "FIND_ALIAS=%~1"
SET "FOUND_TENANT_DISPLAY="
SET "SELECTED_TENANT_ROOT="
FOR /L %%I IN (1,1,%TENANT.COUNT%) DO (
  IF /I "!TENANT.%%I.alias!"=="%FIND_ALIAS%" (
    SET "FOUND_TENANT_DISPLAY=!TENANT.%%I.display!"
    SET "SELECTED_TENANT_ROOT=!TENANT.%%I.root!"
  )
)
IF NOT DEFINED FOUND_TENANT_DISPLAY EXIT /B 1
IF NOT DEFINED SELECTED_TENANT_ROOT EXIT /B 1
EXIT /B 0