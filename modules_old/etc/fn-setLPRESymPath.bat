@ECHO OFF
FOR /F "tokens=*" %%a IN ('fn-config get RootSymLinksPath') DO SET "LPRE_SYM_PATH=%%a"