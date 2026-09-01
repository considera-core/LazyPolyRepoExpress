#!/usr/bin/env bash
# =====================
# fn-bootstrap <tenant>
# =====================
# Loads tenant and module configuration from CSV files

tenantName="$1"

# Set LPRE repo path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LPRE_REPO_PATH="$(cd "$SCRIPT_DIR/../.." && pwd)"
export LPRE_REPO_PATH

tenantCSV="$LPRE_REPO_PATH/tenants/data/$tenantName.csv"
if [ ! -f "$tenantCSV" ]; then
    echo "[ERROR] $tenantName.csv not found at $tenantCSV"
    exit 1
fi

tenantsCSV="$LPRE_REPO_PATH/tenants/data/tenants.csv"
if [ ! -f "$tenantsCSV" ]; then
    echo "[ERROR] tenants.csv not found at $tenantsCSV"
    exit 1
fi

# Clear previous repo and tenant variables
unset REPO_COUNT TENANT_COUNT
for var in $(compgen -v | grep -E '^REPO_|^TENANT_'); do
    unset "$var"
done

# Parse tenants.csv
TENANT_COUNT=0
while IFS=, read -r alias display root; do
    # Skip header and comments
    if [[ "$alias" == "alias" || "$alias" == \#* ]]; then
        continue
    fi

    if [ "$alias" = "$tenantName" ]; then
        ((TENANT_COUNT++))
        eval "TENANT_${TENANT_COUNT}_alias=\"$alias\""
        eval "TENANT_${TENANT_COUNT}_display=\"$display\""
        eval "TENANT_${TENANT_COUNT}_root=\"$root\""
    fi
done < "$tenantsCSV"

if [ "$TENANT_COUNT" -eq 0 ]; then
    echo "[ERROR] No tenants parsed from $tenantsCSV"
    exit 1
fi

export TENANT_COUNT

# Parse tenant modules CSV
REPO_COUNT=0
while IFS=, read -r alias name label type client server home; do
    # Skip header and comments
    if [[ "$alias" == "alias" || "$alias" == \#* ]]; then
        continue
    fi

    ((REPO_COUNT++))
    eval "REPO_${REPO_COUNT}_alias=\"$alias\""
    eval "REPO_${REPO_COUNT}_name=\"$name\""
    eval "REPO_${REPO_COUNT}_label=\"$label\""
    eval "REPO_${REPO_COUNT}_type=\"$type\""
    eval "REPO_${REPO_COUNT}_client=\"$client\""
    eval "REPO_${REPO_COUNT}_server=\"$server\""
    eval "REPO_${REPO_COUNT}_home=\"$home\""
done < "$tenantCSV"

if [ "$REPO_COUNT" -eq 0 ]; then
    echo "[ERROR] No repos parsed from $tenantCSV"
    exit 1
fi

export REPO_COUNT

# Export all REPO and TENANT variables for child processes
for i in $(seq 1 "$TENANT_COUNT"); do
    for field in alias display root; do
        var="TENANT_${i}_${field}"
        export "$var"
    done
done

for i in $(seq 1 "$REPO_COUNT"); do
    for field in alias name label type client server home; do
        var="REPO_${i}_${field}"
        export "$var"
    done
done

exit 0
