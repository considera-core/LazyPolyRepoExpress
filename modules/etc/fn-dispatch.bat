:: ==============================================================================
:: fn-bootstrap <tenant> <script_name> <module> <action?> <arg1?> <arg2?> <arg3?>
:: ==============================================================================
@ECHO OFF
SETLOCAL EnableExtensions
SETLOCAL EnableDelayedExpansion

SET "tenant=%~1"
SET "script_name=%~2"
SET "module=%~3"
SET "action=%~4"
SET "arg1=%~5"
SET "arg2=%~6"
SET "arg3=%~7"

IF NOT DEFINED tenant (
    ECHO [ERROR] Missing tenant
    EXIT /B 1
)

IF NOT DEFINED module (
    CALL :MODULE_FAIL
    EXIT /B 1
)

IF /I "%module%" == "help" (
    CALL :HELP
    EXIT /B 0
)

CALL fn-bootstrap "%script_name%"
IF ERRORLEVEL 1 EXIT /B 1

IF NOT DEFINED action (
    ECHO [ERROR] Missing action
    ECHO   Actions: branch ^| branches ^| pull ^| home ^| story ^<storyId^>
    ECHO   For help: %script_name% help
    EXIT /B 1
)

IF /I "%module%" == "git" (
    :: fn-git-branch <tenant> <project>
    IF /I "%action%"=="branch" (
        CALL fn-git-branch "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-git-branches <tenant> <project>
    IF /I "%action%"=="branches" (
        CALL fn-git-branches "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-git-pull <tenant> <project>
    IF /I "%action%"=="pull" (
        CALL fn-git-pull "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-git-home <tenant> <project>
    IF /I "%action%"=="home" (
        CALL fn-git-home "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-git-story <tenant> <story-id> <project> 
    IF /I "%action%"=="story" (
        CALL fn-git-story "%tenant%" "%arg1%" "%arg2%"
        EXIT /B %ERRORLEVEL%
    )

    ECHO [ERROR] Unknown git action "%action%"
    ECHO         Actions: branch ^| branches ^| pull ^| home ^| story ^<storyId^>
    EXIT /B 0
)

IF /I "%module%"=="app" (
    :: fn-app-run <tenant> <app>
    IF /I "%action%"=="run" (
        CALL fn-app-run "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-app-launch <tenant> <project>
    IF /I "%action%"=="launch" (
        CALL fn-app-launch "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-app-validate <tenant> <project>
    IF /I "%action%"=="validate" (
        ECHO [INFO] Validating apps for tenant "%tenant%" and project "%arg1%"
        CALL fn-app-validate "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    ECHO [ERROR] Unknown app action "%action%"
    ECHO         Actions: run ^| launch ^| validate
    EXIT /B 0
)

IF /I "%module%"=="ide" (
    :: fn-ide-rider <tenant> <project>
    IF /I "%action%"=="rider" (
        CALL fn-ide-rider "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-ide-webstorm <tenant> <project>
    IF /I "%action%"=="webstorm" (
        CALL fn-ide-webstorm "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-ide-jetbrains <tenant> <project> -- opens client in Webstorm, opens server in Rider ; app type must either be bff or api
    IF /I "%action%"=="jetbrains" (
        CALL fn-ide-jetbrains "%tenant%" "%arg1%" "%arg2%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-ide-code <tenant> <project>
    IF /I "%action%"=="code" (
        CALL fn-ide-code "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    ECHO [ERROR] Unknown ide action "%action%"
    ECHO         Actions: rider ^| webstorm ^| jetbrains ^| code
    EXIT /B 0
)

IF /I "%module%"=="web" (
    :: fn-web-repo <tenant> <project>
    IF /I "%action%"=="repo" (
        CALL fn-web-repo "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-web-tags <tenant> <project>
    IF /I "%action%"=="tags" (
        CALL fn-web-tags "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-web-actions <tenant> <project>
    IF /I "%action%"=="actions" (
        CALL fn-web-actions "%tenant%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-web-app <tenant> <project> <env?>
    IF /I "%action%"=="app" (
        CALL fn-web-app "%tenant%" "%arg1%" "%arg2%"
        EXIT /B %ERRORLEVEL%
    )

    EXIT /B 0
)

IF /I "%module%"=="ai" (
    :: fn-ai-claude <tenant> <command> <project>
    IF /I "%action%"=="claude" (
        CALL fn-ai-claude "%tenant%" "%arg1%" "%arg2%"
        EXIT /B %ERRORLEVEL%
    )

    EXIT /B 0
)

IF /I "%module%"=="module" (
    ECHO [INFO] Listing modules
    ECHO   Usage: %script_name% [flags] ^<module^> ^<action^> [args...]
    ECHO   Modules: git ^| app ^| ide ^| web ^| help
    ECHO   For help: %script_name% help
    EXIT /B 0
)

IF /I "%module%"=="modules" (
    ECHO [INFO] Listing modules
    ECHO   Usage: %script_name% [flags] ^<module^> ^<action^> [args...]
    ECHO   Modules: git ^| app ^| ide ^| web ^| help
    ECHO   For help: %script_name% help
    EXIT /B 0
)

:MODULE_FAIL
    ECHO [ERROR] Missing module
    ECHO   Usage: %script_name% [flags] ^<module^> ^<action^> [args...]
    ECHO   Modules: git ^| app ^| ide ^| web ^| help
    ECHO   For help: %script_name% help
    ECHO.
    EXIT /B 0

:HELP
    echo [VANGUARD HELP: %tenant%]
    echo.
    echo     [USAGE]
    ::echo       %script_name% [flags] ^<module^> ^<action^> [args...]
    echo       %script_name% ^<module^> ^<action^> [args...]
    echo.
    ::echo     [FLAGS]
    ::echo       -v                         Verbose output (shows bootstrap details). More flags coming.
    ::echo.
    echo     [MODULES]
    echo       git                                             Git operations across one repo (by alias) or all repos (depends on action).
    echo       app                                             App-level workflows (run/validate).
    echo       ide                                             Open projects in IDEs.
    echo       web                                             Open web resources (repo/tags/actions/app URL).
    echo.
    echo     [GIT MODULE]
    echo       %script_name% git branch   ^<project^>                   Show current branch for a project
    echo       %script_name% git branches ^<project^>                   List local branches for a project
    echo       %script_name% git pull     [project?]                  Pull current branch (all repos if project omitted)
    echo       %script_name% git home     [project?]                  Switch to root branch main/master (all repos if omitted)
    echo       %script_name% git story    ^<project^> ^<story-id^>        Switch or create branch named story-id
    echo.
    echo     [APP MODULE]
    echo       %script_name% app launch   ^<project^> ^<here?^>           Launch a singular project
    echo       %script_name% app run      ^<app^>                       Run an app (group of projects)
    echo       %script_name% app validate [project?]                  Validate configured repos exist (or just one)
    echo.
    echo     [IDE MODULE]
    echo       %script_name% ide rider    ^<project^>                   Open project in Rider
    echo       %script_name% ide webstorm ^<project^>                   Open project in WebStorm
    echo       %script_name% ide code     ^<project^>                   Open project in VS Code
    echo       %script_name% ide jetbrains ^<project^>                  Open client in WebStorm, server in Rider
    echo.
    echo     [WEB MODULE]
    echo       %script_name% web repo     ^<project^>                   Open GitHub repo page
    echo       %script_name% web tags     ^<project^>                   Open GitHub tags page
    echo       %script_name% web actions  ^<project^>                   Open GitHub actions page
    echo       %script_name% web app      ^<app^> [env?]                Open app URL (env defaults to local)
    echo.
    echo     [TERMS]
    echo       project                                         Repo alias from this tenant's ^<tenant^>.csv (example: citizen, admin, api)
    echo       app                                             App alias (often same as a BFF alias like citizen/admin/support/public)
    echo       env                                             local ^| ci ^| qa ^| prod  (defaults to local)
    echo.
    echo     [EXAMPLES]
    echo       - %script_name% git pull
    echo       - %script_name% git pull admin
    echo       - %script_name% git story admin EV-4235
    echo       - %script_name% app run citizen
    echo       - %script_name% web app citizen qa
    echo       - %script_name% ide jetbrains admin
    ::echo       - %script_name% -v app validate
    echo.
    echo     [NOTES]
    echo       - This tenant loads repos from %script_name%.csv (or equivalent). Aliases differ per tenant.
    echo       - Some actions support "all repos" behavior when ^<project^> is omitted.
    echo.
    exit /b 0