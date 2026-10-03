# 📄 Dosya Yolu: /NopCommerce/current/installer/services/install_service.sh
# 📌 Amac: nopCommerce cok surumlu, DB-secimli, native/Docker ve opsiyonel TLS deployment akisinin is kurallarini yonetmek
# 📌 Modul - Shell
# Version: 1.6.1
# Aciklama: CLI, surum/app/DB/TLS cozumleme, release, HTTP bootstrap, Let's Encrypt ve deployment orkestrasyonu
# Bagimli Oldugu Katman: Repo | Tool | View | Config | Language

set -Eeuo pipefail

install_service_require_config() {
    local key

    for key in         NOP_DEFAULT_VERSION         NOP_RELEASE_API_BASE         NOP_RELEASE_TAG_FORMAT         NOP_PACKAGE_NAME_FORMAT         NOP_ALLOW_LEGACY_WITHOUT_SHA256         NOP_INSTALL_ROOT         NOP_RELEASES_DIR         NOP_CURRENT_DIR         NOP_BACKUP_DIR         NOP_TEMP_DIR         NOP_APP_MODE         NOP_SERVICE_NAME         NOP_SERVICE_USER         NOP_SERVICE_GROUP         NOP_ASPNETCORE_URLS         NOP_PUBLIC_HOST         NOP_NGINX_SITE_AVAILABLE         NOP_NGINX_SITE_ENABLED         NOP_DEFAULT_NGINX_SITE         NOP_SYSTEMD_UNIT         NOP_DOTNET_ROOT         NOP_DOTNET_EXECUTABLE         NOP_DOTNET_SYMLINK         NOP_DOTNET_INSTALL_SCRIPT_URL         NOP_DOTNET_RUNTIME_KIND         NOP_TLS_MODE         NOP_TLS_STAGING         NOP_TLS_NATIVE_CERTBOT_EXECUTABLE         NOP_TLS_CERTBOT_IMAGE         NOP_TLS_NATIVE_CERT_ROOT         NOP_TLS_NATIVE_WEBROOT         NOP_TLS_DOCKER_CERT_ROOT         NOP_TLS_DOCKER_WEBROOT         NOP_TLS_DOCKER_NGINX_CERT_ROOT         NOP_TLS_DOCKER_NGINX_WEBROOT         NOP_TLS_DOCKER_CERTBOT_CERT_ROOT         NOP_TLS_DOCKER_CERTBOT_WEBROOT         NOP_TLS_DEPLOY_HOOK         NOP_TLS_RENEW_SCRIPT         NOP_TLS_RENEW_SERVICE         NOP_TLS_RENEW_TIMER         NOP_TLS_RENEW_ON_CALENDAR         NOP_TLS_RENEW_RANDOM_DELAY_SEC         NOP_DB_PROVIDER         NOP_DB_MODE         NOP_DB_SECRET_FILE         NOP_DB_SECRET_REQUIRE_PRIVATE         NOP_DB_SETTINGS_RELATIVE_PATH         NOP_DB_SETTINGS_FILE_MODE         NOP_DB_NAME         NOP_DB_USER         NOP_DB_DOCKER_BIND_HOST         NOP_DB_DOCKER_MYSQL_PORT         NOP_DB_DOCKER_POSTGRESQL_PORT         NOP_DB_DOCKER_MYSQL_INTERNAL_PORT         NOP_DB_DOCKER_POSTGRESQL_INTERNAL_PORT         NOP_DB_DOCKER_MYSQL_IMAGE         NOP_DB_DOCKER_POSTGRESQL_IMAGE         NOP_DB_DOCKER_CONTAINER_PREFIX         NOP_DB_DOCKER_VOLUME_PREFIX         NOP_DB_DOCKER_START_TIMEOUT         NOP_DOCKER_EXECUTABLE         NOP_DOCKER_STACK_PROJECT         NOP_DOCKER_STACK_ROOT         NOP_DOCKER_STACK_PERSIST_ROOT         NOP_DOCKER_STACK_COMPOSE_FILE         NOP_DOCKER_STACK_NGINX_CONFIG         NOP_DOCKER_STACK_DOCKERFILE_RELATIVE         NOP_DOCKER_STACK_DOCKERIGNORE_RELATIVE         NOP_DOCKER_STACK_APP_IMAGE         NOP_DOCKER_STACK_NGINX_IMAGE         NOP_DOCKER_STACK_APP_SERVICE         NOP_DOCKER_STACK_DATABASE_SERVICE         NOP_DOCKER_STACK_NGINX_SERVICE         NOP_DOCKER_STACK_APP_PORT         NOP_DOCKER_STACK_HTTP_BIND_HOST         NOP_DOCKER_STACK_HTTP_PORT         NOP_DOCKER_STACK_HTTPS_BIND_HOST         NOP_DOCKER_STACK_HTTPS_PORT         NOP_DOCKER_STACK_PERSIST_PATHS         NOP_SUPPORTED_OS         NOP_OS_RELEASE_FILE         NOP_NOLOGIN_SHELL         NOP_APT_BASE_PACKAGES         NOP_APT_NATIVE_PACKAGES         NOP_APT_TLS_PACKAGES         NOP_WRITABLE_PATHS         NOP_SUPPORTED_VERSION_FAMILIES         NOP_VERSION_PATTERN         NOP_VERSION_ALIASES         NOP_RUNTIME_CHANNELS         NOP_PACKAGE_NAME_OVERRIDES         NOP_LEGACY_VERSION_FAMILIES         NOP_DB_PROVIDER_ALIASES         NOP_DB_PROVIDER_SUPPORT         NOP_DB_MODES         NOP_DB_DOCKER_PROVIDERS         NOP_APP_MODES         NOP_DOCKER_APP_RUNTIME_IMAGES         NOP_DOCKER_APP_RUNTIME_PROFILES         NOP_TLS_MODES
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
    local requested_app_mode=""
    local requested_tls_mode=""
    local list_versions="0"
    local list_databases="0"
    local list_app_modes="0"
    local list_tls_modes="0"

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
            --app-mode)
                if [[ "$#" -lt 2 || -z "${2:-}" ]]; then
                    console_view_error "${ERR_USAGE}"
                    return 64
                fi
                requested_app_mode="$2"
                shift 2
                ;;
            --tls-mode)
                if [[ "$#" -lt 2 || -z "${2:-}" ]]; then
                    console_view_error "${ERR_USAGE}"
                    return 64
                fi
                requested_tls_mode="$2"
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
            --list-app-modes)
                list_app_modes="1"
                shift
                ;;
            --list-tls-modes)
                list_tls_modes="1"
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
    export INSTALL_REQUEST_APP_MODE="${requested_app_mode}"
    export INSTALL_REQUEST_TLS_MODE="${requested_tls_mode}"
    export INSTALL_REQUEST_LIST_VERSIONS="${list_versions}"
    export INSTALL_REQUEST_LIST_DATABASES="${list_databases}"
    export INSTALL_REQUEST_LIST_APP_MODES="${list_app_modes}"
    export INSTALL_REQUEST_LIST_TLS_MODES="${list_tls_modes}"
}

