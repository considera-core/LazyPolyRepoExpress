@ECHO OFF
FOR /F "tokens=*" %%a IN ('vanguard-config get HelperToolsPath') DO SET "HELPER_TOOLS_PATH=%%a"