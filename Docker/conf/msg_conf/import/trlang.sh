#!/usr/bin/env bash
set -euo pipefail

MAP_DIR="/opt/rathena/src/map"
MAP_CPP="$MAP_DIR/map.cpp"
MAP_HPP="$MAP_DIR/map.hpp"

# 0) Yedek
[[ -f "$MAP_HPP" ]] && cp -n "$MAP_HPP" "$MAP_HPP.bak.$(date +%F-%H%M%S)" || true

# 1) map.hpp icindeki YANLIS satirlari temizle
#  - "\1" kalan hatali satirlar
#  - tum MSG_CONF_NAME_* extern satirlari (yeniden yazilacak)
sed -i -E '
/^extern[[:space:]]+const[[:space:]]+char\*\\1;[[:space:]]*$/d
/^extern[[:space:]]+const[[:space:]]+char\*MSG_CONF_NAME_[A-Z]+;[[:space:]]*$/d
' "$MAP_HPP"

# 2) map.cpp icindeki isimleri cikar (sirayla, uniq)
#    once "const char*MSG_CONF_NAME_XXX;" satirlarindan, yoksa atama satirlarindan cek
names="$(awk '
  BEGIN{FS=""; seen_cnt=0}
  {
    if (match($0,/MSG_CONF_NAME_[A-Z]+/)) {
      name=substr($0,RSTART,RLENGTH);
      if (!seen[name]++) {
        order[++seen_cnt]=name;
      }
    }
  }
  END{
    for(i=1;i<=seen_cnt;i++) print order[i];
  }
' "$MAP_CPP" | grep -E '^MSG_CONF_NAME_[A-Z]+$' | tr '\n' ' ' )"

# Guvenlik: hic isim bulunamazsa bilinen listeyi kullan
if [[ -z "${names// }" ]]; then
  names="MSG_CONF_NAME_RUS MSG_CONF_NAME_SPN MSG_CONF_NAME_GRM MSG_CONF_NAME_CHN MSG_CONF_NAME_MAL MSG_CONF_NAME_IDN MSG_CONF_NAME_FRN MSG_CONF_NAME_POR MSG_CONF_NAME_THA MSG_CONF_NAME_TUR"
fi

# 3) Gecici blok olustur
tmp="$(mktemp)"
for n in $names; do
  echo "extern const char*${n};" >> "$tmp"
done

# 4) Uygun bir yere ekle:
#    - THA extern satiri VARSA onun hemen altina tum blok
#    - yoksa dosyanin sonuna ekle
if grep -q '^extern[[:space:]]\+const[[:space:]]\+char\*MSG_CONF_NAME_THA;[[:space:]]*$' "$MAP_HPP"; then
  # THA altina ekle
  awk -v FILEBLOCK="$tmp" '
    BEGIN{
      while((getline line < FILEBLOCK) > 0){ block=block line "\n" }
      close(FILEBLOCK)
    }
    {
      print $0
      if ($0 ~ /^extern[ \t]+const[ \t]+char\*MSG_CONF_NAME_THA;[ \t]*$/) {
        printf "%s", block
      }
    }
  ' "$MAP_HPP" > "$MAP_HPP.new" && mv -f "$MAP_HPP.new" "$MAP_HPP"
else
  # sona ekle
  printf "\n" >> "$MAP_HPP"
  cat "$tmp" >> "$MAP_HPP"
fi
rm -f "$tmp"

# 5) Son bir normalizasyon: "*" sonrasi bosluk KALDIR
sed -i -E 's/^(extern[[:space:]]+const[[:space:]]+char\*)[[:space:]]+/\1/' "$MAP_HPP"

# 6) Kontrol
echo "== map.hpp extern kontrol =="
grep -n '^extern const char\*MSG_CONF_NAME_' "$MAP_HPP" || true
