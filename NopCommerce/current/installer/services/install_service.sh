# 📄 Dosya Yolu: /NopCommerce/current/installer/services/install_service.sh
# 📌 Amac: nopCommerce cok surumlu kurulum is akisinin tum is kurallarini yonetmek
# 📌 Modul - Shell
# Version: 1.2.0
# Aciklama: CLI, config, surum cozumleme, release deploy, runtime, systemd ve Nginx orkestrasyonu
# Bagimli Oldugu Katman: Repo | Tool | View | Config | Language

set -Eeuo pipefail

install_service_require_config() {
    local key

    for key in         NOP_DEFAULT_VERSION         NOP_RELEASE_API_BASE         NOP_RELEASE_TAG_FORMAT         NOP_PACKAGE_NAME_FORMAT         NOP_ALLOW_LEGACY_WITHOUT_SHA256         NOP_INSTALL_ROOT         NOP_RELEASES_DIR         NOP_CURRENT_DIR         NOP_BACKUP_DIR         NOP_TEMP_DIR         NOP_SERVICE_NAME         NOP_SERVICE_USER         NOP_SERVICE_GROUP         NOP_ASPNETCORE_URLS         NOP_PUBLIC_HOST         NOP_NGINX_SITE_AVAILABLE         NOP_NGINX_SITE_ENABLED         NOP_DEFAULT_NGINX_SITE         NOP_SYSTEMD_UNIT         NOP_DOTNET_ROOT         NOP_DOTNET_EXECUTABLE         NOP_DOTNET_SYMLINK         NOP_DOTNET_INSTALL_SCRIPT_URL         NOP_DOTNET_RUNTIME_KIND         NOP_SUPPORTED_OS         NOP_OS_RELEASE_FILE         NOP_NOLOGIN_SHELL         NOP_APT_BASE_PACKAGES         NOP_WRITABLE_PATHS         NOP_SUPPORTED_VERSION_FAMILIES         NOP_VERSION_PATTERN         NOP_VERSION_ALIASES         NOP_RUNTIME_CHANNELS         NOP_PACKAGE_NAME_OVERRIDES         NOP_LEGACY_VERSION_FAMILIES
    do
        if [[ -z "${!key:-}" ]]; then
            console_view_error "${ERR_CONFIG_KEY}: ${key}"
            return 78
        fi
    done
}

install_service_parse_args() {
    local config_path=""
    local requested_version=""
    local list_versions="0"

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                if [[ "$#" -lt 2 || -z "${2:-}" ]]; then
                    console_view_error "${ERR_USAGE}"
                    return 64
                fi
                requested_version="$2"
                shift 2
                ;;
            --config)
                if [[ "$#" -lt 2 || -z "${2:-}" ]]; then
                    console_view_error "${ERR_USAGE}"
                    return 64
                fi
                config_path="$2"
                shift 2
                ;;
            --list-versions)
                list_versions="1"
                shift
                ;;
            -*)
                console_view_error "${ERR_USAGE}"
                return 64
                ;;
            *)
                if [[ -z "${config_path}" ]]; then
                    config_path="$1"
                    shift
                else
                    console_view_error "${ERR_USAGE}"
                    return 64
                fi
                ;;
        esac
    done

    export INSTALL_REQUEST_CONFIG="${config_path}"
    export INSTALL_REQUEST_VERSION="${requested_version}"
    export INSTALL_REQUEST_LIST_VERSIONS="${list_versions}"
}

install_service_load_config() {
    local config_path="$1"

    if [[ -z "${config_path}" ]]; then
        console_view_error "${ERR_USAGE}"
        return 64
    fi

    if [[ ! -f "${config_path}" ]]; then
        console_view_error "${ERR_CONFIG_FILE}: ${config_path}"
        return 66
    fi

    set -a
    source "${config_path}"
    source "${INSTALLER_ROOT}/config/version-catalog.env"
    set +a
}

install_service_run() {
    local installer_root="$1"
    shift

    export INSTALLER_ROOT="${installer_root}"

    source "${INSTALLER_ROOT}/language/tr.labels"
    source "${INSTALLER_ROOT}/views/console_view.sh"
    source "${INSTALLER_ROOT}/repositories/version_repository.sh"

    install_service_parse_args "$@"

    if [[ "${INSTALL_REQUEST_LIST_VERSIONS}" == "1" ]]; then
        source "${INSTALLER_ROOT}/config/version-catalog.env"
        version_repository_list
        return 0
    fi

    install_service_load_config "${INSTALL_REQUEST_CONFIG}"
    install_service_require_config

    source "${INSTALLER_ROOT}/repositories/release_repository.sh"
    source "${INSTALLER_ROOT}/tools/os_tool.sh"
    source "${INSTALLER_ROOT}/tools/systemd_tool.sh"
    source "${INSTALLER_ROOT}/tools/nginx_tool.sh"

    version_repository_resolve "${INSTALL_REQUEST_VERSION:-${NOP_DEFAULT_VERSION}}"

    console_view_info "${MSG_START}"

    os_tool_require_root
    os_tool_validate_platform
    os_tool_install_dependencies

    release_repository_resolve_metadata

    os_tool_install_dotnet_runtime
    os_tool_ensure_service_account

    release_repository_prepare
    release_repository_download
    release_repository_deploy

    systemd_tool_install
    systemd_tool_start

    nginx_tool_install

    console_view_info "${MSG_DONE}"
    console_view_value "${MSG_URL}" "${NOP_PUBLIC_HOST}"
}
