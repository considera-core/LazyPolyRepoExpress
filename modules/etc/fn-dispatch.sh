#!/usr/bin/env bash
# ==============================================================================
# fn-dispatch <tenant> <tenant_alias> <module> <action?> <arg1?> <arg2?> <arg3?>
# ==============================================================================

tenant="$1"
tenant_alias="$2"
module="$3"
action="$4"
arg1="$5"
arg2="$6"
arg3="$7"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$tenant" ]; then
    echo "[ERROR] Missing tenant"
    exit 1
fi

if [ -z "$module" ]; then
    echo "[ERROR] Missing module"
    echo "  Usage: $tenant_alias <module> <action> [args...]"
    echo "  Modules: git | app | ide | web | aws | ai | npm | npx | help"
    echo "  For help: $tenant_alias help"
    exit 1
fi

# Handle help
if [ "${module,,}" = "help" ]; then
    "$SCRIPT_DIR/fn-dispatch-help.sh" "$tenant" "$tenant_alias"
    exit 0
fi

# Bootstrap tenant configuration
"$SCRIPT_DIR/fn-bootstrap.sh" "$tenant_alias"
if [ $? -ne 0 ]; then
    exit 1
fi

# Git module
if [ "${module,,}" = "git" ]; then
    if [ -z "$action" ]; then
        echo "[ERROR] Missing action"
        echo "  Actions: branch | branches | pull | home | story <storyId>"
        echo "  For help: $tenant_alias help"
        exit 1
    fi

    case "${action,,}" in
        branch)
            "$SCRIPT_DIR/../git/fn-git-branch.sh" "$tenant_alias" "$arg1"
            exit $?
            ;;
        branches)
            "$SCRIPT_DIR/../git/fn-git-branches.sh" "$tenant_alias" "$arg1"
            exit $?
            ;;
        pull)
            "$SCRIPT_DIR/../git/fn-git-pull.sh" "$tenant_alias" "$arg1"
            exit $?
            ;;
        home)
            "$SCRIPT_DIR/../git/fn-git-home.sh" "$tenant_alias" "$arg1"
            exit $?
            ;;
        story)
            "$SCRIPT_DIR/../git/fn-git-story.sh" "$tenant_alias" "$arg1" "$arg2"
            exit $?
            ;;
        *)
            echo "[ERROR] Unknown git action \"$action\""
            echo "  Actions: branch | branches | pull | home | story <storyId>"
            exit 1
            ;;
    esac
fi

# App module
if [ "${module,,}" = "app" ]; then
    if [ -z "$action" ]; then
        echo "[ERROR] Missing action"
        echo "  Actions: run | launch | validate"
        echo "  For help: $tenant_alias help"
        exit 1
    fi

    case "${action,,}" in
        run)
            "$SCRIPT_DIR/../app/fn-app-run.sh" "$tenant_alias" "$arg1"
            exit $?
            ;;
        launch)
            "$SCRIPT_DIR/../app/fn-app-launch.sh" "$tenant_alias" "$arg1"
            exit $?
            ;;
        validate)
            echo "[INFO] Validating apps for tenant \"$tenant\" and project \"$arg1\""
            "$SCRIPT_DIR/../app/fn-app-validate.sh" "$tenant_alias" "$arg1"
            exit $?
            ;;
        *)
            echo "[ERROR] Unknown app action \"$action\""
            echo "  Actions: run | launch | validate"
            exit 1
            ;;
    esac
fi

