#!/bin/bash
# rAthena mapcache updater (kaynak: klasor tarama)
# Versiyon: 1.0 (opt/rathena dizinine göre)
# Yazan: Burak için optimize edildi

set -e

# Ana dizin sabit olarak tanımlandı
RA_DIR="/opt/rathena"

# Harita ve araç yolları
mkdir -p "$RA_DIR/maps"
MAP_DIR="$RA_DIR/maps"
MAPCACHE="$RA_DIR/tools/mapcache"

# Kontroller
if [ ! -x "$MAPCACHE" ]; then
  echo "❌ HATA: $MAPCACHE bulunamadi veya calistirilamiyor"; exit 1
fi
if [ ! -d "$MAP_DIR" ]; then
  echo "❌ HATA: $MAP_DIR bulunamadi"; exit 1
fi

# Islemler
echo ">> $MAP_DIR icindeki *.gat dosyalari taraniyor..."
find "$MAP_DIR" -maxdepth 1 -type f -name '*.gat' | while read -r GAT; do
  echo " + $(basename "$GAT") eklendi"
  "$MAPCACHE" --add "$GAT"
done

echo "✅ Mapcache guncellemesi tamamlandi!"
