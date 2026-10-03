# 📄 Dosya Yolu: /NopCommerce/current/installer/services/install_service.sh
# 📌 Amac: nopCommerce kurulum is akisinin tum is kurallarini yonetmek
# 📌 Modul - Shell
# Version: 1.0.1
# Aciklama: Config validation, dependency kurulumu, release deploy, systemd ve Nginx orkestrasyonu
# Bagimli Oldugu Katman: Repo | Tool | Config | Language

set -Eeuo pipefail

install_service_require_config() {
    local key

    for key in         NOP_VERSION         NOP_RELEASE_TAG         NOP_PACKAGE_NAME         NOP_PACKAGE_SHA256         NOP_RELEASE_BASE_URL         NOP_INSTALL_ROOT         NOP_RELEASES_DIR         NOP_CURRENT_DIR         NOP_BACKUP_DIR         NOP_TEMP_DIR         NOP_SERVICE_NAME         NOP_SERVICE_USER         NOP_SERVICE_GROUP         NOP_ASPNETCORE_URLS         NOP_PUBLIC_HOST         NOP_NGINX_SITE_AVAILABLE         NOP_NGINX_SITE_ENABLED         NOP_DEFAULT_NGINX_SITE         NOP_SYSTEMD_UNIT         NOP_DOTNET_EXECUTABLE         NOP_DOTNET_RUNTIME_PACKAGE         NOP_DOTNET_RUNTIME_VERSION_PREFIX         NOP_MICROSOFT_PACKAGES_BASE_URL         NOP_APT_BASE_PACKAGES         NOP_SUPPORTED_OS         NOP_OS_RELEASE_FILE         NOP_NOLOGIN_SHELL         NOP_WRITABLE_PATHS
    do
        if [[ -z "${!key:-}" ]]; then
            printf '%s: %s\n' "${ERR_CONFIG_KEY}" "${key}" >&2
            return 78
        fi
    done
}

install_service_run() {
    local installer_root="$1"
    local config_path="${2:-}"

    export INSTALLER_ROOT="${installer_root}"

    source "${INSTALLER_ROOT}/language/tr.labels"

    if [[ -z "${config_path}" ]]; then
        printf '%s\n' "${ERR_USAGE}" >&2
        return 64
    fi

    if [[ ! -f "${config_path}" ]]; then
        printf '%s: %s\n' "${ERR_CONFIG_FILE}" "${config_path}" >&2
        return 66
    fi

    set -a
    source "${config_path}"
    set +a

    source "${INSTALLER_ROOT}/repositories/release_repository.sh"
    source "${INSTALLER_ROOT}/tools/os_tool.sh"
    source "${INSTALLER_ROOT}/tools/systemd_tool.sh"
    source "${INSTALLER_ROOT}/tools/nginx_tool.sh"

    install_service_require_config

    printf '%s\n' "${MSG_START}"

    os_tool_require_root
    os_tool_validate_platform
    os_tool_install_dependencies
    os_tool_install_dotnet_runtime
    os_tool_ensure_service_account

    release_repository_prepare
    release_repository_download
    release_repository_deploy

    systemd_tool_install
    systemd_tool_start

    nginx_tool_install

    printf '%s\n' "${MSG_DONE}"
    printf '%s %s\n' "${MSG_URL}" "${NOP_PUBLIC_HOST}"
}
