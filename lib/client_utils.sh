#!/bin/bash
# Client Utilities
#
# This library provides functions to initialize database client tools.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="${SCRIPT_DIR}/../tools"

# Initialize Snowflake client (snowsql)
# Extracts snowsql from pre-packaged archive in tools directory
init_snowflake_client() {
    local snowsql_dir="${TOOLS_DIR}/snowsql_dir"
    local snowsql_path="${snowsql_dir}/snowsql"
    
    # Check if snowsql already exists in tools directory
    if [ -x "$snowsql_path" ]; then
        echo "snowsql already exists in tools directory"
        return 0
    fi
    
    # Check if snowsql is available in system PATH
    if command -v snowsql >/dev/null 2>&1; then
        echo "snowsql found in system PATH"
        return 0
    fi
    
    echo "Extracting snowsql to tools directory..."
    
    local arch_type="x86_64"
    # Find the snowsql archive for this architecture
    local archive_path="${TOOLS_DIR}/snowsql-linux-${arch_type}.zip"
    if [ ! -f "$archive_path" ]; then
        # Try alternative naming
        archive_path=$(find "$TOOLS_DIR" -name "*snowsql*${arch_type}*.zip" 2>/dev/null | head -1)
    fi
    
    if [ -z "$archive_path" ] || [ ! -f "$archive_path" ]; then
        echo "ERROR: snowsql archive not found for architecture: $arch_type" >&2
        echo "Please place snowsql-linux-${arch_type}.zip in ${TOOLS_DIR}" >&2
        return 1
    fi
    
    # Create snowsql directory
    mkdir -p "$snowsql_dir"
    
    # Extract snowsql
    echo "Extracting from: $archive_path"
    if ! unzip -o "$archive_path" -d "$snowsql_dir"; then
        echo "ERROR: Failed to extract snowsql archive" >&2
        return 1
    fi
    
    # Make executable
    chmod +x "$snowsql_path" 2>/dev/null
    
    # Verify installation
    if [ -x "$snowsql_path" ]; then
        echo "snowsql extracted successfully to: $snowsql_path"
        return 0
    else
        echo "ERROR: snowsql extraction failed" >&2
        return 1
    fi
}

# Initialize MySQL client
# Placeholder for future implementation
init_mysql_client() {
    if command -v mysql >/dev/null 2>&1; then
        echo "mysql client found in system PATH"
        return 0
    fi
    
    echo "ERROR: mysql client not found. Please install mysql-client package." >&2
    return 1
}
