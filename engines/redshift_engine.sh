#!/bin/bash
# Redshift Database Engine Implementation
#
# This engine implements the benchmark framework interface for Redshift databases.
# Redshift uses MySQL protocol for connections.
#
# Required environment variables:
# - host: Redshift host
# - user: Redshift username
# - password: Redshift password
# - db: Redshift database name

# Source the interface for utility functions
# TODO: modify psql to rsql if needed
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/interface.sh"

# 1. Initialize and check Redshift dependencies
engine_init() {
    # Check required command-line tools
    local missing_deps=()
    for cmd in psql; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "ERROR: Missing required dependencies: ${missing_deps[*]}" >&2
        echo "Please install the missing tools and try again." >&2
        return 1
    fi
    
    # Set default ports if not provided
    port="${port:-5439}"
    
    # Check required environment variables
    local missing_vars=()
    for var in host port user db ; do
        if [ -z "${!var:-}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "ERROR: Missing required environment variables: ${missing_vars[*]}" >&2
        echo "Please set these variables in your benchmark.yaml configuration." >&2
        return 1
    fi
    engine_setup_user
    echo "Initialized Redshift: $host:$port/$db:$schema"
    return 0
}

# 2. Execute a SQL file using mysql client
engine_run_sql_file() {
    local sql_file="$1"
    
    if [ ! -f "$sql_file" ]; then
        echo "ERROR: SQL file not found: $sql_file" >&2
        return 1
    fi
    
    # Set password environment variable for psql
    export PGPASSWORD="${password:-}"
    local args=(
        -h"$host"
        -p"$port"
        -U"$user"
        -d"$db"
        -q
        -a 
        -P pager=off
        -v ON_ERROR_STOP=1
    )
    # Execute the SQL file
    if psql "${args[@]}" -f "$sql_file"; then
        return 0
    else
        echo "ERROR: Failed to execute SQL file: $sql_file" >&2
        return 1
    fi
}

# 2.1. Execute a SQL statement using mysql client
engine_run_sql() {
    local db="$1"
    local sql_statement="$2"
    
    if [ -z "$sql_statement" ]; then
        echo "ERROR: SQL statement cannot be empty" >&2
        return 1
    fi

    # Set password environment variable for psql
    export PGPASSWORD="${password:-}"

    # Build psql command arguments
    local args=(
        -h"$host" 
        -p"$port" 
        -U"$user" 
        -d"$db"
        -q
        -a 
        -P pager=off
        -v ON_ERROR_STOP=1
    )
    # Execute the SQL statement
    if output=$(psql "${args[@]}" -c "$sql_statement" 2>&1); then
        return 0
    else
        echo "ERROR: Failed to execute SQL statement: $sql_statement" >&2
        return 1
    fi
}

# 3. Generate JDBC DataSource XML configuration for Redshift
engine_get_jdbc_datasource() {
    # TODO: Implement JDBC DataSource XML generation for Redshift
    return 0
}

# 4. Get JDBC Sampler DataSource Name
engine_get_jdbc_sampler_name() {
    echo "Redshift"
}

# Optional: Fetch engine version
engine_get_version() {
    export PGPASSWORD="${password:-}"
    local args=(
        -h"$host"
        -p"$port"
        -U"$user"
        -d"$db"
        -t
        -A
        -q
        -P pager=off
    )
    local version
    version="$(psql "${args[@]}" -c "SELECT version();" 2>/dev/null || true)"
    # Prefer the Redshift version token from the version string.
    local redshift_version
    redshift_version="$(echo "$version" | sed -n 's/.*Redshift[[:space:]]\([0-9][^ )]*\).*/\1/p' | head -n 1)"
    if [ -n "$redshift_version" ]; then
        echo "$redshift_version"
    else
        echo "$version" | head -n 1
    fi
}

# Optional: Fetch total data size in bytes
engine_get_data_size_bytes() {
    export PGPASSWORD="${password:-}"
    local args=(
        -h"$host"
        -p"$port"
        -U"$user"
        -d"$db"
        -t
        -A
        -q
        -P pager=off
    )
    if [ -n "${schema:-}" ]; then
        local size
        size="$(psql "${args[@]}" -c "SELECT COALESCE(SUM(size),0) * 1024 * 1024 FROM SVV_TABLE_INFO WHERE \"schema\" = '${schema}';" 2>/dev/null || true)"
        echo "$size" | head -n 1
    else
        local size
        size="$(psql "${args[@]}" -c "SELECT COALESCE(SUM(size),0) * 1024 * 1024 FROM SVV_TABLE_INFO;" 2>/dev/null || true)"
        echo "$size" | head -n 1
    fi
}

# Helper function to create database (used in DDL setup)
engine_create_database() {
    export PGPASSWORD="${password:-}"
    local args=(
        -h"$host"
        -p"$port"
        -U"$user"
        -d"$db"
        -q
        -a 
        -P pager=off
        -v ON_ERROR_STOP=1
    )

    local do_drop="${drop_database:-true}"

    if [ "$do_drop" = "true" ]; then
        if psql "${args[@]}" -c "DROP SCHEMA IF EXISTS ${schema} CASCADE; CREATE SCHEMA ${schema};" ; then
            return 0
        else
            echo "ERROR: Failed to create database/schema: $db/$schema" >&2
            return 1
        fi
    fi

    if psql "${args[@]}" -c "CREATE SCHEMA IF NOT EXISTS ${schema};" ; then
        return 0
    else
        echo "ERROR: Failed to create schema: $db/$schema" >&2
        return 1
    fi
}

# Optional: drop schema if requested by orchestrator
engine_drop_database() {
    export PGPASSWORD="${password:-}"
    local args=(
        -h"$host"
        -p"$port"
        -U"$user"
        -d"$db"
        -q
        -a
        -P pager=off
        -v ON_ERROR_STOP=1
    )
    if psql "${args[@]}" -c "DROP SCHEMA IF EXISTS ${schema} CASCADE;" ; then
        return 0
    else
        echo "ERROR: Failed to drop schema: $db/$schema" >&2
        return 1
    fi
}

engine_setup_user() {
    export PGPASSWORD="${password:-}"
    current_user=$(psql -h "$host" -p "$port" -U "$user" -d "$db" -t -A -v ON_ERROR_STOP=1 -c "select current_user;")
    psql -h "$host" -p "$port" -U "$user" -d "$db" -t -A -v ON_ERROR_STOP=1 -c "alter user \"${current_user}\" set enable_result_cache_for_session = false;"
    psql -h "$host" -p "$port" -U "$user" -d "$db" -v ON_ERROR_STOP=1 -q -A -t -c "ALTER USER ${current_user} SET search_path=${schema},public;"
}
