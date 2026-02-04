:: ========================================================================
:: fn-forEachAliasByType <type> <tenant> <function> <arg1?> <arg2?> <arg3?>
:: ========================================================================
@ECHO OFF
SET "type=%~1"
SET "tenant=%~2"
SET "fn=%~3"
SET "arg1=%~4"
SET "arg2=%~5"
SET "arg3=%~6"
IF NOT DEFINED type (
  ECHO [ERROR] Missing type
  EXIT /B 1
)
IF NOT DEFINED tenant (
  ECHO [ERROR] Missing tenant
  EXIT /B 1
)
IF NOT DEFINED fn (
  ECHO [ERROR] Missing function name
  EXIT /B 1
)
FOR /L %%I IN (1,1,%REPO.COUNT%) DO (
  IF /I "!REPO.%%I.type!"=="%type%" (
    CALL %fn% "%tenant%" "!REPO.%%I.alias!" "%arg1%" "%arg2%" "%arg3%"
  )
)
EXIT /B 0