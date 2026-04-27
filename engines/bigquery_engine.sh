#!/bin/bash
# BigQuery Database Engine Implementation
#
# This engine implements the benchmark framework interface for Google BigQuery.
# It uses the bq command-line tool for SQL execution.
#
# Required environment variables:
# - project: Google Cloud project ID
# - db: BigQuery dataset name
# - location: BigQuery location/region (Optional, default: US)
# - application_credentials: Path to service account JSON key file (Optional, use `gcloud auth application-default login` to create one)

# Source the interface for utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/interface.sh"

# # setup gcloud application credentials
# setup_gcloud() {
#     wget --continue --progress=dot:giga https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
#     tar -xf google-cloud-cli-linux-x86_64.tar.gz
#     ./google-cloud-sdk/install.sh
#     source .bashrc
#     ./google-cloud-sdk/bin/gcloud init
# }

# 1. Initialize and check BigQuery dependencies
engine_init() {
    # Check required command-line tools
    local missing_deps=()
    for cmd in bq; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "ERROR: Missing required dependencies: ${missing_deps[*]}" >&2
        echo "Please install the Google Cloud SDK and try again." >&2
        return 1
    fi
    
    # Set default location if not provided
    location="${location:-US}"
    
    # Check required environment variables
    local missing_vars=()
    for var in project db; do
        if [ -z "${!var:-}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "ERROR: Missing required environment variables: ${missing_vars[*]}" >&2
        echo "Please set these variables in your benchmark.yaml configuration." >&2
        return 1
    fi
    
    # Authenticate with service account if key is provided
    if [ -n "${application_credentials:-}" ]; then
        if [ ! -f "$application_credentials" ]; then
            echo "ERROR: Application credentials file not found: $application_credentials" >&2
            return 1
        fi
        export GOOGLE_APPLICATION_CREDENTIALS="$application_credentials"
    fi
    
    echo "Initialized BigQuery: $project/$db (location: $location)"
    return 0
}

# 2. Execute a SQL file using bq command
engine_run_sql_file() {
    local sql_file="$1"
    
    if [ ! -f "$sql_file" ]; then
        echo "ERROR: SQL file not found: $sql_file" >&2
        return 1
    fi
    
    # Read the SQL file content
    local sql_content
    sql_content=$(cat "$sql_file")
    
    # Build bq command arguments
    local args=(
        query
        --project_id="$project"
        --use_legacy_sql=false
        --use_cache=false
        --location="$location"
        --format=prettyjson
    )
    
    # Execute the SQL file
    if bq "${args[@]}" "$sql_content"; then
        return 0
    else
        echo "ERROR: Failed to execute SQL file: $sql_file" >&2
        return 1
    fi
}

# 2.1. Execute a SQL statement using bq command
engine_run_sql() {
    local target_dataset="$1"
    local sql_statement="$2"
    
    if [ -z "$sql_statement" ]; then
        echo "ERROR: SQL statement cannot be empty" >&2
        return 1
    fi
    
    # Build bq command arguments
    local args=(
        query
        --project_id="$project"
        --use_legacy_sql=false
        --use_cache=false
        --location="$location"
        --format=prettyjson
    )
    
    # Add dataset if provided
    if [ -n "$target_dataset" ]; then
        args+=(--dataset_id="$target_dataset")
    fi
    
    # Execute the SQL statement
    if bq "${args[@]}" "$sql_statement"; then
        return 0
    else
        echo "ERROR: Failed to execute SQL statement: $sql_statement" >&2
        return 1
    fi
}

# Optional: Fetch engine version
engine_get_version() {
    # BigQuery does not expose a server version via SQL in most environments.
    # Use the bq client version as a best-effort proxy.
    local version
    version="$(bq version 2>/dev/null | head -n 1 | tr -d '\r' || true)"
    # Extract the first X.Y.Z-style token to return a pure version number.
    version="$(echo "$version" | grep -Eo '[0-9]+([.][0-9]+)+' | head -n 1 || true)"
    echo "$version"
}

# Optional: Fetch total data size in bytes
engine_get_data_size_bytes() {
    local args=(
        query
        --project_id="$project"
        --use_legacy_sql=false
        --location="$location"
        --format=csv
        --headless
    )
    local size
    size="$(bq "${args[@]}" "SELECT COALESCE(SUM(size_bytes),0) FROM \`${project}.${db}.__TABLES__\`;" 2>/dev/null || true)"
    echo "$size" | head -n 1
}

# Helper function to create dataset (used in DDL setup)
engine_create_database() {
    # Build bq command arguments for removing dataset
    local rm_args=(
        rm
        --project_id="$project"
        --location="$location"
        -r
        -f
        "${project}:${db}"
    )
    
    # Build bq command arguments for creating dataset
    local mk_args=(
        mk
        --project_id="$project"
        --location="$location"
        --dataset
        "${project}:${db}"
    )

    local do_drop="${drop_database:-true}"

    if [ "$do_drop" = "true" ]; then
        # Remove existing dataset if it exists, then create new one
        bq "${rm_args[@]}" 2>/dev/null || true
        if bq "${mk_args[@]}"; then
            return 0
        else
            echo "ERROR: Failed to create dataset: $db" >&2
            return 1
        fi
    fi

    if bq show --project_id="$project" "${project}:${db}" >/dev/null 2>&1; then
        return 0
    fi

    if bq "${mk_args[@]}"; then
        return 0
    else
        echo "ERROR: Failed to create dataset: $db" >&2
        return 1
    fi
}

# Optional: drop dataset if requested by orchestrator
engine_drop_database() {
    local rm_args=(
        rm
        --project_id="$project"
        --location="$location"
        -r
        -f
        "${project}:${db}"
    )

    if bq "${rm_args[@]}" 2>/dev/null; then
        return 0
    else
        echo "ERROR: Failed to drop dataset: $db" >&2
        return 1
    fi
}
