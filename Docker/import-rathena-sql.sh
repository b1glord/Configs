#!/usr/bin/env bash
set -euo pipefail

# rAthena SQL toplu yukleyici
# Calisma yeri: repo kokunde (./rathena/sql-files mevcut)
# Docker: rathena_db (MariaDB) container'i calisiyor olmali

# ---- Ayarlar / Varsayilanlar ----
ENV_FILE="${ENV_FILE:-.env}"

# .env'den degisken cek (varsa)
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
fi

# DB isimleri ve sifreler
DB_HOST_DOCKER="${DB_HOST_DOCKER:-db}"              # rAthena ic ag adi (bilgi icin)
DB_PORT_DOCKER="${DB_PORT_DOCKER:-3306}"            # rAthena ic ag portu (bilgi icin)
DB_NAME="${DB_NAME:-ragnarok}"
LOG_DB_NAME="${LOG_DB_NAME:-ragnaroklog}"

# MariaDB root bilgisi (container icinde var)
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD gerekli (.env icinde tanimla)}"

# SQL modu:
# minimal  -> sadece main.sql (DB_NAME) + logs.sql (LOG_DB_NAME)
# re       -> minimal + *_re.sql veri tablolarini ekler (SQL DB kullaniyorsan)
# pre      -> minimal + pre-re tablolarini ekler
SQL_MODE="${SQL_MODE:-minimal}"  # minimal | re | pre

# rAthena sql-files yolu (host tarafinda)
SQL_DIR="${SQL_DIR:-./rathena/sql-files}"

# Docker container adi
DB_CONT="${DB_CONT:-rathena_db}"

# ---- Yardimci fonksiyonlar ----
die() { echo "HATA: $*" >&2; exit 1; }

need_file() { [ -f "$1" ] || die "Dosya yok: $1"; }

mysql_exec() {
  local db="$1"; shift
  local file="$1"; shift
  echo ">> Import: $(basename "$file") -> $db"
  # STDIN ile icerigi container'a veriyoruz
  docker exec -i "$DB_CONT" sh -c "exec mysql -uroot -p\"\$MYSQL_ROOT_PASSWORD\" \"$db\"" < "$file"
}

mysql_stmt() {
  local stmt="$1"
  docker exec -i "$DB_CONT" sh -c "exec mysql -uroot -p\"\$MYSQL_ROOT_PASSWORD\" -e \"$stmt\""
}

# ---- Kontroller ----
command -v docker >/dev/null || die "docker bulunamadi"
docker ps --format '{{.Names}}' | grep -qx "$DB_CONT" || die "Container calismiyor: $DB_CONT"
[ -d "$SQL_DIR" ] || die "Klasor bulunamadi: $SQL_DIR"

# ---- DB olustur / yetki ver ----
echo ">> DB olusturma ve yetkiler"
mysql_stmt "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql_stmt "CREATE DATABASE IF NOT EXISTS \`$LOG_DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Opsiyonel: uygulama kullanicisi varsa tanimla (ENV'den)
if [ -n "${MYSQL_USER:-}" ] && [ -n "${MYSQL_PASSWORD:-}" ]; then
  mysql_stmt "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
  mysql_stmt "GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${MYSQL_USER}'@'%';"
  mysql_stmt "GRANT ALL PRIVILEGES ON \`${LOG_DB_NAME}\`.* TO '${MYSQL_USER}'@'%';"
  mysql_stmt "FLUSH PRIVILEGES;"
fi

# ---- Zorunlu importlar ----
MAIN_SQL="$SQL_DIR/main.sql"
LOGS_SQL="$SQL_DIR/logs.sql"
need_file "$MAIN_SQL"
need_file "$LOGS_SQL"

mysql_exec "$DB_NAME" "$MAIN_SQL"
mysql_exec "$LOG_DB_NAME" "$LOGS_SQL"

# ---- Opsiyonel veri tablolarini ekle (SQL_MODE) ----
case "$SQL_MODE" in
  minimal)
    echo ">> SQL_MODE=minimal (yalniz main.sql ve logs.sql yuklendi)"
    ;;
  re)
    # Renewal tablolar
    FILES=(
      "$SQL_DIR/item_db_re.sql"
      "$SQL_DIR/mob_db_re.sql"
      "$SQL_DIR/mob_skill_db_re.sql"
      # kullanacaksan digerleri:
      # "$SQL_DIR/item_cash_db_re.sql"
      # "$SQL_DIR/roulette.sql"
      # "$SQL_DIR/roulette_mutual.sql"
      # "$SQL_DIR/web.sql"
    )
    for f in "${FILES[@]}"; do
      if [ -f "$f" ]; then mysql_exec "$DB_NAME" "$f"; else echo ">> Atlaniyor (yok): $(basename "$f")"; fi
    done
    ;;
  pre)
    # Pre-renewal tablolar
    FILES=(
      "$SQL_DIR/item_db.sql"
      "$SQL_DIR/mob_db.sql"
      "$SQL_DIR/mob_skill_db.sql"
      # kullanacaksan digerleri:
      # "$SQL_DIR/item_cash_db.sql"
      # "$SQL_DIR/roulette.sql"
      # "$SQL_DIR/roulette_mutual.sql"
      # "$SQL_DIR/web.sql"
    )
    for f in "${FILES[@]}"; do
      if [ -f "$f" ]; then mysql_exec "$DB_NAME" "$f"; else echo ">> Atlaniyor (yok): $(basename "$f")"; fi
    done
    ;;
  *)
    die "Gecersiz SQL_MODE: $SQL_MODE (minimal|re|pre)"
    ;;
esac

echo ">> Bitti."
