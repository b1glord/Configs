#!/usr/bin/env bash
set -euo pipefail


echo "=== [1/4] Klasör ve Dosya Hazırlığı ==="

CONF_DIR="/opt/rathena/conf/msg_conf"
CONF_IMPORT_DIR="$CONF_DIR/import"
MAP_DIR="/opt/rathena/src/map"
MAP_HPP="$MAP_DIR/map.hpp"
MAP_CPP="$MAP_DIR/map.cpp"

# 1) Klasör oluştur
mkdir -p "$CONF_IMPORT_DIR"

# 2) map_msg_tur.conf oluştur (yoksa ENG'den kopyala)
if [[ ! -f "$CONF_DIR/map_msg_tur.conf" ]]; then
  cp "$CONF_DIR/map_msg.conf" "$CONF_DIR/map_msg_tur.conf"
  echo "[+] map_msg_tur.conf oluşturuldu (ENG'den kopyalandı)"
fi

# 3) import satırını Türkçe import dosyasına yönlendir
sed -i 's|import:[[:space:]]*conf/msg_conf/import/map_msg_eng_conf\.txt|import: conf/msg_conf/import/map_msg_tur_conf.txt|' \
  "$CONF_DIR/map_msg_tur.conf"

# 4) TR import dosyasını indir
wget -qO "$CONF_IMPORT_DIR/map_msg_tur_conf.txt" \
'https://raw.githubusercontent.com/b1glord/Configs/refs/heads/master/Docker/conf/msg_conf/import/map_msg_tur_conf.txt'
echo "[+] map_msg_tur_conf.txt indirildi."











# === Dosya yolları ===
MSG_HPP="/opt/rathena/src/common/msg_conf.hpp"
MSG_CPP="/opt/rathena/src/common/msg_conf.cpp"

# --- CRLF temizliği ---
sed -i 's/\r$//' "$MSG_HPP"
sed -i 's/\r$//' "$MSG_CPP"

# ======================================================
# === msg_conf.hpp DÜZENLEMELERİ ===
# ======================================================

# 1️⃣ Yorumlarda Thai → Turkish
sed -i 's|//[[:space:]]*Thai|// Turkish|g' "$MSG_HPP"

# 2️⃣ LANG_THA satırını Türkçe olarak değiştir
sed -i 's/\<LANG_THA\>[[:space:]]*=[[:space:]]*0x100[[:space:]]*,[[:space:]]*\/\/[[:space:]]*Thai/LANG_THA = 0x100,   \/\/ Turkish/' "$MSG_HPP"

# 3️⃣ LANG_ENABLE değerini 0xFFF yap
sed -i 's/^\(#define[[:space:]]\+LANG_ENABLE[[:space:]]\+\).*/\10xFFF/' "$MSG_HPP"

# 4️⃣ "THA" tanımlarını "TUR" ile değiştir
sed -i 's/\<THA\>/TUR/g' "$MSG_HPP"

# Kontrol çıktısı
echo "[OK] msg_conf.hpp düzenlendi:"
grep -n 'LANG_' "$MSG_HPP" | tail -n 10 || true


# ======================================================
# === msg_conf.cpp DÜZENLEMELERİ ===
# ======================================================

# 1️⃣ Fonksiyon içinde 'tha' kontrolünü 'tur' olarak değiştir
sed -i 's/!strncmpi(langtype,[[:space:]]*"tha"/!strncmpi(langtype, "tur"/g' "$MSG_CPP"

# 2️⃣ Thai → Turkish dönüşümleri
sed -i 's/Thai (THA)/Turkish (TUR)/g' "$MSG_CPP"

# 3️⃣ Tekil "THA" → "TUR" dönüşümleri (dizi, enum, yorum vb.)
sed -i 's/\<THA\>/TUR/g' "$MSG_CPP"

# 4️⃣ case kısmında Turkish (TUR) ekli (güvenlik amaçlı)
grep -q 'Turkish (TUR)' "$MSG_CPP" || \
sed -i '/case[[:space:]]*9:[[:space:]]*return[[:space:]]*"Thai (THA)";/a\		case 9: return "Turkish (TUR)";' "$MSG_CPP"

# Kontrol çıktısı
echo
echo "[OK] msg_conf.cpp düzenlendi:"
grep -n 'Turkish' "$MSG_CPP" || true
grep -n 'TUR' "$MSG_CPP" | tail -n 10 || true

# === Derleme önerisi ===
echo
echo "✅ Değişiklikler tamamlandı."
echo "Şimdi yeniden derleyin:"
echo "cd /opt/rathena && make clean && make server"
