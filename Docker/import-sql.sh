#!/usr/bin/env bash
set -euo pipefail

# .env degiskenleri compose ile zaten container'a gelir.
# Yine de elde calistirma icin opsiyonel .env oku:
ENV_FILE="${ENV_FILE:-/opt/rathena/.env}"
if [ -f "$ENV_FILE" ]; then
  set -a; . "$ENV_FILE"; set +a
fi

: "${MYSQL_ROOT_PASSWORD:? .env icinde MYSQL_ROOT_PASSWORD gerekli}"

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-3306}"

DB_NAME="${DB_NAME:-ragnarok}"
LOG_DB_NAME="${LOG_DB_NAME:-ragnaroklog}"

# SQL set secimi: minimal | re | pre
SQL_MODE="${SQL_MODE:-minimal}"

# rAthena sql klasoru (senin mount yapina gore)
SQL_DIR="${SQL_DIR:-/opt/rathena/rathena/sql-files}"

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

echo ">> DB olustur"
mysql_stmt "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql_stmt "CREATE DATABASE IF NOT EXISTS \`$LOG_DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Uygulama kullanicisi (opsiyonel)
if [ -n "${DB_USER:-}" ] && [ -n "${DB_PASS:-}" ]; then
  echo ">> Kullanici ve yetki: $DB_USER"
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
    echo ">> SQL_MODE=minimal (main.sql + logs.sql)"
    ;;
  re)
    # Renewal icin tipik siralama (dosya yoksa atlar)
    FILES=(
      "web.sql"
      "item_db_re.sql" "item_db_re_equip.sql" "item_db_re_etc.sql" "item_db_re_usable.sql" "item_db2_re.sql"
      "mob_db_re.sql" "mob_db2_re.sql"
      "mob_skill_db_re.sql" "mob_skill_db2_re.sql"
      "roulette_default_data.sql" "roulette.sql" "roulette_mutual.sql"
      "customaccount.sql" "custom.sql"
    )
    for f in "${FILES[@]}"; do mysql_file "$DB_NAME" "$SQL_DIR/$f"; done
    ;;
  pre)
    # Pre-renewal icin tipik siralama
    FILES=(
      "web.sql"
      "item_db.sql" "item_db_equip.sql" "item_db_etc.sql" "item_db_usable.sql" "item_db2.sql"
      "mob_db.sql" "mob_db2.sql"
      "mob_skill_db.sql" "mob_skill_db2.sql"
      "roulette_default_data.sql" "roulette.sql" "roulette_mutual.sql"
      "customaccount.sql" "custom.sql"
    )
    for f in "${FILES[@]}"; do mysql_file "$DB_NAME" "$SQL_DIR/$f"; done
    ;;
  *)
    echo "HATA: Gecersiz SQL_MODE: $SQL_MODE (minimal|re|pre)"; exit 1;;
esac

echo ">> Tamam."
