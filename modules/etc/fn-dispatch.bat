:: ==============================================================================
:: fn-dispatch <tenant> <tenant_alias> <module> <action?> <arg1?> <arg2?> <arg3?>
:: ==============================================================================
@ECHO OFF
SETLOCAL EnableExtensions
SETLOCAL EnableDelayedExpansion

SET "tenant=%~1"
SET "tenant_alias=%~2"
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

CALL fn-bootstrap "%tenant_alias%"
IF ERRORLEVEL 1 EXIT /B 1

IF /I "%module%" == "git" (
    IF NOT DEFINED action (
        ECHO [ERROR] Missing action
        ECHO   Actions: branch ^| branches ^| pull ^| home ^| story ^<storyId^>
        ECHO   For help: %tenant_alias% help
        EXIT /B 1
    )

    :: fn-git-branch <tenant> <project>
    IF /I "%action%"=="branch" (
        CALL fn-git-branch "%tenant_alias%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-git-branches <tenant> <project>
    IF /I "%action%"=="branches" (
        CALL fn-git-branches "%tenant_alias%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-git-pull <tenant> <project>
    IF /I "%action%"=="pull" (
        CALL fn-git-pull "%tenant_alias%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-git-home <tenant> <project>
    IF /I "%action%"=="home" (
        CALL fn-git-home "%tenant_alias%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-git-story <tenant> <story-id> <project> 
    IF /I "%action%"=="story" (
        CALL fn-git-story "%tenant_alias%" "%arg1%" "%arg2%"
        EXIT /B %ERRORLEVEL%
    )

    ECHO [ERROR] Unknown git action "%action%"
    ECHO    Actions: branch ^| branches ^| pull ^| home ^| story ^<storyId^>
    EXIT /B 0
)

IF /I "%module%"=="app" (
    IF NOT DEFINED action (
        ECHO [ERROR] Missing action
        ECHO   Actions: run ^| launch ^| validate
        ECHO   For help: %tenant_alias% help
        EXIT /B 1
    )

    :: fn-app-run <tenant> <app>
    IF /I "%action%"=="run" (
        CALL fn-app-run "%tenant_alias%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-app-launch <tenant> <project>
    IF /I "%action%"=="launch" (
        CALL fn-app-launch "%tenant_alias%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-app-validate <tenant> <project>
    IF /I "%action%"=="validate" (
        ECHO [INFO] Validating apps for tenant "%tenant%" and project "%arg1%"
        CALL fn-app-validate "%tenant_alias%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    ECHO [ERROR] Unknown app action "%action%"
    ECHO   Actions: run ^| launch ^| validate
    EXIT /B 0
)

IF /I "%module%"=="ide" (
    IF NOT DEFINED action (
        ECHO [ERROR] Missing action
        ECHO   Actions: rider ^| webstorm ^| jetbrains ^| code ^| riderDebug
        ECHO   For help: %tenant_alias% help
        EXIT /B 1
    )

    :: fn-ide-rider <tenant> <project>
    IF /I "%action%"=="rider" (
        CALL fn-ide-rider "%tenant_alias%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-ide-webstorm <tenant> <project>
    IF /I "%action%"=="webstorm" (
        CALL fn-ide-webstorm "%tenant_alias%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-ide-jetbrains <tenant> <project> -- opens client in Webstorm, opens server in Rider ; app type must either be bff or api
    IF /I "%action%"=="jetbrains" (
        CALL fn-ide-jetbrains "%tenant_alias%" "%arg1%" "%arg2%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-ide-code <tenant> <project>
    IF /I "%action%"=="code" (
        CALL fn-ide-code "%tenant_alias%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-ide-riderDebug <tenant> <project>
    IF /I "%action%"=="riderDebug" (
        CALL fn-ide-riderDebug "%tenant_alias%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    ECHO [ERROR] Unknown ide action "%action%"
    ECHO   Actions: rider ^| webstorm ^| jetbrains ^| code ^| riderDebug
    EXIT /B 0
)

IF /I "%module%"=="web" (
    IF NOT DEFINED action (
        ECHO [ERROR] Missing action
        ECHO   Actions: repo ^| tags ^| actions ^| app
        ECHO   For help: %tenant_alias% help
        EXIT /B 1
    )

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

    ECHO [ERROR] Unknown web action "%action%"
    ECHO   Actions: repo ^| tags ^| actions ^| app
    EXIT /B 0
)

IF /I "%module%"=="ai" (
    IF NOT DEFINED action (
        ECHO [ERROR] Missing action
        ECHO   Actions: claude
        ECHO   For help: %tenant_alias% help
        EXIT /B 1
    )

    :: fn-ai-claude <tenant> <command> <project>
    IF /I "%action%"=="claude" (
        CALL fn-ai-claude "%tenant_alias%" "%arg1%" "%arg2%"
        EXIT /B %ERRORLEVEL%
    )

    ECHO [ERROR] Unknown ai action "%action%"
    ECHO   Actions: claude
    EXIT /B 0
)

IF /I "%module%"=="npm" (
    :: fn-npm <tenant> <project> <command>
    CALL fn-npm "%tenant_alias%" "%action%" "%arg1%"
    EXIT /B %ERRORLEVEL%
)

IF /I "%module%"=="npx" (
    :: fn-npx-knip <tenant> <project>
    IF /I "%action%"=="knip" (
        CALL fn-npx-knip "%tenant_alias%" "%arg1%"
        EXIT /B %ERRORLEVEL%
    )

    :: fn-npx <tenant> <project> <command>
    CALL fn-npx "%tenant_alias%" "%action%" "%arg1%"
    EXIT /B %ERRORLEVEL%
)

IF /I "%module%"=="aws" (
    IF NOT DEFINED action (
        ECHO [ERROR] Missing action
        ECHO   Actions: profile
        ECHO   For help: %tenant_alias% help
        EXIT /B 1
    )

    :: fn-aws-profile <tenant>
    IF /I "%action%"=="profile" (
        CALL fn-aws-profile "%tenant_alias%"
        EXIT /B %ERRORLEVEL%
    )

    ECHO [ERROR] Unknown aws action "%action%"
    ECHO   Actions: profile
    EXIT /B 0
)

IF /I "%module%"=="module" (
    ECHO [INFO] Listing modules
    ECHO   Usage: %tenant_alias% [flags] ^<module^> ^<action^> [args...]
    ECHO   Modules: git ^| app ^| ide ^| web ^| aws ^| ai ^| npm ^| help
    ECHO   For help: %tenant_alias% help
    EXIT /B 0
)

IF /I "%module%"=="modules" (
    ECHO [INFO] Listing modules
    ECHO   Usage: %tenant_alias% [flags] ^<module^> ^<action^> [args...]
    ECHO   Modules: git ^| app ^| ide ^| web ^| aws ^| ai ^| npm ^| help
    ECHO   For help: %tenant_alias% help
    EXIT /B 0
)

:MODULE_FAIL
    ECHO [ERROR] Missing module
    ECHO   Usage: %tenant_alias% [flags] ^<module^> ^<action^> [args...]
    ECHO   Modules: git ^| app ^| ide ^| web ^| aws ^| ai ^| npm ^| help
    ECHO   For help: %tenant_alias% help
    ECHO.
    EXIT /B 0

:HELP
    echo [LPRE HELP: %tenant%]
    echo.
    echo     [USAGE]
    ::echo       %tenant_alias% [flags] ^<module^> ^<action^> [args...]
    echo       %tenant_alias% ^<module^> ^<action^> [args...]
    echo.
    ::echo     [FLAGS]
    ::echo       -v                         Verbose output (shows bootstrap details). More flags coming.
    ::echo.
    echo     [MODULES]
    echo       git                                             Git operations across one repo (by alias) or all repos (depends on action).
    echo       app                                             App-level workflows (run/validate).
    echo       ide                                             Open projects in IDEs.
    echo       web                                             Open web resources (repo/tags/actions/app URL).
    echo       aws                                             AWS configuration and profile management.
    echo       npm                                             Node.js package management.
    echo.
    echo     [GIT MODULE]
    echo       %tenant_alias% git branch   ^<project^>                   Show current branch for a project
    echo       %tenant_alias% git branches ^<project^>                   List local branches for a project
    echo       %tenant_alias% git pull     [project?]                  Pull current branch (all repos if project omitted)
    echo       %tenant_alias% git home     [project?]                  Switch to root branch main/master (all repos if omitted)
    echo       %tenant_alias% git story    ^<project^> ^<story-id^>        Switch or create branch named story-id
    echo.
    echo     [APP MODULE]
    echo       %tenant_alias% app launch   ^<project^> ^<here?^>           Launch a singular project
    echo       %tenant_alias% app run      ^<app^>                       Run an app (group of projects)
    echo       %tenant_alias% app validate [project?]                  Validate configured repos exist (or just one)
    echo.
    echo     [IDE MODULE]
    echo       %tenant_alias% ide rider    ^<project^>                   Open project in Rider
    echo       %tenant_alias% ide webstorm ^<project^>                   Open project in WebStorm
    echo       %tenant_alias% ide code     ^<project^>                   Open project in VS Code
    echo       %tenant_alias% ide jetbrains ^<project^>                  Open client in WebStorm, server in Rider
    echo       %tenant_alias% ide riderDebug ^<project^>                 Attach Rider debugger to running .dll process
    echo.
    echo     [WEB MODULE]
    echo       %tenant_alias% web repo     ^<project^>                   Open GitHub repo page
    echo       %tenant_alias% web tags     ^<project^>                   Open GitHub tags page
    echo       %tenant_alias% web actions  ^<project^>                   Open GitHub actions page
    echo       %tenant_alias% web app      ^<app^> [env?]                Open app URL (env defaults to local)
    echo.
    echo     [AWS MODULE]
    echo       %tenant_alias% aws profile  ^<profile-name^>              Set AWS_PROFILE environment variable
    echo.
    echo     [NPM MODULE]
    echo       %tenant_alias% npm          ^<project?^> ^<command^>           Node.js package management
    echo.
    echo     [NPX MODULE]
    echo       %tenant_alias% npx          ^<project?^> ^<command^>           Node.js package execution
    echo       %tenant_alias% npx knip     ^<project?^>                   Alias for "%tenant_alias% npx <project?> -y knip --dependencies > /.tmp/knip/%tenant_alias%-<project>.txt 2>&1"
    echo.
    echo     [TERMS]
    echo       project                                         Repo alias from this tenant's ^<tenant^>.csv (example: citizen, admin, api)
    echo       app                                             App alias (often same as a BFF alias like citizen/admin/support/public)
    echo       env                                             local ^| ci ^| qa ^| prod  (defaults to local)
    echo.
    echo     [EXAMPLES]
    echo       - %tenant_alias% git pull
    echo       - %tenant_alias% git pull admin
    echo       - %tenant_alias% git story admin EV-4235
    echo       - %tenant_alias% app run citizen
    echo       - %tenant_alias% web app citizen qa
    echo       - %tenant_alias% ide jetbrains admin
    echo.
    echo     [NOTES]
    echo       - This tenant loads repos from %tenant_alias%.csv (or equivalent). Aliases differ per tenant.
    echo       - Some actions support "all repos" behavior when ^<project^> is omitted.
    echo.
    exit /b 0