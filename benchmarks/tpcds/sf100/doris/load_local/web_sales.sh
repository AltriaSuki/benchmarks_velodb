#!/bin/bash
set -euo pipefail

table="web_sales"

# Doris connection (inherited from benchmark.yaml via benchmark.sh)
host="${fe_host:-${FE_HOST:-127.0.0.1}}"
http_port="${fe_http_port:-${FE_HTTP_PORT:-8030}}"
db="${db:-tpcds}"
user_="${user:-root}"
pass="${password:-${PASSWORD:-}}"

# Stream load knobs (override if needed)
timeout_s="${DORIS_STREAM_LOAD_TIMEOUT_S:-86400}"
max_filter_ratio="${DORIS_MAX_FILTER_RATIO:-0.1}"

url="http://${host}:${http_port}/api/${db}/${table}/_stream_load"
label="bench_${db}_${table}_${RANDOM}_$$"

echo "[INFO] Stream load ${db}.${table} from: /root/benchmarks/benchmarks/tpcds/sf100/postgresql/data/web_sales.dat"

sep_value='|'

headers=(
  # Doris Stream Load requires/benefits from Expect: 100-continue.
  -H "Expect: 100-continue"
  -H "format:csv"
  -H "column_separator:${sep_value}"
  -H "columns:ws_sold_date_sk,ws_sold_time_sk,ws_ship_date_sk,ws_item_sk,ws_bill_customer_sk,ws_bill_cdemo_sk,ws_bill_hdemo_sk,ws_bill_addr_sk,ws_ship_customer_sk,ws_ship_cdemo_sk,ws_ship_hdemo_sk,ws_ship_addr_sk,ws_web_page_sk,ws_web_site_sk,ws_ship_mode_sk,ws_warehouse_sk,ws_promo_sk,ws_order_number,ws_quantity,ws_wholesale_cost,ws_list_price,ws_sales_price,ws_ext_discount_amt,ws_ext_sales_price,ws_ext_wholesale_cost,ws_ext_list_price,ws_ext_tax,ws_coupon_amt,ws_ext_ship_cost,ws_net_paid,ws_net_paid_inc_tax,ws_net_paid_inc_ship,ws_net_paid_inc_ship_tax,ws_net_profit"
  -H "timeout:${timeout_s}"
  -H "max_filter_ratio:${max_filter_ratio}"
)

if [[ ! -f '/root/benchmarks/benchmarks/tpcds/sf100/postgresql/data/web_sales.dat' ]]; then
  echo "[ERROR] Source file not found: /root/benchmarks/benchmarks/tpcds/sf100/postgresql/data/web_sales.dat" >&2
  exit 1
fi

# Doris BE defaults to ~10GB max Stream Load body; load big files in chunks.
max_body_mb="${DORIS_STREAM_LOAD_BODY_MAX_MB:-10240}"
chunk_mb="${DORIS_STREAM_LOAD_CHUNK_MB:-8192}"

file_size_bytes="$(stat -c%s '/root/benchmarks/benchmarks/tpcds/sf100/postgresql/data/web_sales.dat')"
max_body_bytes="$((max_body_mb * 1024 * 1024))"

if (( file_size_bytes == 0 )); then
  echo "[ERROR] Source file is empty: /root/benchmarks/benchmarks/tpcds/sf100/postgresql/data/web_sales.dat" >&2
  exit 1
fi

do_curl() {
  local this_label="$1"
  local input_file="$2"

  if [[ "false" == "true" ]]; then
    sed 's/|$//' "$input_file" | \
      curl -sS --fail-with-body --location-trusted -u "${user_}:${pass}" -H "label:${this_label}" "${headers[@]}" -T - "$url"
  else
    curl -sS --fail-with-body --location-trusted -u "${user_}:${pass}" -H "label:${this_label}" "${headers[@]}" -T "$input_file" "$url"
  fi
}

if (( file_size_bytes > max_body_bytes )); then
  chunk_dir="${DORIS_STREAM_LOAD_CHUNK_DIR:-/tmp/doris_stream_load_chunks}/${db}/${table}_${label}"
  mkdir -p "$chunk_dir"
  cleanup() { rm -rf "$chunk_dir"; }
  trap cleanup EXIT
  # Split by line boundaries to avoid corrupting records.
  split -C "${chunk_mb}m" -d -a 4 '/root/benchmarks/benchmarks/tpcds/sf100/postgresql/data/web_sales.dat' "$chunk_dir/part_"

  # Load each chunk.
  for part in "$chunk_dir"/part_*; do
    part_suffix="$(basename "$part")"
    part_label="${label}_${part_suffix}"
    resp="$(do_curl "$part_label" "$part")"
    echo "$resp"
    echo "$resp" | grep -Eqi '"status"[[:space:]]*:[[:space:]]*"success"' || {
      echo "[ERROR] Stream load failed for ${db}.${table} (chunk: $part_suffix)" >&2
      exit 1
    }
  done
  exit 0
fi

resp="$(do_curl "$label" '/root/benchmarks/benchmarks/tpcds/sf100/postgresql/data/web_sales.dat')"

echo "$resp"
echo "$resp" | grep -Eqi '"status"[[:space:]]*:[[:space:]]*"success"' || {
  echo "[ERROR] Stream load failed for ${db}.${table}" >&2
  exit 1
}
