
SET "Input_FrameworkId=%GLOBAL_FlagArg1%"

IF /I "%Input_FrameworkId%"=="dotnet" (
    PUSHD "%Output_Resolved_ProjectRootPath%"
    CALL dotnet watch 
    POPD
    IF ERRORLEVEL 1 GOTO Failure
)
ELSE IF /I "%Input_FrameworkId%"=="ng" (
    PUSHD "%Output_Resolved_ProjectRootPath%"
    CALL ng serve:%Output_Resolved_ProjectId%
    POPD
    IF ERRORLEVEL 1 GOTO Failure
)
ELSE IF /I "%Input_FrameworkId%"=="caddy" (
    PUSHD "%Output_Resolved_ProjectRootPath%"
    CALL caddy run Caddyfile
    POPD
    IF ERRORLEVEL 1 GOTO Failure
)
ELSE IF /I "%Input_FrameworkId%"=="terraform" (
    PUSHD "%Output_Resolved_ProjectRootPath%"
    CALL terraform apply
    POPD
    IF ERRORLEVEL 1 GOTO Failure
)
ELSE IF /I "%Input_FrameworkId%"=="unity" (
    PUSHD "%Output_Resolved_ProjectRootPath%"
    CALL Unity.exe -projectPath "%Output_Resolved_ProjectRootPath%" -executeMethod BuildScript.Build
    POPD
    IF ERRORLEVEL 1 GOTO Failure
)
ELSE (
    SET "Input_Error=Unsupported framework %Input_FrameworkId%"
    GOTO Failure
)