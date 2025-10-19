#!/usr/bin/env bash
set -euo pipefail

MAP_HPP="/opt/rathena/src/map/map.hpp"

# CRLF varsa temizle (önlem)
sed -i 's/\r$//' "$MAP_HPP"

# Eğer zaten varsa dokunma
if ! grep -q '^extern const char\*MSG_CONF_NAME_TUR;' "$MAP_HPP"; then
  # THA satırının hemen altına ekle
  sed -i '/^extern const char\*MSG_CONF_NAME_THA;[[:space:]]*$/a extern const char*MSG_CONF_NAME_TUR;' "$MAP_HPP"
  echo "[OK] TUR satırı eklendi."
else
  echo "[SKIP] TUR zaten mevcut, değişiklik yapılmadı."
fi

# Kontrol için göster
grep -n 'MSG_CONF_NAME_' "$MAP_HPP" | tail -n 5


