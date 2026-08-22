:: ==================
:: fn-setRepoRootPath
:: ==================
@ECHO OFF
FOR /F "tokens=*" %%a IN ('fn-config get VanguardPath') DO SET "REPO_ROOT_PATH=%%a"