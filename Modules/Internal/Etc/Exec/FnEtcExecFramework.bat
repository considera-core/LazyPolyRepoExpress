
SET "Function_FrameworkId=%GLOBAL_FlagArg1%"

IF /I "%Function_FrameworkId%"=="dotnet" (
    PUSHD "%GLOBAL_ResolvedProjectRootPath%"
    CALL dotnet watch 
    POPD
    IF ERRORLEVEL 1 GOTO Failure
)
ELSE IF /I "%Function_FrameworkId%"=="ng" (
    PUSHD "%GLOBAL_ResolvedProjectRootPath%"
    CALL ng serve:%GLOBAL_ResolvedProjectId%
    POPD
    IF ERRORLEVEL 1 GOTO Failure
)
ELSE IF /I "%Function_FrameworkId%"=="caddy" (
    PUSHD "%GLOBAL_ResolvedProjectRootPath%"
    CALL caddy run Caddyfile
    POPD
    IF ERRORLEVEL 1 GOTO Failure
)
ELSE IF /I "%Function_FrameworkId%"=="terraform" (
    PUSHD "%GLOBAL_ResolvedProjectRootPath%"
    CALL terraform apply
    POPD
    IF ERRORLEVEL 1 GOTO Failure
)
ELSE IF /I "%Function_FrameworkId%"=="unity" (
    PUSHD "%GLOBAL_ResolvedProjectRootPath%"
    CALL Unity.exe -projectPath "%GLOBAL_ResolvedProjectRootPath%" -executeMethod BuildScript.Build
    POPD
    IF ERRORLEVEL 1 GOTO Failure
)
ELSE (
    SET "Function_Error=Unsupported framework %Function_FrameworkId%"
    GOTO Failure
)