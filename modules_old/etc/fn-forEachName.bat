:: ==========================================================
:: fn-forEachName <tenant> <function> <arg1?> <arg2?> <arg3?>
:: ==========================================================
@ECHO OFF
SET "tenant=%~1"
SET "fn=%~2"
SET "arg1=%~3"
SET "arg2=%~4"
SET "arg3=%~5"
IF NOT DEFINED tenant (
  ECHO [ERROR] Missing tenant
  EXIT /B 1
)
IF NOT DEFINED fn (
  ECHO [ERROR] Missing function name
  EXIT /B 1
)
FOR /L %%I IN (1,1,%REPO.COUNT%) DO (
    CALL %fn% "%tenant%" "!REPO.%%I.name!" "%arg1%" "%arg2%" "%arg3%"
)
EXIT /B 0