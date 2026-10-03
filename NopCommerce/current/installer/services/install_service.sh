# 📄 Dosya Yolu: /NopCommerce/current/installer/services/install_service.sh
# 📌 Amac: nopCommerce cok surumlu, DB-secimli ve opsiyonel Docker DB kurulum akisinin is kurallarini yonetmek
# 📌 Modul - Shell
# Version: 1.4.0
# Aciklama: CLI, surum/DB cozumleme, release, runtime, DB provisioning/config, systemd ve Nginx orkestrasyonu
# Bagimli Oldugu Katman: Repo | Tool | View | Config | Language

set -Eeuo pipefail

install_service_require_config() {
    local key

    for key in         NOP_DEFAULT_VERSION         NOP_RELEASE_API_BASE         NOP_RELEASE_TAG_FORMAT         NOP_PACKAGE_NAME_FORMAT         NOP_ALLOW_LEGACY_WITHOUT_SHA256         NOP_INSTALL_ROOT         NOP_RELEASES_DIR         NOP_CURRENT_DIR         NOP_BACKUP_DIR         NOP_TEMP_DIR         NOP_SERVICE_NAME         NOP_SERVICE_USER         NOP_SERVICE_GROUP         NOP_ASPNETCORE_URLS         NOP_PUBLIC_HOST         NOP_NGINX_SITE_AVAILABLE         NOP_NGINX_SITE_ENABLED         NOP_DEFAULT_NGINX_SITE         NOP_SYSTEMD_UNIT         NOP_DOTNET_ROOT         NOP_DOTNET_EXECUTABLE         NOP_DOTNET_SYMLINK         NOP_DOTNET_INSTALL_SCRIPT_URL         NOP_DOTNET_RUNTIME_KIND         NOP_DB_PROVIDER         NOP_DB_MODE         NOP_DB_SECRET_FILE         NOP_DB_SECRET_REQUIRE_PRIVATE         NOP_DB_SETTINGS_RELATIVE_PATH         NOP_DB_SETTINGS_FILE_MODE         NOP_DB_NAME         NOP_DB_USER         NOP_DB_DOCKER_BIND_HOST         NOP_DB_DOCKER_MYSQL_PORT         NOP_DB_DOCKER_POSTGRESQL_PORT         NOP_DB_DOCKER_MYSQL_IMAGE         NOP_DB_DOCKER_POSTGRESQL_IMAGE         NOP_DB_DOCKER_CONTAINER_PREFIX         NOP_DB_DOCKER_VOLUME_PREFIX         NOP_DB_DOCKER_START_TIMEOUT         NOP_DOCKER_EXECUTABLE         NOP_SUPPORTED_OS         NOP_OS_RELEASE_FILE         NOP_NOLOGIN_SHELL         NOP_APT_BASE_PACKAGES         NOP_WRITABLE_PATHS         NOP_SUPPORTED_VERSION_FAMILIES         NOP_VERSION_PATTERN         NOP_VERSION_ALIASES         NOP_RUNTIME_CHANNELS         NOP_PACKAGE_NAME_OVERRIDES         NOP_LEGACY_VERSION_FAMILIES         NOP_DB_PROVIDER_ALIASES         NOP_DB_PROVIDER_SUPPORT         NOP_DB_MODES         NOP_DB_DOCKER_PROVIDERS
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
    local requested_db=""
    local requested_db_mode=""
    local list_versions="0"
    local list_databases="0"

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
            --db)
                if [[ "$#" -lt 2 || -z "${2:-}" ]]; then
                    console_view_error "${ERR_USAGE}"
                    return 64
                fi
                requested_db="$2"
                shift 2
                ;;
            --db-mode)
                if [[ "$#" -lt 2 || -z "${2:-}" ]]; then
                    console_view_error "${ERR_USAGE}"
                    return 64
                fi
                requested_db_mode="$2"
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
            --list-databases)
                list_databases="1"
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
    export INSTALL_REQUEST_DB_PROVIDER="${requested_db}"
    export INSTALL_REQUEST_DB_MODE="${requested_db_mode}"
    export INSTALL_REQUEST_LIST_VERSIONS="${list_versions}"
    export INSTALL_REQUEST_LIST_DATABASES="${list_databases}"
}

install_service_load_catalogs() {
    source "${INSTALLER_ROOT}/config/version-catalog.env"
    source "${INSTALLER_ROOT}/config/database-catalog.env"
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
    install_service_load_catalogs
    set +a
}

install_service_prepare_database() {
    if [[ "${NOP_DB_PROVIDER_OFFICIAL}" == "Web" ]]; then
        return 0
    fi

    database_repository_prepare_connection

    if [[ "${NOP_DB_MODE_RESOLVED}" == "docker" ]]; then
        docker_database_tool_provision
    fi
}

install_service_run() {
    local installer_root="$1"
    shift

    export INSTALLER_ROOT="${installer_root}"

    source "${INSTALLER_ROOT}/language/tr.labels"
    source "${INSTALLER_ROOT}/views/console_view.sh"
    source "${INSTALLER_ROOT}/repositories/version_repository.sh"
    source "${INSTALLER_ROOT}/repositories/database_repository.sh"

    install_service_parse_args "$@"

    if [[ "${INSTALL_REQUEST_LIST_VERSIONS}" == "1" ]]; then
        install_service_load_catalogs
        version_repository_list
        return 0
    fi

    if [[ "${INSTALL_REQUEST_LIST_DATABASES}" == "1" ]]; then
        install_service_load_catalogs
        database_repository_list
        return 0
    fi

    install_service_load_config "${INSTALL_REQUEST_CONFIG}"
    install_service_require_config

    source "${INSTALLER_ROOT}/repositories/release_repository.sh"
    source "${INSTALLER_ROOT}/tools/os_tool.sh"
    source "${INSTALLER_ROOT}/tools/systemd_tool.sh"
    source "${INSTALLER_ROOT}/tools/nginx_tool.sh"
    source "${INSTALLER_ROOT}/tools/docker_database_tool.sh"

    version_repository_resolve "${INSTALL_REQUEST_VERSION:-${NOP_DEFAULT_VERSION}}"
    database_repository_resolve_provider "${INSTALL_REQUEST_DB_PROVIDER:-${NOP_DB_PROVIDER}}"
    database_repository_resolve_mode "${INSTALL_REQUEST_DB_MODE:-${NOP_DB_MODE}}"

    console_view_info "${MSG_START}"

    os_tool_require_root
    os_tool_validate_platform
    os_tool_install_dependencies

    release_repository_resolve_metadata

    os_tool_install_dotnet_runtime
    os_tool_ensure_service_account

    install_service_prepare_database

    release_repository_prepare
    release_repository_download
    release_repository_deploy

    database_repository_write_settings

    systemd_tool_install
    systemd_tool_start

    nginx_tool_install

    console_view_info "${MSG_DONE}"
    console_view_value "${MSG_URL}" "${NOP_PUBLIC_HOST}"
}
