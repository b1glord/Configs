# 📄 Dosya Yolu: /NopCommerce/current/installer/repositories/database_repository.sh
# 📌 Amac: Veritabani provider/mod secimini, surum uyumlulugunu ve dataSettings.json uretimini yonetmek
# 📌 Modul - Shell
# Version: 1.2.0
# Aciklama: Native host veya Docker stack hedefi icin geriye uyumlu ve secret-korumali DB config adapteri
# Bagimli Oldugu Katman: Config | View | Language

set -Eeuo pipefail

database_repository_map_get() {
    local map_value="$1"
    local search_key="$2"
    local entry
    local key
    local value
    local entries

    IFS=';' read -r -a entries <<< "${map_value}"

    for entry in "${entries[@]}"; do
        key="${entry%%=*}"
        value="${entry#*=}"

        if [[ "${key}" == "${search_key}" ]]; then
            printf '%s' "${value}"
            return 0
        fi
    done

    return 1
}

database_repository_colon_list_contains() {
    local list_value="$1"
    local expected="$2"
    local item
    local items

    IFS=':' read -r -a items <<< "${list_value}"

    for item in "${items[@]}"; do
        if [[ "${item}" == "${expected}" ]]; then
            return 0
        fi
    done

    return 1
}

database_repository_provider_supported() {
    local family="$1"
    local provider="$2"
    local supported
    local item
    local providers

    supported="$(database_repository_map_get "${NOP_DB_PROVIDER_SUPPORT}" "${family}" || true)"

    if [[ -z "${supported}" ]]; then
        return 1
    fi

    IFS=',' read -r -a providers <<< "${supported}"

    for item in "${providers[@]}"; do
        if [[ "${item}" == "${provider}" ]]; then
            return 0
        fi
    done

    return 1
}

database_repository_resolve_provider() {
    local requested_provider="$1"
    local normalized
    local official

    normalized="$(printf '%s' "${requested_provider}" | tr '[:upper:]' '[:lower:]')"
    official="$(database_repository_map_get "${NOP_DB_PROVIDER_ALIASES}" "${normalized}" || true)"

    if [[ -z "${official}" ]]; then
        console_view_error "${ERR_DB_PROVIDER}: ${requested_provider}"
        return 64
    fi

    export NOP_DB_PROVIDER_REQUESTED="${normalized}"
    export NOP_DB_PROVIDER_OFFICIAL="${official}"

    if [[ "${official}" == "Web" ]]; then
        console_view_info "${MSG_DB_WEB_SETUP}"
        return 0
    fi

    if ! database_repository_provider_supported "${NOP_VERSION_FAMILY}" "${official}"; then
        console_view_error "${ERR_DB_UNSUPPORTED}: ${NOP_VERSION} -> ${official}"
        return 65
    fi

    console_view_value "${MSG_DB_PROVIDER}" "${official}"
}

database_repository_resolve_mode() {
    local requested_mode="$1"
    local normalized

    normalized="$(printf '%s' "${requested_mode}" | tr '[:upper:]' '[:lower:]')"

    if ! database_repository_colon_list_contains "${NOP_DB_MODES}" "${normalized}"; then
        console_view_error "${ERR_DB_MODE}: ${requested_mode}"
        return 64
    fi

    if [[ "${NOP_DB_PROVIDER_OFFICIAL}" == "Web" && "${normalized}" != "external" ]]; then
        console_view_error "${ERR_DB_WEB_DOCKER}"
        return 65
    fi

    if [[ "${normalized}" == "docker" ]] &&        ! database_repository_colon_list_contains "${NOP_DB_DOCKER_PROVIDERS}" "${NOP_DB_PROVIDER_OFFICIAL}"; then
        console_view_error "${ERR_DB_DOCKER_PROVIDER}: ${NOP_DB_PROVIDER_OFFICIAL}"
        return 65
    fi

    export NOP_DB_MODE_RESOLVED="${normalized}"
    console_view_value "${MSG_DB_MODE}" "${NOP_DB_MODE_RESOLVED}"
}

