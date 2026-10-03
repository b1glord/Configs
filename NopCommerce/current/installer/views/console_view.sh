# 📄 Dosya Yolu: /NopCommerce/current/installer/views/console_view.sh
# 📌 Amac: Installer konsol ciktilarini tek bir View katmaninda uretmek
# 📌 Modul - Shell
# Version: 1.0.0
# Aciklama: Info, warning, error ve key/value ciktilarini standartlastirir
# Bagimli Oldugu Katman: Language

set -Eeuo pipefail

console_view_info() {
    printf '[%s] %s\n' "${LABEL_INFO}" "$*"
}

console_view_warn() {
    printf '[%s] %s\n' "${LABEL_WARN}" "$*" >&2
}

console_view_error() {
    printf '[%s] %s\n' "${LABEL_ERROR}" "$*" >&2
}

console_view_value() {
    local label="$1"
    local value="$2"

    printf '%s: %s\n' "${label}" "${value}"
}

console_view_versions() {
    printf '%s\n' "${MSG_AVAILABLE_VERSIONS}"
    printf '%s\n' "${MSG_VERSION_EXAMPLES}"
}
