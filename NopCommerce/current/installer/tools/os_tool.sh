# 📄 Dosya Yolu: /NopCommerce/current/installer/tools/os_tool.sh
# 📌 Amac: Linux platform, paket yoneticisi, .NET runtime ve servis hesabini yonetmek
# 📌 Modul - Shell
# Version: 1.0.1
# Aciklama: Config ile tanimlanan Debian tabanli Linux sistemleri icin dis sistem adaptoru
# Bagimli Oldugu Katman: Config | Language

set -Eeuo pipefail

os_tool_require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        printf '%s\n' "${ERR_ROOT}" >&2
        return 77
    fi
}

os_tool_validate_platform() {
    local supported
    local os_item
    local is_supported

    if [[ ! -f "${NOP_OS_RELEASE_FILE}" ]]; then
        printf '%s\n' "${ERR_OS_RELEASE}" >&2
        return 69
    fi

    source "${NOP_OS_RELEASE_FILE}"

    is_supported="0"
    IFS=':' read -r -a supported <<< "${NOP_SUPPORTED_OS}"

    for os_item in "${supported[@]}"; do
        if [[ "${ID}" == "${os_item}" ]]; then
            is_supported="1"
            break
        fi
    done

    if [[ "${is_supported}" != "1" ]]; then
        printf '%s: %s\n' "${ERR_UNSUPPORTED_OS}" "${ID}" >&2
        return 69
    fi
}

os_tool_install_dependencies() {
    local packages

    IFS=' ' read -r -a packages <<< "${NOP_APT_BASE_PACKAGES}"

    printf '%s\n' "${MSG_DEPENDENCIES}"
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
}

os_tool_install_dotnet_runtime() {
    local feed_url
    local feed_package

    if command -v "${NOP_DOTNET_EXECUTABLE}" >/dev/null 2>&1 &&        "${NOP_DOTNET_EXECUTABLE}" --list-runtimes | grep -q "^Microsoft.AspNetCore.App ${NOP_DOTNET_RUNTIME_VERSION_PREFIX}"; then
        return 0
    fi

    source "${NOP_OS_RELEASE_FILE}"

    feed_package="${NOP_TEMP_DIR}/packages-microsoft-prod.deb"
    feed_url="${NOP_MICROSOFT_PACKAGES_BASE_URL}/${ID}/${VERSION_ID}/packages-microsoft-prod.deb"

    printf '%s\n' "${MSG_DOTNET}"
    curl --fail --location --retry 3 --output "${feed_package}" "${feed_url}"
    dpkg -i "${feed_package}"
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y "${NOP_DOTNET_RUNTIME_PACKAGE}"
}

os_tool_ensure_service_account() {
    if ! getent group "${NOP_SERVICE_GROUP}" >/dev/null 2>&1; then
        groupadd --system "${NOP_SERVICE_GROUP}"
    fi

    if ! id "${NOP_SERVICE_USER}" >/dev/null 2>&1; then
        useradd             --system             --gid "${NOP_SERVICE_GROUP}"             --home-dir "${NOP_INSTALL_ROOT}"             --shell "${NOP_NOLOGIN_SHELL}"             "${NOP_SERVICE_USER}"
    fi
}