# IDE module
if [ "${module,,}" = "ide" ]; then
    if [ -z "$action" ]; then
        echo "[ERROR] Missing action"
        echo "  Actions: rider | webstorm | jetbrains | code | riderDebug"
        echo "  For help: $tenant_alias help"
        exit 1
    fi

    case "${action,,}" in
        rider)
            "$SCRIPT_DIR/../ide/fn-ide-rider.sh" "$tenant_alias" "$arg1"
            exit $?
            ;;
        webstorm)
            "$SCRIPT_DIR/../ide/fn-ide-webstorm.sh" "$tenant_alias" "$arg1"
            exit $?
            ;;
        jetbrains)
            "$SCRIPT_DIR/../ide/fn-ide-jetbrains.sh" "$tenant_alias" "$arg1" "$arg2"
            exit $?
            ;;
        code)
            "$SCRIPT_DIR/../ide/fn-ide-code.sh" "$tenant_alias" "$arg1"
            exit $?
            ;;
        riderdebug)
            "$SCRIPT_DIR/../ide/fn-ide-riderDebug.sh" "$tenant_alias" "$arg1"
            exit $?
            ;;
        *)
            echo "[ERROR] Unknown ide action \"$action\""
            echo "  Actions: rider | webstorm | jetbrains | code | riderDebug"
            exit 1
            ;;
    esac
fi

# Web module
if [ "${module,,}" = "web" ]; then
    if [ -z "$action" ]; then
        echo "[ERROR] Missing action"
        echo "  Actions: repo | tags | actions | app"
        echo "  For help: $tenant_alias help"
        exit 1
    fi

    case "${action,,}" in
        repo)
            "$SCRIPT_DIR/../web/fn-web-repo.sh" "$tenant" "$arg1"
            exit $?
            ;;
        tags)
            "$SCRIPT_DIR/../web/fn-web-tags.sh" "$tenant" "$arg1"
            exit $?
            ;;
        actions)
            "$SCRIPT_DIR/../web/fn-web-actions.sh" "$tenant" "$arg1"
            exit $?
            ;;
        app)
            "$SCRIPT_DIR/../web/fn-web-app.sh" "$tenant" "$arg1" "$arg2"
            exit $?
            ;;
        *)
            echo "[ERROR] Unknown web action \"$action\""
            echo "  Actions: repo | tags | actions | app"
            exit 1
            ;;
    esac
fi

# AI module
if [ "${module,,}" = "ai" ]; then
    if [ -z "$action" ]; then
        echo "[ERROR] Missing action"
        echo "  Actions: claude"
        echo "  For help: $tenant_alias help"
        exit 1
    fi

    case "${action,,}" in
        claude)
            "$SCRIPT_DIR/../ai/fn-ai-claude.sh" "$tenant_alias" "$arg1" "$arg2"
            exit $?
            ;;
        *)
            echo "[ERROR] Unknown ai action \"$action\""
            echo "  Actions: claude"
            exit 1
            ;;
    esac
fi

# NPM module
if [ "${module,,}" = "npm" ]; then
    "$SCRIPT_DIR/../npm/fn-npm.sh" "$tenant_alias" "$action" "$arg1"
    exit $?
fi

# NPX module
if [ "${module,,}" = "npx" ]; then
    if [ "${action,,}" = "knip" ]; then
        "$SCRIPT_DIR/../npx/fn-npx-knip.sh" "$tenant_alias" "$arg1"
        exit $?
    fi

    "$SCRIPT_DIR/../npx/fn-npx.sh" "$tenant_alias" "$action" "$arg1"
    exit $?
fi

# AWS module
if [ "${module,,}" = "aws" ]; then
    if [ -z "$action" ]; then
        echo "[ERROR] Missing action"
        echo "  Actions: profile"
        echo "  For help: $tenant_alias help"
        exit 1
    fi

    case "${action,,}" in
        profile)
            "$SCRIPT_DIR/../aws/fn-aws-profile.sh" "$tenant_alias"
            exit $?
            ;;
        *)
            echo "[ERROR] Unknown aws action \"$action\""
            echo "  Actions: profile"
            exit 1
            ;;
    esac
fi

# Module listing
if [ "${module,,}" = "module" ] || [ "${module,,}" = "modules" ]; then
    echo "[INFO] Listing modules"
    echo "  Usage: $tenant_alias <module> <action> [args...]"
    echo "  Modules: git | app | ide | web | aws | ai | npm | npx | help"
    echo "  For help: $tenant_alias help"
    exit 0
fi

echo "[ERROR] Unknown module \"$module\""
echo "  Usage: $tenant_alias <module> <action> [args...]"
echo "  Modules: git | app | ide | web | aws | ai | npm | npx | help"
echo "  For help: $tenant_alias help"
exit 1
