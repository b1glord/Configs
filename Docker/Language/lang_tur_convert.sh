#!/usr/bin/env bash
set -euo pipefail

echo "=== [1/4] Klasor ve Dosya Hazirligi ==="

CONF_DIR="/opt/rathena/conf/msg_conf"
CONF_IMPORT_DIR="$CONF_DIR/import"
MAP_DIR="/opt/rathena/src/map"
MAP_HPP="$MAP_DIR/map.hpp"
MAP_CPP="$MAP_DIR/map.cpp"
MSG_HPP="/opt/rathena/src/common/msg_conf.hpp"
MSG_CPP="/opt/rathena/src/common/msg_conf.cpp"

# 1) Klasor olustur
mkdir -p "$CONF_IMPORT_DIR"

# 2) map_msg_tur.conf olustur (yoksa ENG'den kopyala)
if [[ ! -f "$CONF_DIR/map_msg_tur.conf" ]]; then
  cp "$CONF_DIR/map_msg.conf" "$CONF_DIR/map_msg_tur.conf"
  echo "[+] map_msg_tur.conf olusturuldu (ENG'den kopyalandi)"
fi

# 3) import satirini TR dosyasina cevir
sed -i 's|import:[[:space:]]*conf/msg_conf/import/map_msg_eng_conf\.txt|import: conf/msg_conf/import/map_msg_tur_conf.txt|' \
  "$CONF_DIR/map_msg_tur.conf"

# 4) TR import dosyasini indir
wget -qO "$CONF_IMPORT_DIR/map_msg_tur_conf.txt" \
'https://raw.githubusercontent.com/b1glord/Configs/refs/heads/master/Docker/conf/msg_conf/import/map_msg_tur_conf.txt' || true
echo "[+] map_msg_tur_conf.txt indirildi."


echo "=== [2/4] map.hpp duzenlemeleri ==="
# CRLF temizle
sed -i 's/\r$//' "$MAP_HPP"

# THA -> TUR (sadece MSG_CONF_NAME_* sembolleri icin, tum dosyada)
sed -i 's/\<MSG_CONF_NAME_THA\>/MSG_CONF_NAME_TUR/g' "$MAP_HPP"

# extern bildirimleri dogru formata yakin tut (yildizdan sonra bosluk olmamasi gerekmiyorsa burayi ac)
# sed -i -E 's/^extern[[:space:]]+const[[:space:]]+char\*[[:space:]]+/extern const char*/' "$MAP_HPP"

grep -n 'MSG_CONF_NAME_' "$MAP_HPP" | tail -n 10 || true


echo "=== [3/4] map.cpp duzenlemeleri ==="
# CRLF temizle
sed -i 's/\r$//' "$MAP_CPP"

# 3.1) const tanimi: SADECE THA bildirimi satiri
#   const char *MSG_CONF_NAME_THA; -> const char *MSG_CONF_NAME_TUR;
sed -i -E 's/^([[:space:]]*const[[:space:]]+char[[:space:]]*\*)MSG_CONF_NAME_THA([[:space:]]*;)/\1MSG_CONF_NAME_TUR\2/' "$MAP_CPP"

# 3.2) listelang[] icindeki THA -> TUR (sadece array blogu icinde)
sed -i -E '/const[[:space:]]+char[[:space:]]*\*[[:space:]]*listelang\[\][[:space:]]*=[[:space:]]*\{/,/^\s*\}\s*;/{ s/\<MSG_CONF_NAME_THA\>/MSG_CONF_NAME_TUR/g }' "$MAP_CPP"

# 3.3) dosya atamasi: THA -> TUR satiri (yol ve yorumla birlikte)
sed -i -E 's/^\s*MSG_CONF_NAME_THA\s*=\s*"conf\/msg_conf\/map_msg_tha\.conf";\s*\/\/\s*Thai\s*$/    MSG_CONF_NAME_TUR = "conf\/msg_conf\/map_msg_tur.conf";   \/\/ Turkish/' "$MAP_CPP"

# Emniyet: eger yukaridaki satir farkli girinti/yorum formatinda ise, yalnizca sembol ve yolu cevir
sed -i -E 's/\<MSG_CONF_NAME_THA\>[[:space:]]*=[[:space:]]*"conf\/msg_conf\/map_msg_tha\.conf"/MSG_CONF_NAME_TUR = "conf\/msg_conf\/map_msg_tur.conf"/' "$MAP_CPP"

echo "[OK] map.cpp degisiklikleri:"
grep -n 'MSG_CONF_NAME_TUR' "$MAP_CPP" || true


echo "=== [4/4] msg_conf.hpp / msg_conf.cpp minimal ==="
# CRLF temizle
sed -i 's/\r$//' "$MSG_HPP" 2>/dev/null || true
sed -i 's/\r$//' "$MSG_CPP" 2>/dev/null || true

# LANG_ENABLE 0xFFF
sed -i 's/^\([[:space:]]*#define[[:space:]]\+LANG_ENABLE[[:space:]]\+\)0x000/\10xFFF/' "$MSG_HPP"

# THA -> TUR donusumu (yalniz yorum/metin ve sembol eslesmeleri)
sed -i 's|//[[:space:]]*Thai|// Turkish|g' "$MSG_HPP"
sed -i 's/\<THA\>/TUR/g' "$MSG_HPP"
sed -i 's/Thai (THA)/Turkish (TUR)/g' "$MSG_CPP"
sed -i 's/!strncmpi(langtype,[[:space:]]*"tha"/!strncmpi(langtype, "tur"/g' "$MSG_CPP"
sed -i 's/\<THA\>/TUR/g' "$MSG_CPP"

echo
echo "✅ Tamam. Derleme:"
echo "cd /opt/rathena && make clean && make server"
