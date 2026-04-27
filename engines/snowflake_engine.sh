#!/bin/bash
# Snowflake Database Engine Implementation
# 
# This engine implements the benchmark framework interface for Snowflake databases.
# It requires the following environment variables to be set:
# - account: Snowflake account identifier  
# - user: Snowflake username
# - role: Snowflake role
# - password: Snowflake password
# - warehouse: Snowflake warehouse name
# - db: Snowflake database name
# - schema: Snowflake schema name

# Source the interface for utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/interface.sh"

# Load JDBC utilities
source "$(dirname "${BASH_SOURCE[0]}")/../lib/jdbc_utils.sh"

# Load client utilities
source "$(dirname "${BASH_SOURCE[0]}")/../lib/client_utils.sh"

# Snowsql command path (will be set in engine_init)
SNOWSQL_CMD=""

# 1. Initialize and check Snowflake dependencies
engine_init() {
    echo "Initializing Snowflake engine..."
    # Initialize Snowflake JDBC driver for JMeter if needed
    if [[ "${jmeter:-}" == "true" ]] && [ -n "${JMETER_HOME:-}" ]; then
        export JVM_ARGS="--add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED"
        init_snowflake_jdbc_driver
    fi
    
    # Initialize snowsql client (download if needed)
    if ! init_snowflake_client; then
        echo "ERROR: Failed to initialize snowsql client" >&2
        return 1
    fi
    
    # Check for snowsql: use system version if available, otherwise use tools directory
    if command -v snowsql >/dev/null 2>&1; then
        SNOWSQL_CMD="snowsql"
    elif [ -x "${SCRIPT_DIR}/../tools/snowsql_dir/snowsql" ]; then
        SNOWSQL_CMD="${SCRIPT_DIR}/../tools/snowsql_dir/snowsql"
        echo "Using snowsql from tools directory: $SNOWSQL_CMD"
    else
        echo "ERROR: snowsql not found in system PATH or tools directory" >&2
        echo "Please install snowsql or place it in the tools directory." >&2
        return 1
    fi
    
    # Check required environment variables
    local missing_vars=()
    for var in account user role password warehouse db schema; do
        if [ -z "${!var:-}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "ERROR: Missing required environment variables: ${missing_vars[*]}" >&2
        echo "Please set these variables in your benchmark.yaml configuration." >&2
        return 1
    fi
    
    echo "Initialized Snowflake: $account/$db"
    return 0
}

# 2. Execute a SQL file using snowsql
engine_run_sql_file() {
    local sql_file="$1"
    
    if [ ! -f "$sql_file" ]; then
        echo "ERROR: SQL file not found: $sql_file" >&2
        return 1
    fi
    
    # Set password environment variable for snowsql
    export SNOWSQL_PWD="${password}"
    export SNOWFLAKE_PASSWORD="${password}"
    
    # Execute the SQL file
    # Note: Using -o output_format=csv to suppress extra output that might interfere with timing
    if "$SNOWSQL_CMD" \
        -a "$account" \
        -u "$user" \
        -r "$role" \
        -w "$warehouse" \
        -d "$db" \
        -s "$schema" \
        -f "$sql_file"; then
        return 0
    else
        echo "ERROR: Failed to execute SQL file: $sql_file" >&2
        return 1
    fi
}

# 2.1. Execute a SQL statement using snowsql
engine_run_sql() {
    local db="$1"
    local sql_statement="$2"
    
    if [ -z "$sql_statement" ]; then
        echo "ERROR: SQL statement cannot be empty" >&2
        return 1
    fi
    
    # Set password environment variable for snowsql
    export SNOWSQL_PWD="${password}"
    export SNOWFLAKE_PASSWORD="${password}"
    
    local args=(
        -a "$account"
        -u "$user"
        -r "$role"
        -w "$warehouse"
    )
    [ -n "$db" ] && args+=(-d "$db")
    [ -n "$schema" ] && args+=(-s "$schema")
    
    # Execute the SQL statement
    if "$SNOWSQL_CMD" "${args[@]}" -q "$sql_statement"; then
        return 0
    else
        echo "ERROR: Failed to execute SQL statement: $sql_statement" >&2
        return 1
    fi
}

# 3. Generate JDBC DataSource XML configuration for Snowflake
engine_get_jdbc_datasource() {
    # Escape any special characters in the password
    local escaped_password
    escaped_password=$(xml_escape "$password")
    
    cat << EOF
<JDBCDataSource guiclass="TestBeanGUI" testclass="JDBCDataSource" testname="JDBC Connection Configuration" enabled="true">
  <boolProp name="autocommit">true</boolProp>
  <stringProp name="checkQuery">SELECT 1</stringProp>
  <stringProp name="connectionAge">5000</stringProp>
  <stringProp name="connectionProperties"></stringProp>
  <stringProp name="dataSource">Snowflake</stringProp>
  <stringProp name="dbUrl">jdbc:snowflake://${account}.snowflakecomputing.com/?user=${user}&amp;warehouse=${warehouse}&amp;db=${db}&amp;schema=${schema}&amp;password=${escaped_password}</stringProp>
  <stringProp name="driver">net.snowflake.client.jdbc.SnowflakeDriver</stringProp>
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
    echo "Snowflake"
}

# Optional: Fetch engine version
engine_get_version() {
    export SNOWSQL_PWD="${password}"
    export SNOWFLAKE_PASSWORD="${password}"
    local args=(
        -a "$account"
        -u "$user"
        -r "$role"
        -w "$warehouse"
        -d "$db"
        -s "$schema"
        -o output_format=csv
        -o header=false
        -o timing=false
        -o friendly=false
    )
    local version
    version="$("$SNOWSQL_CMD" "${args[@]}" -q "SELECT CURRENT_VERSION();" 2>/dev/null || true)"
    echo "$version" | head -n 1
}

# Optional: Fetch total data size in bytes
engine_get_data_size_bytes() {
    export SNOWSQL_PWD="${password}"
    export SNOWFLAKE_PASSWORD="${password}"
    local args=(
        -a "$account"
        -u "$user"
        -r "$role"
        -w "$warehouse"
        -d "$db"
        -s "$schema"
        -o output_format=csv
        -o header=false
        -o timing=false
        -o friendly=false
    )
    local size
    size="$("$SNOWSQL_CMD" "${args[@]}" -q "SELECT COALESCE(SUM(BYTES),0) FROM ${db}.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '${schema}';" 2>/dev/null || true)"
    echo "$size" | head -n 1
}

# Helper function to create database (used in DDL setup)
engine_create_database() {
    # SNOWSQL_PWD="$password"
    export SNOWSQL_PWD="${password}"
    export SNOWFLAKE_PASSWORD="${password}"
    
    local args=(
        -a "$account"
        -u "$user"
        -r "$role"
        -w "$warehouse"
    )

    local do_drop="${drop_database:-true}"

    if [ "$do_drop" = "true" ]; then
        if  "$SNOWSQL_CMD" "${args[@]}" -q "DROP DATABASE IF EXISTS ${db}; CREATE DATABASE ${db};" ; then
            return 0
        else
            echo "ERROR: Failed to create database: $db" >&2
            return 1
        fi
    fi

    if "$SNOWSQL_CMD" "${args[@]}" -q "CREATE DATABASE IF NOT EXISTS ${db};" ; then
        return 0
    else
        echo "ERROR: Failed to create database: $db" >&2
        return 1
    fi
}

# Optional: drop database if requested by orchestrator
engine_drop_database() {
    export SNOWSQL_PWD="${password}"
    export SNOWFLAKE_PASSWORD="${password}"

    local args=(
        -a "$account"
        -u "$user"
        -r "$role"
        -w "$warehouse"
    )

    if "$SNOWSQL_CMD" "${args[@]}" -q "DROP DATABASE IF EXISTS ${db};" ; then
        return 0
    else
        echo "ERROR: Failed to drop database: $db" >&2
        return 1
    fi
}
