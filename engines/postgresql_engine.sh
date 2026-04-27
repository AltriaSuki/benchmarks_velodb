#!/bin/bash
# PostgreSQL Database Engine Implementation
#
# This engine implements the benchmark framework interface for PostgreSQL databases.
# PostgreSQL uses native psql protocol for connections.
#
# Required environment variables:
# - pg_host: PostgreSQL host address
# - pg_port: PostgreSQL port (default: 5432)
# - user: PostgreSQL username
# - password: PostgreSQL password (optional)
# - db: PostgreSQL database name

# Source the interface for utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/interface.sh"

# 1. Initialize and check PostgreSQL dependencies
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
        echo "Please install: sudo apt-get install postgresql-client" >&2
        return 1
    fi
    
    # Set default port if not provided
    pg_port="${pg_port:-5432}"
    
    # Check required environment variables
    local missing_vars=()
    for var in pg_host user db; do
        if [ -z "${!var:-}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "ERROR: Missing required environment variables: ${missing_vars[*]}" >&2
        echo "Please set these variables in your benchmark.yaml configuration." >&2
        return 1
    fi
    
    echo "Initialized PostgreSQL: $pg_host:$pg_port/$db"
    return 0
}

# 2. Execute a SQL file using psql client
engine_run_sql_file() {
    local sql_file="$1"
    
    if [ ! -f "$sql_file" ]; then
        echo "ERROR: SQL file not found: $sql_file" >&2
        return 1
    fi
    
    # Set password environment variable for psql
    export PGPASSWORD="${password:-}"
    
    local args=(
        -h"$pg_host"
        -p"$pg_port"
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

# 2.1. Execute a SQL statement using psql client
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
        -h"$pg_host" 
        -p"$pg_port" 
        -U"$user"
        -q
        -a 
        -P pager=off
        -v ON_ERROR_STOP=1
    )
    
    # Add database if specified
    [ -n "$db" ] && args+=(-d"$db")
    
    # Execute the SQL statement
    if output=$(psql "${args[@]}" -c "$sql_statement" 2>&1); then
        return 0
    else
        echo "ERROR: Failed to execute SQL statement: $sql_statement" >&2
        return 1
    fi
}

# 3. Generate JDBC DataSource XML configuration for PostgreSQL
engine_get_jdbc_datasource() {
    # Escape any special characters in the password
    local escaped_password
    escaped_password=$(xml_escape "${password:-}")
    
    cat << EOF
<JDBCDataSource guiclass="TestBeanGUI" testclass="JDBCDataSource" testname="JDBC Connection Configuration" enabled="true">
  <boolProp name="autocommit">true</boolProp>
  <stringProp name="checkQuery">SELECT 1</stringProp>
  <stringProp name="connectionAge">5000</stringProp>
  <stringProp name="connectionProperties"></stringProp>
  <stringProp name="dataSource">PostgreSQL</stringProp>
  <stringProp name="dbUrl">jdbc:postgresql://${pg_host}:${pg_port}/${db}</stringProp>
  <stringProp name="driver">org.postgresql.Driver</stringProp>
  <stringProp name="keepAlive">true</stringProp>
  <stringProp name="password">${escaped_password}</stringProp>
  <stringProp name="poolMax">0</stringProp>
  <stringProp name="timeout">10000</stringProp>
  <stringProp name="transactionIsolation">DEFAULT</stringProp>
  <stringProp name="trimInterval">60000</stringProp>
  <stringProp name="username">${user}</stringProp>
</JDBCDataSource>
EOF
}

# 4. Get JDBC Sampler DataSource Name
engine_get_jdbc_sampler_name() {
    echo "PostgreSQL"
}

# Optional: Fetch engine version
engine_get_version() {
    export PGPASSWORD="${password:-}"
    local args=(
        -h"$pg_host"
        -p"$pg_port"
        -U"$user"
        -d"$db"
        -t
        -A
        -q
        -P pager=off
    )
    local version
    version="$(psql "${args[@]}" -c "SHOW server_version;" 2>/dev/null || true)"
    echo "$version" | head -n 1
}

# Optional: Fetch total data size in bytes
engine_get_data_size_bytes() {
    export PGPASSWORD="${password:-}"
    local args=(
        -h"$pg_host"
        -p"$pg_port"
        -U"$user"
        -d"$db"
        -t
        -A
        -q
        -P pager=off
    )
    local size
    size="$(psql "${args[@]}" -c "SELECT pg_database_size(current_database());" 2>/dev/null || true)"
    echo "$size" | head -n 1
}

# Helper function to create database (used in DDL setup)
engine_create_database() {
    export PGPASSWORD="${password:-}"
    local args=(
        -h"$pg_host"
        -p"$pg_port"
        -U"$user"
        -d"postgres"
        -q
        -a 
        -P pager=off
        -v ON_ERROR_STOP=1
    )

    local do_drop="${drop_database:-true}"

    if [ "$do_drop" = "true" ]; then
        if psql "${args[@]}" -c "DROP DATABASE IF EXISTS ${db};" && \
           psql "${args[@]}" -c "CREATE DATABASE ${db};"; then
            echo "Database ${db} created successfully"
            return 0
        else
            echo "ERROR: Failed to create database: $db" >&2
            return 1
        fi
    fi

    local args_noecho=()
    for arg in "${args[@]}"; do
        if [ "$arg" = "-a" ]; then
            continue
        fi
        args_noecho+=("$arg")
    done

    local exists
    exists=$(psql "${args_noecho[@]}" -t -A -c "SELECT 1 FROM pg_database WHERE datname='${db}';")
    if [ "$exists" = "1" ]; then
        echo "Database ${db} already exists, skipping create"
        return 0
    fi

    if psql "${args[@]}" -c "CREATE DATABASE ${db};"; then
        echo "Database ${db} created successfully"
        return 0
    else
        echo "ERROR: Failed to create database: $db" >&2
        return 1
    fi
}

# Optional: drop database if requested by orchestrator
engine_drop_database() {
    export PGPASSWORD="${password:-}"
    local args=(
        -h"$pg_host"
        -p"$pg_port"
        -U"$user"
        -d"postgres"
        -q
        -a
        -P pager=off
        -v ON_ERROR_STOP=1
    )

    if psql "${args[@]}" -c "DROP DATABASE IF EXISTS ${db};"; then
        echo "Database ${db} dropped successfully"
        return 0
    else
        echo "ERROR: Failed to drop database: $db" >&2
        return 1
    fi
}
