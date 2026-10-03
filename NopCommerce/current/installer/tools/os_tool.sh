# 📄 Dosya Yolu: /NopCommerce/current/installer/tools/os_tool.sh
# 📌 Amac: Linux platform, bagimlilik, side-by-side .NET runtime ve servis hesabini yonetmek
# 📌 Modul - Shell
# Version: 1.2.0
# Aciklama: Native modda host .NET/Nginx bagimliliklarini, Docker modda yalniz ortak paketleri kurar
# Bagimli Oldugu Katman: Config | View | Language

set -Eeuo pipefail

os_tool_require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        console_view_error "${ERR_ROOT}"
        return 77
    fi
}

os_tool_validate_platform() {
    local supported
    local os_item
    local is_supported

    if [[ ! -f "${NOP_OS_RELEASE_FILE}" ]]; then
        console_view_error "${ERR_OS_RELEASE}"
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
        console_view_error "${ERR_UNSUPPORTED_OS}: ${ID}"
        return 69
    fi
}

os_tool_install_dependencies() {
    local app_mode="${1:-native}"
    local package_string
    local packages

    package_string="${NOP_APT_BASE_PACKAGES}"

    if [[ "${app_mode}" == "native" ]]; then
        package_string+=" ${NOP_APT_NATIVE_PACKAGES}"
    fi

    IFS=' ' read -r -a packages <<< "${package_string}"

    console_view_info "${MSG_DEPENDENCIES}"
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
}

os_tool_runtime_is_installed() {
    if [[ ! -x "${NOP_DOTNET_EXECUTABLE}" ]]; then
        return 1
    fi

    "${NOP_DOTNET_EXECUTABLE}" --list-runtimes 2>/dev/null |         grep -q "^Microsoft.AspNetCore.App ${NOP_DOTNET_RUNTIME_CHANNEL}\."
}

os_tool_install_dotnet_runtime() {
    local install_script

    if os_tool_runtime_is_installed; then
        return 0
    fi

    install_script="${NOP_TEMP_DIR}/dotnet-install.sh"

    mkdir -p "${NOP_TEMP_DIR}" "${NOP_DOTNET_ROOT}"

    console_view_info "${MSG_DOTNET}"
    curl --fail --location --retry 3         --output "${install_script}"         "${NOP_DOTNET_INSTALL_SCRIPT_URL}"

    bash "${install_script}"         --channel "${NOP_DOTNET_RUNTIME_CHANNEL}"         --runtime "${NOP_DOTNET_RUNTIME_KIND}"         --install-dir "${NOP_DOTNET_ROOT}"         --no-path

    if ! os_tool_runtime_is_installed; then
        console_view_error "${ERR_DOTNET_INSTALL}: ${NOP_DOTNET_RUNTIME_CHANNEL}"
        return 70
    fi

    ln -sfn "${NOP_DOTNET_EXECUTABLE}" "${NOP_DOTNET_SYMLINK}"
}

os_tool_ensure_service_account() {
    if ! getent group "${NOP_SERVICE_GROUP}" >/dev/null 2>&1; then
        groupadd --system "${NOP_SERVICE_GROUP}"
    fi

    if ! id "${NOP_SERVICE_USER}" >/dev/null 2>&1; then
        useradd             --system             --gid "${NOP_SERVICE_GROUP}"             --home-dir "${NOP_INSTALL_ROOT}"             --shell "${NOP_NOLOGIN_SHELL}"             "${NOP_SERVICE_USER}"
    fi
}
