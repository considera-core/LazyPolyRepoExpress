@ECHO OFF
FOR /F "tokens=*" %%a IN ('fn-config get RootRepoPath') DO SET "LPRE_REPO_PATH=%%a"