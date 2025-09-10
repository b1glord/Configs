#!/usr/bin/env bash
set -euo pipefail

# Opsiyonel: .env oku (compose calistiriyorsa zaten env var)
ENV_FILE="${ENV_FILE:-/opt/rathena/.env}"
[ -f "$ENV_FILE" ] && { set -a; . "$ENV_FILE"; set +a; }

: "${MYSQL_ROOT_PASSWORD:? .env icinde MYSQL_ROOT_PASSWORD gerekli}"

DB_HOST="${DB_HOST}"
DB_PORT="${DB_PORT}"
DB_NAME="${DB_NAME}"
LOG_DB_NAME="${LOG_DB_NAME}"
SQL_DIR="${SQL_DIR:-/opt/rathena/rathena/sql-files}"

# ----- MOD SECIMI: arguman -> env -> prompt -----
MODE_INPUT="${1:-${SQL_MODE:-}}"
# normalize
MODE_INPUT="$(echo "${MODE_INPUT:-}" | tr '[:upper:]' '[:lower:]')"
case "$MODE_INPUT" in
  --re|re)          SQL_MODE="re" ;;
  --pre|pre|pre-re) SQL_MODE="pre" ;;
  --minimal|minimal)SQL_MODE="minimal" ;;
  "" )
    echo
    read -rp "SQL modu sec (re / pre) [bos = minimal]: " ans || true
    ans="$(echo "${ans:-}" | tr '[:upper:]' '[:lower:]')"
    case "$ans" in
      re)        SQL_MODE="re" ;;
      pre|pre-re)SQL_MODE="pre" ;;
      *)         SQL_MODE="minimal" ;;
    esac
    ;;
  *)
    echo "Gecersiz secim: $MODE_INPUT (kullan: --re | --pre | --minimal)"; exit 1;;
esac

echo ">> SQL_MODE = $SQL_MODE"
echo ">> DB_HOST=$DB_HOST DB_PORT=$DB_PORT DB_NAME=$DB_NAME LOG_DB_NAME=$LOG_DB_NAME"
echo ">> SQL_DIR=$SQL_DIR"
echo

mysql_stmt() {
  mysql -h "$DB_HOST" -P "$DB_PORT" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "$1"
}
mysql_file() {
  local db="$1"; local file="$2"
  if [ ! -f "$file" ]; then
    echo ">> yok: $(basename "$file") (atlanacak)"
    return 0
  fi
  echo ">> import: $(basename "$file") -> $db"
  mysql -h "$DB_HOST" -P "$DB_PORT" -uroot -p"$MYSQL_ROOT_PASSWORD" "$db" < "$file"
}

echo ">> DB olustur/varsa atla"
mysql_stmt "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql_stmt "CREATE DATABASE IF NOT EXISTS \`$LOG_DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Opsiyonel uygulama kullanicisi
if [ -n "${DB_USER:-}" ] && [ -n "${DB_PASS:-}" ]; then
  echo ">> Kullanici/Yetki: $DB_USER"
  mysql_stmt "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
              GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '${DB_USER}'@'%';
              GRANT ALL PRIVILEGES ON \`$LOG_DB_NAME\`.* TO '${DB_USER}'@'%';
              FLUSH PRIVILEGES;"
fi

# Zorunlu dosyalar
mysql_file "$DB_NAME"     "$SQL_DIR/main.sql"
mysql_file "$LOG_DB_NAME" "$SQL_DIR/logs.sql"

case "$SQL_MODE" in
  minimal)
    echo ">> minimal bitti (main.sql + logs.sql)";;
  re)
    for f in \
      "web.sql" \
      "item_db_re.sql" "item_db_re_equip.sql" "item_db_re_etc.sql" "item_db_re_usable.sql" "item_db2_re.sql" \
      "mob_db_re.sql" "mob_db2_re.sql" \
      "mob_skill_db_re.sql" "mob_skill_db2_re.sql" \
      "roulette_default_data.sql" "roulette.sql" "roulette_mutual.sql" \
      "customaccount.sql" "custom.sql"
    do mysql_file "$DB_NAME" "$SQL_DIR/$f"; done
    ;;
  pre)
    for f in \
      "web.sql" \
      "item_db.sql" "item_db_equip.sql" "item_db_etc.sql" "item_db_usable.sql" "item_db2.sql" \
      "mob_db.sql" "mob_db2.sql" \
      "mob_skill_db.sql" "mob_skill_db2.sql" \
      "roulette_default_data.sql" "roulette.sql" "roulette_mutual.sql" \
      "customaccount.sql" "custom.sql"
    do mysql_file "$DB_NAME" "$SQL_DIR/$f"; done
    ;;
esac

echo ">> Tamam."
