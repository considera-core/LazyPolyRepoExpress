#!/usr/bin/env bash
# The name of the App directory (/Tenant/...projects)
Tenant="SampleTenant"
# The name of the CSV key
KEY="sample-tenant"
module="$1"
action="$2"
arg1="$3"
arg2="$4"
arg3="$5"

# Get the script directory to find fn-dispatch
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$(cd "$SCRIPT_DIR/../../modules/etc" && pwd)"

# Call fn-dispatch
"$MODULES_DIR/fn-dispatch.sh" "$Tenant" "$KEY" "$module" "$action" "$arg1" "$arg2" "$arg3"
exit $?