database_repository_validate_identifier() {
    local label="$1"
    local value="$2"

    if ! [[ "${value}" =~ ^[A-Za-z0-9_]+$ ]]; then
        console_view_error "${ERR_DB_IDENTIFIER}: ${label}"
        return 64
    fi
}

database_repository_validate_port() {
    local value="$1"

    [[ "${value}" =~ ^[0-9]+$ ]] && (( value >= 1 && value <= 65535 ))
}

database_repository_validate_docker_config() {
    database_repository_validate_identifier "NOP_DB_NAME" "${NOP_DB_NAME}"
    database_repository_validate_identifier "NOP_DB_USER" "${NOP_DB_USER}"

    if ! database_repository_validate_port "${NOP_DB_DOCKER_MYSQL_PORT}" ||        ! database_repository_validate_port "${NOP_DB_DOCKER_POSTGRESQL_PORT}" ||        ! database_repository_validate_port "${NOP_DB_DOCKER_MYSQL_INTERNAL_PORT}" ||        ! database_repository_validate_port "${NOP_DB_DOCKER_POSTGRESQL_INTERNAL_PORT}" ||        ! [[ "${NOP_DB_DOCKER_START_TIMEOUT}" =~ ^[0-9]+$ ]] ||        (( NOP_DB_DOCKER_START_TIMEOUT < 1 )); then
        console_view_error "${ERR_DB_DOCKER_NUMBER}"
        return 64
    fi

    if ! [[ "${NOP_DB_DOCKER_CONTAINER_PREFIX}" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]] ||        ! [[ "${NOP_DB_DOCKER_VOLUME_PREFIX}" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]]; then
        console_view_error "${ERR_DB_DOCKER_NAME}"
        return 64
    fi
}

database_repository_validate_secret_permissions() {
    if [[ "${NOP_DB_SECRET_REQUIRE_PRIVATE}" != "1" ]]; then
        return 0
    fi

    if find "${NOP_DB_SECRET_FILE}" -maxdepth 0 -perm /077 -print -quit | grep -q .; then
        console_view_error "${ERR_DB_SECRET_PERMISSIONS}: ${NOP_DB_SECRET_FILE}"
        return 77
    fi

    return 0
}

database_repository_load_secret() {
    if [[ "${NOP_DB_PROVIDER_OFFICIAL}" == "Web" ]]; then
        return 0
    fi

    if [[ ! -f "${NOP_DB_SECRET_FILE}" ]]; then
        console_view_error "${ERR_DB_SECRET_FILE}: ${NOP_DB_SECRET_FILE}"
        return 66
    fi

    database_repository_validate_secret_permissions || return $?

    unset NOP_DB_CONNECTION_STRING
    unset NOP_DB_PASSWORD
    unset NOP_DB_ROOT_PASSWORD

    set -a
    source "${NOP_DB_SECRET_FILE}"
    set +a

    if [[ "${NOP_DB_MODE_RESOLVED}" == "external" ]]; then
        if [[ -z "${NOP_DB_CONNECTION_STRING:-}" ]]; then
            console_view_error "${ERR_DB_CONNECTION_STRING}"
            return 78
        fi
        return 0
    fi

    if [[ -z "${NOP_DB_PASSWORD:-}" ]]; then
        console_view_error "${ERR_DB_PASSWORD}"
        return 78
    fi

    if [[ "${NOP_DB_PROVIDER_OFFICIAL}" == "MySql" && -z "${NOP_DB_ROOT_PASSWORD:-}" ]]; then
        console_view_error "${ERR_DB_ROOT_PASSWORD}"
        return 78
    fi

    return 0
}

