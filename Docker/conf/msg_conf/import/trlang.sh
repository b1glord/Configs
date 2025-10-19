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

# ===============================
echo "=== [2/4] map.hpp Güncellemesi ==="

# Normalize satır sonları
sed -i 's/\r$//' "$MAP_HPP"

# TUR extern yoksa, THA extern altına ekle
if ! grep -q '^extern const char\*MSG_CONF_NAME_TUR;' "$MAP_HPP"; then
  sed -i '/^extern const char\*MSG_CONF_NAME_THA;[[:space:]]*$/a extern const char*MSG_CONF_NAME_TUR;' "$MAP_HPP"
  echo "[+] map.hpp: TUR extern eklendi"
else
  echo "[=] map.hpp: TUR zaten mevcut"
fi

grep -n 'MSG_CONF_NAME_' "$MAP_HPP" | tail -n 5 || true

# ===============================
echo "=== [3/4] map.cpp Güncellemesi ==="

# Normalize satır sonları
sed -i 's/\r$//' "$MAP_CPP"

# 1) const bildirimine TUR ekle (THA altına)
if ! grep -qE '^[[:space:]]*const[[:space:]]+char[[:space:]]*\*[[:space:]]*MSG_CONF_NAME_TUR[[:space:]]*;' "$MAP_CPP"; then
awk '
BEGIN{added=0}
/^[ \t]*const[ \t]*char[ \t]*\*[ \t]*MSG_CONF_NAME_THA[ \t]*;[ \t]*$/ && !added {
  lead=""; m=match($0,/[^ \t]/); if (m>1) lead=substr($0,1,m-1)
  print $0
  print lead "const char *MSG_CONF_NAME_TUR;"
  added=1
  next
}
{print}
' "$MAP_CPP" > "$MAP_CPP.tmp1" && mv -f "$MAP_CPP.tmp1" "$MAP_CPP"
echo "[+] map.cpp: TUR const eklendi"
fi

# 2) THA assignment altına TUR assignment ekle
if ! grep -Eq 'MSG_CONF_NAME_TUR[[:space:]]*=' "$MAP_CPP"; then
awk '
BEGIN{added=0}
/^[ \t]*MSG_CONF_NAME_THA[ \t]*=[ \t]*"conf\/msg_conf\/map_msg_tha\.conf";([ \t]*\/\/[ \t]*Thai)?[ \t]*$/ && !added {
  lead=""; m=match($0,/[^ \t]/); if (m>1) lead=substr($0,1,m-1)
  print $0
  print lead "MSG_CONF_NAME_TUR = \"conf/msg_conf/map_msg_tur.conf\";   // Turkish"
  added=1
  next
}
{print}
' "$MAP_CPP" > "$MAP_CPP.tmp2" && mv -f "$MAP_CPP.tmp2" "$MAP_CPP"
echo "[+] map.cpp: TUR assignment eklendi"
fi

# 3) listelang[]: THA altına TUR ekle; THA virgüllü, TUR virgülsüz (son)
awk '
BEGIN{inarr=0; seenTur=0}
/^[ \t]*const[ \t]+char[ \t]*\*[ \t]*listelang\[\][ \t]*=[ \t]*\{/ { inarr=1 }
inarr==1 && $0 ~ /^[ \t]*MSG_CONF_NAME_TUR[ \t]*,?[ \t]*$/ {
  if (!seenTur) {
    lead=""; m=match($0,/[^ \t]/); if (m>1) lead=substr($0,1,m-1)
    print lead "MSG_CONF_NAME_TUR"
    seenTur=1
  }
  next
}
inarr==1 && $0 ~ /^[ \t]*MSG_CONF_NAME_THA[ \t]*,?[ \t]*$/ {
  lead=""; m=match($0,/[^ \t]/); if (m>1) lead=substr($0,1,m-1)
  print lead "MSG_CONF_NAME_THA,"
  if (!seenTur) {
    print lead "MSG_CONF_NAME_TUR"
    seenTur=1
  }
  next
}
inarr==1 && $0 ~ /^[ \t]*\}[ \t]*;[ \t]*$/ { inarr=0 }
{ print }
' "$MAP_CPP" > "$MAP_CPP.tmp3" && mv -f "$MAP_CPP.tmp3" "$MAP_CPP"

echo "[+] map.cpp: listelang[] güncellendi"

# ===============================
echo "=== [4/4] Kontrol Çıktısı ==="
grep -n 'MSG_CONF_NAME_THA' "$MAP_CPP" | head -n 3 || true
grep -n 'MSG_CONF_NAME_TUR' "$MAP_CPP" | head -n 5 || true

echo
echo "✅ İşlem tamamlandı. Derleme komutu:"
echo "cd /opt/rathena/src && make clean && make server"
