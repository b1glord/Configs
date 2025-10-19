#!/usr/bin/env bash
set -euo pipefail

# ========== MAP.HPP ==========
MAP_HPP="/opt/rathena/src/map/map.hpp"

# Normalize CRLF
sed -i 's/\r$//' "$MAP_HPP"

# TUR extern yoksa, THA extern satirinin ALTINA ekle
if ! grep -q '^extern const char\*MSG_CONF_NAME_TUR;' "$MAP_HPP"; then
  sed -i '/^extern const char\*MSG_CONF_NAME_THA;[[:space:]]*$/a extern const char*MSG_CONF_NAME_TUR;' "$MAP_HPP"
  echo "[OK] map.hpp: TUR extern eklendi"
else
  echo "[SKIP] map.hpp: TUR zaten var"
fi

grep -n 'MSG_CONF_NAME_' "$MAP_HPP" | tail -n 5 || true


# ========== MAP.CPP ==========
MAP_CPP="/opt/rathena/src/map/map.cpp"

# Normalize CRLF
sed -i 's/\r$//' "$MAP_CPP"

# 1) const bildirimine TUR ekle (THA altina), yoksa — girintiyi koru
if ! grep -qE '^[[:space:]]*const[[:space:]]+char[[:space:]]*\*[[:space:]]*MSG_CONF_NAME_TUR[[:space:]]*;' "$MAP_CPP"; then
awk '
BEGIN{added=0}
# THA const satirini bul: ayni girinti ile altina TUR const yaz
/^[ \t]*const[ \t]*char[ \t]*\*[ \t]*MSG_CONF_NAME_THA[ \t]*;[ \t]*$/ && !added {
  lead=""; m=match($0,/[^ \t]/); if (m>1) lead=substr($0,1,m-1)
  print $0
  print lead "const char *MSG_CONF_NAME_TUR;"
  added=1
  next
}
{print}
' "$MAP_CPP" > "$MAP_CPP.tmp1" && mv -f "$MAP_CPP.tmp1" "$MAP_CPP"
fi

# 2) THA assignment altina TUR assignment ekle (yoksa) — girintiyi koru
if ! grep -Eq 'MSG_CONF_NAME_TUR[[:space:]]*=' "$MAP_CPP"; then
awk '
BEGIN{added=0}
# THA assignment satirini bul: ayni girinti ile altina TUR assignment yaz
/^[ \t]*MSG_CONF_NAME_THA[ \t]*=[ \t]*"conf\/msg_conf\/map_msg_tha\.conf";([ \t]*\/\/[ \t]*Thai)?[ \t]*$/ && !added {
  lead=""; m=match($0,/[^ \t]/); if (m>1) lead=substr($0,1,m-1)
  print $0
  print lead "MSG_CONF_NAME_TUR = \"conf/msg_conf/map_msg_tur.conf\";   // Turkish"
  added=1
  next
}
{print}
' "$MAP_CPP" > "$MAP_CPP.tmp2" && mv -f "$MAP_CPP.tmp2" "$MAP_CPP"
fi

# 3) listelang[]: THA altina TUR ekle; THA virgullu, TUR VIRGULSUZ (son eleman), dup yok
awk '
BEGIN{inarr=0; seenTur=0}
# dizi baslangici
/^[ \t]*const[ \t]+char[ \t]*\*[ \t]*listelang\[\][ \t]*=[ \t]*\{/ { inarr=1 }

# Dizi icinde TUR satiri gorulurse:
#  - ilk goruste normalize edip yaz
#  - daha sonraki TUR tekrarlarini yazma (dup engelle)
inarr==1 && $0 ~ /^[ \t]*MSG_CONF_NAME_TUR[ \t]*,?[ \t]*$/ {
  if (!seenTur) {
    lead=""; m=match($0,/[^ \t]/); if (m>1) lead=substr($0,1,m-1)
    print lead "MSG_CONF_NAME_TUR"
    seenTur=1
  }
  next
}

# THA satiri: THA yi virgullu yaz; eger henuz TUR gorulmediyse hemen altina TUR u yaz
inarr==1 && $0 ~ /^[ \t]*MSG_CONF_NAME_THA[ \t]*,?[ \t]*$/ {
  lead=""; m=match($0,/[^ \t]/); if (m>1) lead=substr($0,1,m-1)
  print lead "MSG_CONF_NAME_THA,"
  if (!seenTur) {
    print lead "MSG_CONF_NAME_TUR"
    seenTur=1
  }
  next
}

# dizi bitisi
inarr==1 && $0 ~ /^[ \t]*\}[ \t]*;[ \t]*$/ { inarr=0 }

{ print }
' /opt/rathena/src/map/map.cpp > /opt/rathena/src/map/map.cpp.tmp && mv -f /opt/rathena/src/map/map.cpp.tmp /opt/rathena/src/map/map.cpp


# Kontrol
echo "[OK] map.cpp degisiklikleri:"
grep -n 'MSG_CONF_NAME_THA' "$MAP_CPP" | head -n 3 || true
grep -n 'MSG_CONF_NAME_TUR' "$MAP_CPP" | head -n 5 || true
