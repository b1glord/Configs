#!/bin/bash
# Dosya Yolu: /OFBIZ/tools/legacy/java/oraclejdk8.sh
# Amac: Eski raw GitHub yolunu yeni TurkuazOFBiz legacy Java scriptine yonlendirir
# Tool - Shell
# Version: 1.0.0
# Aciklama: Geriye uyumluluk shim'i; aktif OFBiz kurulumunda kullanilmaz
#
# Bagimli Oldugu Katman: Tool

set -e

TARGET_URL="https://raw.githubusercontent.com/TurkuazLabs/TurkuazOFBiz/main/tools/legacy/java/oraclejdk8.sh"
TMP_FILE="$(mktemp)"

cleanup() {
    rm -f "${TMP_FILE}"
}
trap cleanup EXIT

if command -v curl >/dev/null 2>&1; then
    curl --fail --location --silent --show-error "${TARGET_URL}" -o "${TMP_FILE}"
else
    wget -qO "${TMP_FILE}" "${TARGET_URL}"
fi

bash "${TMP_FILE}" "$@"
