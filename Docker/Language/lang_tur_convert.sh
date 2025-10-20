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










# ======================================================
# === map.hpp DÜZENLEMELERİ ===
# ======================================================
sed -i 's/\<MSG_CONF_NAME_THA\>/MSG_CONF_NAME_TUR/' /opt/rathena/src/map/map.hpp










# ======================================================
# === map.cpp DÜZENLEMELERİ ===
# ======================================================
MAP_CPP="/opt/rathena/src/map/map.cpp"

# CRLF temizle (önlem)
sed -i 's/\r$//' "$MAP_CPP"

# 1️⃣ const tanımı düzelt
# const char *MSG_CONF_NAME_THA;  →  const char *MSG_CONF_NAME_TUR;
sed -i 's/\<const[[:space:]]\+char[[:space:]]\*\MSG_CONF_NAME_THA;/const char *MSG_CONF_NAME_TUR;/' "$MAP_CPP"

# 2️⃣ dizideki THA ifadesi düzelt
# MSG_CONF_NAME_THA,  →  MSG_CONF_NAME_TUR
sed -i 's/\<MSG_CONF_NAME_THA\>[[:space:]]*,/MSG_CONF_NAME_TUR,/' "$MAP_CPP"

# 3️⃣ dosya ataması düzelt
# MSG_CONF_NAME_THA = "conf/msg_conf/map_msg_tha.conf"; // Thai
# ↓↓↓
# MSG_CONF_NAME_TUR = "conf/msg_conf/map_msg_tur.conf"; // Turkish
sed -i 's/\<MSG_CONF_NAME_THA\>[[:space:]]*=[[:space:]]*"conf\/msg_conf\/map_msg_tha\.conf";[[:space:]]*\/\/[[:space:]]*Thai/MSG_CONF_NAME_TUR = "conf\/msg_conf\/map_msg_tur.conf";   \/\/ Turkish/' "$MAP_CPP"

# Kontrol çıktısı
echo "[OK] map.cpp düzenlendi:"
grep -n 'MSG_CONF_NAME_TUR' "$MAP_CPP" || true










# ======================================================
# === msg_conf.hpp DÜZENLEMELERİ 1 ===
# ======================================================
sed -i 's/^\([[:space:]]*#define[[:space:]]\+LANG_ENABLE[[:space:]]\+\)0x000/\10xFFF/' /opt/rathena/src/common/msg_conf.hpp
grep -n 'LANG_ENABLE' /opt/rathena/src/common/msg_conf.hpp










# === Dosya yolları ===
MSG_HPP="/opt/rathena/src/common/msg_conf.hpp"
MSG_CPP="/opt/rathena/src/common/msg_conf.cpp"

# --- CRLF temizliği ---
sed -i 's/\r$//' "$MSG_HPP"
sed -i 's/\r$//' "$MSG_CPP"

# ======================================================
# === msg_conf.hpp DÜZENLEMELERİ 2 ===
# ======================================================

# 1️⃣ LANG_THA satırını LANG_TUR ve Türkçe yorumla değiştir
sed -i 's/\<LANG_THA\>[[:space:]]*=[[:space:]]*0x100[[:space:]]*,*/LANG_TUR = 0x100,   \/\/ Turkish/' "$MSG_HPP"

# 2️⃣ Yorumlarda Thai → Turkish
sed -i 's|//[[:space:]]*Thai|// Turkish|g' "$MSG_HPP"

# 3️⃣ LANG_ENABLE değerini 0xFFF yap
sed -i 's/^\(#define[[:space:]]\+LANG_ENABLE[[:space:]]\+\).*/\10xFFF/' "$MSG_HPP"

# 4️⃣ THA → TUR genel dönüşümü
sed -i 's/\<THA\>/TUR/g' "$MSG_HPP"

# Kontrol çıktısı
echo "[OK] msg_conf.hpp düzenlendi:"
grep -n 'LANG_' "$MSG_HPP" | tail -n 10 || true


# ======================================================
# === msg_conf.cpp DÜZENLEMELERİ ===
# ======================================================

# 1️⃣ 'tha' kontrollerini 'tur' olarak değiştir
sed -i 's/!strncmpi(langtype,[[:space:]]*"tha"/!strncmpi(langtype, "tur"/g' "$MSG_CPP"

# 2️⃣ Thai (THA) → Turkish (TUR)
sed -i 's/Thai (THA)/Turkish (TUR)/g' "$MSG_CPP"

# 3️⃣ THA → TUR dönüşümü (kalan tanımlar)
sed -i 's/\<THA\>/TUR/g' "$MSG_CPP"

# 4️⃣ case kısmında Turkish (TUR) yoksa ekle
grep -q 'Turkish (TUR)' "$MSG_CPP" || \
sed -i '/case[[:space:]]*9:[[:space:]]*return[[:space:]]*"Turkish (TUR)";/!{/case[[:space:]]*9:[[:space:]]*return[[:space:]]*"Thai (THA)";/a\		case 9: return "Turkish (TUR)";}' "$MSG_CPP"

# Kontrol çıktısı
echo
echo "[OK] msg_conf.cpp düzenlendi:"
grep -n 'Turkish' "$MSG_CPP" || true
grep -n 'TUR' "$MSG_CPP" | tail -n 10 || true

# === Derleme önerisi ===
echo
echo "✅ Dönüşüm tamamlandı."
echo "Yeniden derlemek için:"
echo "cd /opt/rathena && make clean && make server"