install_service_load_catalogs() {
    source "${INSTALLER_ROOT}/config/version-catalog.env"
    source "${INSTALLER_ROOT}/config/database-catalog.env"
    source "${INSTALLER_ROOT}/config/application-catalog.env"
    source "${INSTALLER_ROOT}/config/tls-catalog.env"
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
    local connection_scope="host"

    if [[ "${NOP_DB_PROVIDER_OFFICIAL}" == "Web" ]]; then
        return 0
    fi

    if [[ "${NOP_APP_MODE_RESOLVED}" == "docker" && "${NOP_DB_MODE_RESOLVED}" == "docker" ]]; then
        connection_scope="stack"
    fi

    database_repository_prepare_connection "${connection_scope}"

    if [[ "${NOP_APP_MODE_RESOLVED}" == "native" && "${NOP_DB_MODE_RESOLVED}" == "docker" ]]; then
        docker_database_tool_provision
    fi
}

install_service_enable_tls_native() {
    if [[ "${NOP_TLS_MODE_RESOLVED}" != "letsencrypt" ]]; then
        tls_tool_disable_renewal_timer
        return 0
    fi

    tls_tool_issue_certificate
    nginx_tool_install "tls"
    tls_tool_install_renewal_timer
}

install_service_enable_tls_docker() {
    if [[ "${NOP_TLS_MODE_RESOLVED}" != "letsencrypt" ]]; then
        tls_tool_disable_renewal_timer
        return 0
    fi

    tls_tool_issue_certificate
    docker_stack_tool_activate_tls
    tls_tool_install_renewal_timer
}

