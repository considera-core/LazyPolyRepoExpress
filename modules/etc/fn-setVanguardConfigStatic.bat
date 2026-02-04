@ECHO OFF
SET "tenant=%~1"
SET "project=%~2"
ECHO 'vanguard-config static get VanguardPath %tenant%_%project%_RootBranch'
FOR /F "tokens=*" %%a IN ('vanguard-config static get %tenant%_%project%_RootBranch') DO SET "VANGUARD_CONFIG_STATIC_VALUE=%%a"