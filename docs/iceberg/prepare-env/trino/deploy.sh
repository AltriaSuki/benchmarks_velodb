#!/bin/bash

# --- 1. Configuration ---
COORDINATOR="172.20.56.208"
WORKERS=("172.20.56.209" "172.20.56.210" "172.20.56.219")
ALL_NODES=($COORDINATOR "${WORKERS[@]}")

# Installation Paths
LOCAL_PKGS="/root/trino"
INSTALL_DIR="/opt"
JDK_TAR="openjdk-25.0.1_linux-x64_bin.tar.gz"
TRINO_TAR="trino-server-479.tar.gz"
TRINO_HOME="$INSTALL_DIR/trino-server-479"
JDK_HOME="$INSTALL_DIR/jdk-25.0.1"
DATA_DIR="/var/lib/trino/data"

# Memory settings (Calculated for 16G Coordinator and 128G Workers)
COORD_XMX="12G"
WORKER_XMX="102G"
MAX_QUERY_MEMORY="92GB"
MAX_TOTAL_MEMORY="184GB"

# SSH Options for automation and bypassing host key prompts
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

# --- 2. Stop all existing Trino services ---
echo "==============================================================="
echo ">>>> STOPPING ALL TRINO SERVICES"
echo "==============================================================="
for NODE in "${ALL_NODES[@]}"
do
    echo "Stopping Trino on $NODE..."
    ssh-keygen -f "/root/.ssh/known_hosts" -R "$NODE" > /dev/null 2>&1
    ssh $SSH_OPTS root@$NODE "$TRINO_HOME/bin/launcher stop" 2>/dev/null || true
done
echo "All services stopped."
exit

# --- 3. Execution ---
for NODE in "${ALL_NODES[@]}"
do
    echo "==============================================================="
    echo ">>>> DEPLOYING TO NODE: $NODE"
    echo "==============================================================="

    # STEP 0: Remove old host keys to prevent "Identification Changed" error
    ssh-keygen -f "/root/.ssh/known_hosts" -R "$NODE" > /dev/null 2>&1

    # STEP 1: System Optimization (Append to limits.conf)
    echo "[1/8] Setting system ulimits and disabling swap..."
    ssh $SSH_OPTS root@$NODE "
        swapoff -a
        if ! grep -q 'trino soft nofile' /etc/security/limits.conf; then
            cat <<EOF >> /etc/security/limits.conf
# Trino Resource Limits
* soft nofile 131072
* hard nofile 131072
* soft nproc 128000
* hard nproc 128000
root soft nofile 131072
root hard nofile 131072
root soft nproc 128000
root hard nproc 128000
EOF
        fi
    "

    # STEP 2: Transfer Binaries using rsync
    echo "[2/8] Syncing tarballs via rsync..."
    ssh $SSH_OPTS root@$NODE "mkdir -p $INSTALL_DIR"
    rsync -avz -e "ssh $SSH_OPTS" $LOCAL_PKGS/$JDK_TAR $LOCAL_PKGS/$TRINO_TAR root@$NODE:$INSTALL_DIR/

    # STEP 3: Extraction
    echo "[3/8] Extracting packages..."
    ssh $SSH_OPTS root@$NODE "cd $INSTALL_DIR && tar -zxf $JDK_TAR && tar -zxf $TRINO_TAR"

    # STEP 4: Setup Directories
    ssh $SSH_OPTS root@$NODE "mkdir -p $TRINO_HOME/etc/catalog && mkdir -p $DATA_DIR"

    # STEP 5: node.properties
    echo "[5/8] Creating node.properties..."
    NODE_ID=$(uuidgen 2>/dev/null || echo "trino-node-$NODE-${RANDOM}")
    ssh $SSH_OPTS root@$NODE "cat <<EOF > $TRINO_HOME/etc/node.properties
node.environment=production
node.id=$NODE_ID
node.data-dir=$DATA_DIR
EOF"

    # STEP 6: jvm.config (Tuned for your hardware)
    echo "[6/8] Configuring JVM for $( [[ "$NODE" == "$COORDINATOR" ]] && echo "Coordinator" || echo "Worker" )..."
    CURRENT_XMX=$( [[ "$NODE" == "$COORDINATOR" ]] && echo "$COORD_XMX" || echo "$WORKER_XMX" )

    ssh $SSH_OPTS root@$NODE "cat <<EOF > $TRINO_HOME/etc/jvm.config
-server
-Xmx$CURRENT_XMX
-XX:InitialRAMPercentage=80
-XX:MaxRAMPercentage=80
-XX:G1HeapRegionSize=32M
-XX:+ExplicitGCInvokesConcurrent
-XX:+ExitOnOutOfMemoryError
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-XX:ReservedCodeCacheSize=512M
-XX:PerMethodRecompilationCutoff=10000
-XX:PerBytecodeRecompilationCutoff=10000
-Djdk.attach.allowAttachSelf=true
-Djdk.nio.maxCachedBufferSize=2000000
-Dfile.encoding=UTF-8
-XX:+EnableDynamicAgentLoading
EOF"

    # STEP 7: config.properties
    echo "[7/8] Configuring Trino service roles..."
    IS_COORD=$( [[ "$NODE" == "$COORDINATOR" ]] && echo "true" || echo "false" )
    ssh $SSH_OPTS root@$NODE "cat <<EOF > $TRINO_HOME/etc/config.properties
coordinator=$IS_COORD
node-scheduler.include-coordinator=false
http-server.http.port=8080
query.max-memory=$MAX_QUERY_MEMORY
query.max-total-memory=$MAX_TOTAL_MEMORY
discovery.uri=http://$COORDINATOR:8080
EOF"

    # STEP 8: Nessie/Iceberg Connector
    echo "[8/8] Configuring Nessie Iceberg connector..."
    ssh $SSH_OPTS root@$NODE "cat <<EOF > $TRINO_HOME/etc/catalog/nessie.properties
connector.name=iceberg
fs.native-s3.enabled=true
iceberg.catalog.type=rest
iceberg.rest-catalog.security=NONE
iceberg.rest-catalog.uri=http://172.20.48.9:19120/iceberg/
iceberg.rest-catalog.warehouse=s3://bench-dataset/iceberg_warehouse
iceberg.rest-catalog.vended-credentials-enabled=false
s3.endpoint=http://oss-cn-beijing-internal.aliyuncs.com
s3.path-style-access=false
s3.region=cn-beijing
s3.aws-access-key=xxxx
s3.aws-secret-key=xxxx
EOF"

    # Final Step: Bind JDK and set launcher permissions
    ssh $SSH_OPTS root@$NODE "sed -i '1i export JAVA_HOME=$JDK_HOME' $TRINO_HOME/bin/launcher"

    # Start Trino service
    echo "[9/9] Starting Trino service..."
    ssh $SSH_OPTS root@$NODE "$TRINO_HOME/bin/launcher start"

    echo "✅ Node $NODE deployment complete."
done

echo "---------------------------------------------------------------"
echo "Cluster Deployment Finished!"
echo "Coordinator UI: http://$COORDINATOR:8080"
echo "Use '$TRINO_HOME/bin/launcher status' to check service status."