install_service_deploy_native() {
    database_repository_write_settings

    systemd_tool_install
    systemd_tool_start

    nginx_tool_install "http"
    install_service_enable_tls_native
}

install_service_deploy_docker() {
    docker_stack_tool_prepare_persistent_data
    database_repository_write_settings "${NOP_DOCKER_STACK_PERSIST_ROOT}"
    docker_stack_tool_install "http"
    install_service_enable_tls_docker
}

install_service_run() {
    local installer_root="$1"
    shift

    export INSTALLER_ROOT="${installer_root}"

    source "${INSTALLER_ROOT}/language/tr.labels"
    source "${INSTALLER_ROOT}/views/console_view.sh"
    source "${INSTALLER_ROOT}/repositories/version_repository.sh"
    source "${INSTALLER_ROOT}/repositories/database_repository.sh"
    source "${INSTALLER_ROOT}/repositories/application_repository.sh"
    source "${INSTALLER_ROOT}/repositories/tls_repository.sh"

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

    if [[ "${INSTALL_REQUEST_LIST_APP_MODES}" == "1" ]]; then
        install_service_load_catalogs
        application_repository_list
        return 0
    fi

    if [[ "${INSTALL_REQUEST_LIST_TLS_MODES}" == "1" ]]; then
        install_service_load_catalogs
        tls_repository_list
        return 0
    fi

    install_service_load_config "${INSTALL_REQUEST_CONFIG}"
    install_service_require_config

    source "${INSTALLER_ROOT}/repositories/release_repository.sh"
    source "${INSTALLER_ROOT}/tools/os_tool.sh"
    source "${INSTALLER_ROOT}/tools/systemd_tool.sh"
    source "${INSTALLER_ROOT}/tools/nginx_tool.sh"
    source "${INSTALLER_ROOT}/tools/docker_database_tool.sh"
    source "${INSTALLER_ROOT}/tools/docker_stack_tool.sh"
    source "${INSTALLER_ROOT}/tools/tls_tool.sh"

    version_repository_resolve "${INSTALL_REQUEST_VERSION:-${NOP_DEFAULT_VERSION}}"
    application_repository_resolve_mode "${INSTALL_REQUEST_APP_MODE:-${NOP_APP_MODE}}"
    tls_repository_resolve_mode "${INSTALL_REQUEST_TLS_MODE:-${NOP_TLS_MODE}}"
    database_repository_resolve_provider "${INSTALL_REQUEST_DB_PROVIDER:-${NOP_DB_PROVIDER}}"
    database_repository_resolve_mode "${INSTALL_REQUEST_DB_MODE:-${NOP_DB_MODE}}"

    console_view_info "${MSG_START}"

    os_tool_require_root
    os_tool_validate_platform
    os_tool_install_dependencies "${NOP_APP_MODE_RESOLVED}" "${NOP_TLS_MODE_RESOLVED}"

    release_repository_resolve_metadata

    if [[ "${NOP_APP_MODE_RESOLVED}" == "native" ]]; then
        os_tool_install_dotnet_runtime
    fi

    os_tool_ensure_service_account
    install_service_prepare_database

    release_repository_prepare
    release_repository_download
    release_repository_deploy

    case "${NOP_APP_MODE_RESOLVED}" in
        native)
            install_service_deploy_native
            ;;
        docker)
            install_service_deploy_docker
            ;;
        *)
            console_view_error "${ERR_APP_MODE}: ${NOP_APP_MODE_RESOLVED}"
            return 64
            ;;
    esac

    console_view_info "${MSG_DONE}"
    console_view_value "${MSG_URL}" "${NOP_PUBLIC_HOST}"
}
