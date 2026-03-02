#!/usr/bin/env bash

set -euo pipefail

DB_USER="sep"
DB_NAME="xdpdb"
DB_HOST="localhost"

usage() {
  echo "Usage: $0 <server1|server2> <config_id>"
  echo
  echo "  server1  -> dùng folder sql_options"
  echo "  server2  -> dùng folder sql_options_server2"
  echo "  config_id: 1..14 (ứng với từng option)"
  echo
  echo "Ví dụ:"
  echo "  $0 server1 9   # L3 GCM 256 trên server1"
  echo "  $0 server2 9   # L3 GCM 256 trên server2"
}

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

ROLE="$1"
CONFIG_ID="$2"

case "${ROLE}" in
  server1)
    SQL_DIR="sql_options"
    ;;
  server2)
    SQL_DIR="sql_options_server2"
    ;;
  *)
    echo "Invalid role: ${ROLE}"
    usage
    exit 1
    ;;
esac

if ! [[ "${CONFIG_ID}" =~ ^[0-9]+$ ]]; then
  echo "config_id must be a number (1..14)"
  exit 1
fi

ID_PADDED=$(printf "%02d" "${CONFIG_ID}")
SQL_FILE_GLOB="${SQL_DIR}/${ID_PADDED}_*.sql"

SQL_FILE=$(ls ${SQL_FILE_GLOB} 2>/dev/null || true)

if [ -z "${SQL_FILE}" ]; then
  echo "Không tìm thấy file SQL cho ID=${CONFIG_ID} trong folder ${SQL_DIR}"
  echo "Đã thử pattern: ${SQL_FILE_GLOB}"
  exit 1
fi

echo "=== XDP LOAD OPTION ==="
echo "Role:      ${ROLE}"
echo "DB user:   ${DB_USER}"
echo "DB name:   ${DB_NAME}"
echo "Host:      ${DB_HOST}"
echo "Config ID: ${CONFIG_ID}"
echo "SQL file:  ${SQL_FILE}"
echo

read -s -p "PostgreSQL password for user ${DB_USER}: " PGPASSWORD
echo
export PGPASSWORD

echo "[1/2] Import SQL for config_id=${CONFIG_ID}"
psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -f "${SQL_FILE}"

echo "[2/2] Notify daemon to use config_id=${CONFIG_ID}"
psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT pg_notify('xdp_start', '${CONFIG_ID}');"

echo
echo "Đã load option ID=${CONFIG_ID} cho ${ROLE} và gửi NOTIFY. Kiểm tra log của daemon để xác nhận."

unset PGPASSWORD

