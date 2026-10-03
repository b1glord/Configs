# 📄 Dosya Yolu: /NopCommerce/current/installer/repositories/database_repository.sh
# 📌 Amac: Veritabani provider secimini, surum uyumlulugunu ve dataSettings.json uretimini yonetmek
# 📌 Modul - Shell
# Version: 1.0.2
# Aciklama: SQL Server, MySQL ve PostgreSQL icin geriye uyumlu ve secret-korumali DB config adapteri
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
    if [[ ! -f "${NOP_DB_SECRET_FILE}" ]]; then
        console_view_error "${ERR_DB_SECRET_FILE}: ${NOP_DB_SECRET_FILE}"
        return 66
    fi

    if ! database_repository_validate_secret_permissions; then
        return 77
    fi

    unset NOP_DB_CONNECTION_STRING

    set -a
    source "${NOP_DB_SECRET_FILE}"
    set +a

    if [[ -z "${NOP_DB_CONNECTION_STRING:-}" ]]; then
        console_view_error "${ERR_DB_CONNECTION_STRING}"
        return 78
    fi

    return 0
}

database_repository_write_settings() {
    local target_file
    local target_dir
    local temp_file

    if [[ "${NOP_DB_PROVIDER_OFFICIAL}" == "Web" ]]; then
        return 0
    fi

    if ! database_repository_load_secret; then
        return $?
    fi

    target_file="${NOP_CURRENT_DIR}/${NOP_DB_SETTINGS_RELATIVE_PATH}"
    target_dir="$(dirname "${target_file}")"
    temp_file="${NOP_TEMP_DIR}/dataSettings.json"

    mkdir -p "${target_dir}" "${NOP_TEMP_DIR}"

    jq -n         --arg connection "${NOP_DB_CONNECTION_STRING}"         --arg provider "${NOP_DB_PROVIDER_OFFICIAL}"         '{
            DataConnectionString: $connection,
            DataProvider: $provider
        }' > "${temp_file}"

    install -o "${NOP_SERVICE_USER}"         -g "${NOP_SERVICE_GROUP}"         -m "${NOP_DB_SETTINGS_FILE_MODE}"         "${temp_file}"         "${target_file}"

    rm -f "${temp_file}"

    console_view_info "${MSG_DB_CONFIG_WRITTEN}"
}

database_repository_list() {
    console_view_info "${MSG_DB_MATRIX}"
    printf '%s\n' "4.30: SqlServer, MySql"
    printf '%s\n' "4.40+: SqlServer, MySql, PostgreSQL"
    printf '%s\n' "web: nopCommerce ilk kurulum sihirbazini kullan"
}
