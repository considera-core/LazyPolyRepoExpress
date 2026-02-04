:: =====================
:: fn-bootstrap <tenant>
:: =====================
@ECHO OFF
SET "tenantName=%~1"
CALL fn-setRepoRootPath
IF ERRORLEVEL 1 EXIT /B 1
CALL fn-setHelperToolsPath
IF ERRORLEVEL 1 EXIT /B 1
SET "CSV=%HELPER_TOOLS_PATH%\tenants\%tenantName%.csv"
IF NOT EXIST "%CSV%" (
    ECHO [ERROR] %tenantName%.csv not found at %CSV%
    EXIT /B 1
)
FOR /F "delims==" %%V IN ('set REPO. 2^>nul') DO SET "%%V="
SET "REPO.COUNT=0"
FOR /F "usebackq tokens=1-4 delims=, eol=#" %%A IN ("%CSV%") DO (
    IF /I "%%A"=="alias" (
        REM Skip header
    ) ELSE (
        SET /A REPO.COUNT+=1
        SET "i=!REPO.COUNT!"
        SET "REPO.!i!.alias=%%A"
        SET "REPO.!i!.name=%%B"
        SET "REPO.!i!.label=%%C"
        SET "REPO.!i!.type=%%D"
    )
)
IF "%REPO.COUNT%"=="0" (
    ECHO [ERROR] No repos parsed from %CSV%
    EXIT /B 1
)
EXIT /B 0