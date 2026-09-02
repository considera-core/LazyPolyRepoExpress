:: FnEtcEnvGetRootRepoPath
:: leprechaun function env RootRepoPath
:: -- Resolves the repository root and exports GLOBAL_RootRepoPath.
:: --
:: -- Self locating from %~dp0 rather than shelling out to a config reader, for
:: -- the same reason as FnEtcEnvGetDataPath: the root is a fact about where this
:: -- script sits, not something that needs looking up.
:: --
:: -- NOTE: No SETLOCAL -- this script exists to export GLOBAL_RootRepoPath.

@ECHO OFF

:: <root>\Modules\Internal\Etc\Env\ -> <root>
FOR %%I IN ("%~dp0..\..\..\..") DO SET "GLOBAL_RootRepoPath=%%~fI"

IF NOT EXIST "%GLOBAL_RootRepoPath%\Modules" (
    CALL FnEtcLogError FnEtcEnvGetRootRepoPath "Repository root not found at %GLOBAL_RootRepoPath%"
    SET "GLOBAL_RootRepoPath="
    EXIT /B 1
)

EXIT /B 0