database_repository_build_docker_connection_string() {
    local scope="${1:-host}"
    local host
    local port

    case "${scope}" in
        host)
            host="${NOP_DB_DOCKER_BIND_HOST}"
            ;;
        stack)
            host="${NOP_DOCKER_STACK_DATABASE_SERVICE}"
            ;;
        *)
            console_view_error "${ERR_DB_CONNECTION_SCOPE}: ${scope}"
            return 64
            ;;
    esac

    case "${NOP_DB_PROVIDER_OFFICIAL}" in
        MySql)
            if [[ "${scope}" == "stack" ]]; then
                port="${NOP_DB_DOCKER_MYSQL_INTERNAL_PORT}"
            else
                port="${NOP_DB_DOCKER_MYSQL_PORT}"
            fi
            export NOP_DB_CONNECTION_STRING="Server=${host};Port=${port};Database=${NOP_DB_NAME};User=${NOP_DB_USER};Password=${NOP_DB_PASSWORD};SslMode=Preferred"
            ;;
        PostgreSQL)
            if [[ "${scope}" == "stack" ]]; then
                port="${NOP_DB_DOCKER_POSTGRESQL_INTERNAL_PORT}"
            else
                port="${NOP_DB_DOCKER_POSTGRESQL_PORT}"
            fi
            export NOP_DB_CONNECTION_STRING="Host=${host};Port=${port};Database=${NOP_DB_NAME};Username=${NOP_DB_USER};Password=${NOP_DB_PASSWORD}"
            ;;
        *)
            console_view_error "${ERR_DB_DOCKER_PROVIDER}: ${NOP_DB_PROVIDER_OFFICIAL}"
            return 65
            ;;
    esac
}

database_repository_prepare_connection() {
    local scope="${1:-host}"

    if [[ "${NOP_DB_PROVIDER_OFFICIAL}" == "Web" ]]; then
        return 0
    fi

    database_repository_load_secret || return $?

    if [[ "${NOP_DB_MODE_RESOLVED}" == "docker" ]]; then
        database_repository_validate_docker_config
        database_repository_build_docker_connection_string "${scope}"
    fi
}

database_repository_write_settings() {
    local app_root="${1:-${NOP_CURRENT_DIR}}"
    local target_file
    local target_dir
    local temp_file

    if [[ "${NOP_DB_PROVIDER_OFFICIAL}" == "Web" ]]; then
        return 0
    fi

    if [[ -z "${NOP_DB_CONNECTION_STRING:-}" ]]; then
        console_view_error "${ERR_DB_CONNECTION_STRING}"
        return 78
    fi

    target_file="${app_root}/${NOP_DB_SETTINGS_RELATIVE_PATH}"
    target_dir="$(dirname "${target_file}")"
    temp_file="${NOP_TEMP_DIR}/dataSettings.json"

    mkdir -p "${target_dir}" "${NOP_TEMP_DIR}"

    jq -n         --arg connection "${NOP_DB_CONNECTION_STRING}"         --arg provider "${NOP_DB_PROVIDER_OFFICIAL}"         '{
            DataConnectionString: $connection,
            DataProvider: $provider
        }' > "${temp_file}"

    install         -o "${NOP_SERVICE_USER}"         -g "${NOP_SERVICE_GROUP}"         -m "${NOP_DB_SETTINGS_FILE_MODE}"         "${temp_file}"         "${target_file}"

    rm -f "${temp_file}"

    console_view_info "${MSG_DB_CONFIG_WRITTEN}"
}

database_repository_list() {
    console_view_info "${MSG_DB_MATRIX}"
    printf '%s\n' "4.30: SqlServer, MySql"
    printf '%s\n' "4.40+: SqlServer, MySql, PostgreSQL"
    printf '%s\n' "external: Web, SqlServer, MySql, PostgreSQL"
    printf '%s\n' "docker + native app: MySql, PostgreSQL"
    printf '%s\n' "docker + docker app: MySql, PostgreSQL (internal Compose network)"
}
