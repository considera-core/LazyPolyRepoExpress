:: ================================================================
:: fn-findProjectByAlias ALIAS
:: Returns:
::   ERRORLEVEL 0 if found, (FOUND_NAME & FOUND_LABEL & FOUND_TYPE)
::   ERRORLEVEL 1 if not found
:: ================================================================
@ECHO OFF
SET "FIND_ALIAS=%~1"
SET "FOUND_NAME="
SET "FOUND_LABEL="
SET "FOUND_TYPE="
FOR /L %%I IN (1,1,%REPO.COUNT%) DO (
  IF /I "!REPO.%%I.alias!"=="%FIND_ALIAS%" (
    SET "FOUND_NAME=!REPO.%%I.name!"
    SET "FOUND_LABEL=!REPO.%%I.label!"
    SET "FOUND_TYPE=!REPO.%%I.type!"
  )
)
IF NOT DEFINED FOUND_NAME EXIT /B 1
EXIT /B 0