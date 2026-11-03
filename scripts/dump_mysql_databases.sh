#!/usr/bin/env bash
set -Eeuo pipefail

# Dumps selected MySQL databases as compressed logical backups.
# Usage:
#   ./dump_mysql_databases.sh
# Optional env vars:
#   MYSQL_CNF=/root/.my.cnf
#   BACKUP_DIR=/var/backups/mysql
#   RETENTION_DAYS=14
#
# Recommended credentials file format (chmod 600):
# [client]
# host=127.0.0.1
# user=root
# password=your_password_here

MYSQL_CNF="${MYSQL_CNF:-/root/.my.cnf}"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/mysql}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
DATE_UTC="$(date -u +%Y%m%dT%H%M%SZ)"

DBS=(ctc joom4 newsletter triphub hutbooking tripreports)

if ! command -v mysqldump >/dev/null 2>&1; then
  echo "ERROR: mysqldump not found in PATH." >&2
  exit 1
fi

if ! command -v mysql >/dev/null 2>&1; then
  echo "ERROR: mysql client not found in PATH." >&2
  exit 1
fi

if ! command -v gzip >/dev/null 2>&1; then
  echo "ERROR: gzip not found in PATH." >&2
  exit 1
fi

if [[ ! -f "$MYSQL_CNF" ]]; then
  echo "ERROR: MySQL credentials file not found: $MYSQL_CNF" >&2
  exit 1
fi

mkdir -p "$BACKUP_DIR"

if ! mysql --defaults-extra-file="$MYSQL_CNF" -NBe "SELECT 1" >/dev/null 2>&1; then
  echo "ERROR: Unable to connect to MySQL using $MYSQL_CNF" >&2
  exit 1
fi

CHECKSUM_FILE="$BACKUP_DIR/checksums_${DATE_UTC}.sha256"
: > "$CHECKSUM_FILE"

for DB in "${DBS[@]}"; do
  if ! mysql --defaults-extra-file="$MYSQL_CNF" -NBe "SHOW DATABASES LIKE '$DB'" | grep -Fxq "$DB"; then
    echo "ERROR: Database not found: $DB" >&2
    exit 1
  fi

  OUT_FILE="$BACKUP_DIR/${DB}_${DATE_UTC}.sql.gz"
  echo "Dumping $DB -> $OUT_FILE"

  mysqldump \
    --defaults-extra-file="$MYSQL_CNF" \
    --databases "$DB" \
    --no-tablespaces \
    --single-transaction \
    --quick \
    --routines \
    --events \
    --triggers \
    --hex-blob \
    --set-gtid-purged=OFF \
    | gzip -1 > "$OUT_FILE"

  sha256sum "$OUT_FILE" >> "$CHECKSUM_FILE"
done

# Remove old backup files.
find "$BACKUP_DIR" -maxdepth 1 -type f -name '*.sql.gz' -mtime +"$RETENTION_DAYS" -delete
find "$BACKUP_DIR" -maxdepth 1 -type f -name 'checksums_*.sha256' -mtime +"$RETENTION_DAYS" -delete

echo "Done. Backups in: $BACKUP_DIR"
echo "Checksums file: $CHECKSUM_FILE"
