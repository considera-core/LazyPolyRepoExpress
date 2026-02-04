:: ================================================================
:: fn-findProjectByAlias ALIAS
:: Returns:
::   ERRORLEVEL 0 if found, (FOUND_NAME & FOUND_LABEL & FOUND_TYPE & FOUND_CLIENT & FOUND_SERVER & FOUND_HOME set)
::   ERRORLEVEL 1 if not found
:: ================================================================
@ECHO OFF
SET "FIND_ALIAS=%~1"
SET "FOUND_NAME="
SET "FOUND_LABEL="
SET "FOUND_TYPE="
SET "FOUND_CLIENT="
SET "FOUND_SERVER="
SET "FOUND_HOME="
FOR /L %%I IN (1,1,%REPO.COUNT%) DO (
  IF /I "!REPO.%%I.alias!"=="%FIND_ALIAS%" (
    SET "FOUND_NAME=!REPO.%%I.name!"
    SET "FOUND_LABEL=!REPO.%%I.label!"
    SET "FOUND_TYPE=!REPO.%%I.type!"
    SET "FOUND_CLIENT=!REPO.%%I.client!"
    SET "FOUND_SERVER=!REPO.%%I.server!"
    SET "FOUND_HOME=!REPO.%%I.home!"
  )
)
IF NOT DEFINED FOUND_NAME EXIT /B 1
EXIT /B 0