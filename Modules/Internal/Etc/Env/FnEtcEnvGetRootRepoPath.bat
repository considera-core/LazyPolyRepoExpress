:: FnEtcEnvGetRootRepoPath
:: -- Gets the root repo path from the config and sets it to ROOT_REPO_PATH

@ECHO OFF

FOR /F "tokens=*" %%a IN ('fn-config get RootRepoPath') DO SET "ROOT_REPO_PATH=%%a"
IF ERRORLEVEL 1 EXIT /B 1

EXIT /B 0