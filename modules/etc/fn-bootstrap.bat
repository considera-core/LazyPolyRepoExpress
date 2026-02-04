:: =====================
:: fn-bootstrap <tenant>
:: =====================
@ECHO OFF
SET "tenantName=%~1"
CALL fn-setLPRERepoPath
IF ERRORLEVEL 1 EXIT /B 1
SET "tenantCSV=%LPRE_REPO_PATH%\tenants\data\%tenantName%.csv"
IF NOT EXIST "%tenantCSV%" (
    ECHO [ERROR] %tenantName%.csv not found at %tenantCSV%
    EXIT /B 1
)
SET "tenantsCSV=%LPRE_REPO_PATH%\tenants\data\tenants.csv"
IF NOT EXIST "%tenantsCSV%" (
    ECHO [ERROR] tenants.csv not found at %tenantsCSV%
    EXIT /B 1
)
FOR /F "delims==" %%V IN ('set REPO. 2^>nul') DO SET "%%V="
FOR /F "delims==" %%V IN ('set TENANT. 2^>nul') DO SET "%%V="

SET "TENANT.COUNT=0"
FOR /F "usebackq tokens=1-3 delims=, eol=#" %%A IN ("%tenantsCSV%") DO (
    IF /I "%%A"=="alias" (
        REM Skip header
    ) ELSE (
        IF /I "%%A"=="%tenantName%" (
            SET /A TENANT.COUNT+=1
            SET "i=!TENANT.COUNT!"
            SET "TENANT.!i!.alias=%%A"
            SET "TENANT.!i!.display=%%B"
            SET "TENANT.!i!.root=%%C"
        )
    )
)
IF "%TENANT.COUNT%"=="0" (
    ECHO [ERROR] No tenants parsed from %tenantsCSV%
    EXIT /B 1
)

SET "REPO.COUNT=0"
FOR /F "usebackq tokens=1-7 delims=, eol=#" %%A IN ("%tenantCSV%") DO (
    IF /I "%%A"=="alias" (
        REM Skip header
    ) ELSE (
        SET /A REPO.COUNT+=1
        SET "i=!REPO.COUNT!"
        SET "REPO.!i!.alias=%%A"
        SET "REPO.!i!.name=%%B"
        SET "REPO.!i!.label=%%C"
        SET "REPO.!i!.type=%%D"
        SET "REPO.!i!.client=%%E"
        SET "REPO.!i!.server=%%F"
        SET "REPO.!i!.home=%%G"
    )
)
IF "%REPO.COUNT%"=="0" (
    ECHO [ERROR] No repos parsed from %tenantCSV%
    EXIT /B 1
)
EXIT /B 0