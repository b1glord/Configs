#!/usr/bin/env bash
set -euo pipefail

# --- Paths ---
CONF_DIR="/opt/rathena/conf/msg_conf"
CONF_IMPORT_DIR="$CONF_DIR/import"
MAP_DIR="/opt/rathena/src/map"
MAP_CPP="$MAP_DIR/map.cpp"
MAP_HPP="$MAP_DIR/map.hpp"
MSG_HPP="/opt/rathena/src/common/msg_conf.hpp"

# --- Backups ---
mkdir -p "$CONF_IMPORT_DIR"
for f in "$MAP_CPP" "$MAP_HPP" "$MSG_HPP"; do
  [[ -f "$f" ]] && cp -n "$f" "$f.bak.$(date +%F-%H%M%S)" || true
done

# --- 0) map.cpp geri yukleme (tmp veya son backup) ---
cd "$MAP_DIR"
if [[ -f map.cpp.tmp ]]; then
  mv -f map.cpp.tmp map.cpp
fi
if [[ ! -f map.cpp ]]; then
  # en yeni yedegi bul ve geri yukle
  latest="$(ls -1t map.cpp.bak.* 2>/dev/null | head -1 || true)"
  [[ -n "$latest" ]] && cp -f "$latest" map.cpp
fi
cd - >/dev/null

# --- 1) TR conf hazirla ---
if [[ ! -f "$CONF_DIR/map_msg_tur.conf" ]]; then
  cp "$CONF_DIR/map_msg.conf" "$CONF_DIR/map_msg_tur.conf"
fi
sed -i 's|import:[[:space:]]*conf/msg_conf/import/map_msg_eng_conf\.txt|import: conf/msg_conf/import/map_msg_tur_conf.txt|' \
  "$CONF_DIR/map_msg_tur.conf"
wget -qO "$CONF_IMPORT_DIR/map_msg_tur_conf.txt" \
  'https://raw.githubusercontent.com/b1glord/Configs/refs/heads/master/Docker/conf/msg_conf/import/map_msg_tur_conf.txt' || true

# --- 2) Dil enum + maske (msg_conf.hpp) ---
if ! grep -q 'LANG_TUR' "$MSG_HPP"; then
  sed -i '/LANG_THA[[:space:]]*=[[:space:]]*0x100[[:space:]]*,/a\ \tLANG_TUR = 0x200,   // Turkish' "$MSG_HPP"
fi
sed -i 's/^\(#define[[:space:]]\+LANG_ENABLE[[:space:]]\+\).*/\10xFFF/' "$MSG_HPP"

# --- 3) Header deklarasyonlari (varsa) ---
if [[ -f "$MAP_HPP" ]]; then
  if grep -qE 'extern[[:space:]]+const[[:space:]]+char\*[[:space:]]*MSG_CONF_NAME_THA[[:space:]]*;' "$MAP_HPP"; then
    grep -qE 'extern[[:space:]]+const[[:space:]]+char\*[[:space:]]*MSG_CONF_NAME_TUR[[:space:]]*;' "$MAP_HPP" || \
    sed -i -E '/extern[[:space:]]+const[[:space:]]+char\*[[:space:]]*MSG_CONF_NAME_THA[[:space:]]*;/a extern const char* MSG_CONF_NAME_TUR;' "$MAP_HPP"
  fi
fi

# --- 4) map.cpp: global const + assignment + listelang[] ---
# 4a) THA const altina TUR const (varsa o blok)
if grep -qE '(^|[[:space:]])const[[:space:]]+char[[:space:]]*\*[[:space:]]*MSG_CONF_NAME_THA[[:space:]]*;' "$MAP_CPP"; then
  grep -qE '(^|[[:space:]])const[[:space:]]+char[[:space:]]*\*[[:space:]]*MSG_CONF_NAME_TUR[[:space:]]*;' "$MAP_CPP" || \
  sed -i -E '/(^|[[:space:]])const[[:space:]]+char[[:space:]]*\*[[:space:]]*MSG_CONF_NAME_THA[[:space:]]*;/a const char *MSG_CONF_NAME_TUR;' "$MAP_CPP"
fi

# 4b) THA assignment altina TUR assignment (yoksa)
if ! grep -Eq 'MSG_CONF_NAME_TUR[[:space:]]*=' "$MAP_CPP"; then
  if grep -Eq 'MSG_CONF_NAME_THA[[:space:]]*=[[:space:]]*"conf/msg_conf/map_msg_tha\.conf";[[:space:]]*//[[:space:]]*Thai' "$MAP_CPP"; then
    sed -i '/MSG_CONF_NAME_THA[[:space:]]*=[[:space:]]*"conf\/msg_conf\/map_msg_tha\.conf";[[:space:]]*\/\/[[:space:]]*Thai/a\
    MSG_CONF_NAME_TUR = "conf/msg_conf/map_msg_tur.conf";   // Turkish' "$MAP_CPP"
  else
    sed -i '/MSG_CONF_NAME_THA[[:space:]]*=[[:space:]]*"conf\/msg_conf\/map_msg_tha\.conf";/a\
    MSG_CONF_NAME_TUR = "conf/msg_conf/map_msg_tur.conf";   // Turkish' "$MAP_CPP"
  fi
fi

# 4c) listelang[] icine THA altina TUR (POSIX awk; gensub YOK)
awk '
BEGIN{inarr=0; hasTur=0}
# dizi baslangici
/^[ \t]*const[ \t]+char[ \t]*\*[ \t]*listelang\[\][ \t]*=[ \t]*\{/ { inarr=1 }
# dizi icerisinde TUR gorulurse isaretle
inarr==1 && $0 ~ /^[ \t]*MSG_CONF_NAME_TUR[ \t]*,/ { hasTur=1 }
# THA satirini virgullu yaz ve altina TUR ekle (yoksa)
inarr==1 && $0 ~ /^[ \t]*MSG_CONF_NAME_THA[ \t]*,?[ \t]*$/ {
    lead=""; m=match($0,/[^ \t]/); if (m>1) { lead=substr($0,1,m-1) }
    print lead "MSG_CONF_NAME_THA,"
    if (hasTur==0) print lead "MSG_CONF_NAME_TUR,"
    next
}
# dizi bitisi
inarr==1 && $0 ~ /^[ \t]*\}[ \t]*;[ \t]*$/ { inarr=0 }
{ print }
' "$MAP_CPP" > "$MAP_CPP.new" && mv -f "$MAP_CPP.new" "$MAP_CPP"

# --- 5) Rapor ---
echo "[OK] import ->" && grep -n '^import:' "$CONF_DIR/map_msg_tur.conf" || true
echo "[OK] enums   ->" && grep -n 'LANG_T.. = ' "$MSG_HPP" || true
[[ -f "$MAP_HPP" ]] && { echo "[OK] map.hpp ->"; grep -n 'MSG_CONF_NAME_TUR' "$MAP_HPP" || true; }
echo "[OK] map.cpp ->" && grep -n 'MSG_CONF_NAME_TUR' "$MAP_CPP" || true

echo
echo "Build tip: cd /opt/rathena/src && make clean && make server"
