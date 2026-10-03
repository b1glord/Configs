# 📄 Dosya Yolu: /NopCommerce/current/installer/repositories/version_repository.sh
# 📌 Amac: nopCommerce surum alias, aile ve .NET runtime eslestirmelerini cozumlemek
# 📌 Modul - Shell
# Version: 1.0.1
# Aciklama: Surum katalogunu okuyarak kurulum icin normalize edilmis release bilgilerini uretir
# Bagimli Oldugu Katman: Config | View | Language

set -Eeuo pipefail

version_repository_map_get() {
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

version_repository_family_for() {
    local version="$1"
    local family
    local families

    IFS=':' read -r -a families <<< "${NOP_SUPPORTED_VERSION_FAMILIES}"

    for family in "${families[@]}"; do
        if [[ "${version}" == "${family}" || "${version}" == "${family}."* ]]; then
            printf '%s' "${family}"
            return 0
        fi
    done

    return 1
}

version_repository_is_legacy_family() {
    local family="$1"
    local legacy_family
    local families

    IFS=':' read -r -a families <<< "${NOP_LEGACY_VERSION_FAMILIES}"

    for legacy_family in "${families[@]}"; do
        if [[ "${family}" == "${legacy_family}" ]]; then
            return 0
        fi
    done

    return 1
}

version_repository_resolve() {
    local requested_version="$1"
    local resolved_version
    local version_family
    local runtime_channel

    resolved_version="$(version_repository_map_get "${NOP_VERSION_ALIASES}" "${requested_version}" || true)"

    if [[ -z "${resolved_version}" ]]; then
        resolved_version="${requested_version}"
    fi

    if ! [[ "${resolved_version}" =~ ${NOP_VERSION_PATTERN} ]]; then
        console_view_error "${ERR_VERSION}: ${requested_version}"
        return 64
    fi

    version_family="$(version_repository_family_for "${resolved_version}" || true)"

    if [[ -z "${version_family}" ]]; then
        console_view_error "${ERR_VERSION}: ${requested_version}"
        return 64
    fi

    runtime_channel="$(version_repository_map_get "${NOP_RUNTIME_CHANNELS}" "${version_family}" || true)"

    if [[ -z "${runtime_channel}" ]]; then
        console_view_error "${ERR_RUNTIME_MAPPING}: ${version_family}"
        return 65
    fi

    export NOP_VERSION="${resolved_version}"
    export NOP_VERSION_FAMILY="${version_family}"
    export NOP_DOTNET_RUNTIME_CHANNEL="${runtime_channel}"

    printf -v NOP_RELEASE_TAG "${NOP_RELEASE_TAG_FORMAT}" "${NOP_VERSION}"
    printf -v NOP_PACKAGE_NAME "${NOP_PACKAGE_NAME_FORMAT}" "${NOP_VERSION}"

    export NOP_RELEASE_TAG
    export NOP_PACKAGE_NAME

    console_view_value "${MSG_SELECTED_VERSION}" "${NOP_VERSION}"
    console_view_value "${MSG_RUNTIME_CHANNEL}" "${NOP_DOTNET_RUNTIME_CHANNEL}"

    if version_repository_is_legacy_family "${NOP_VERSION_FAMILY}"; then
        console_view_warn "${MSG_LEGACY_RUNTIME}"
    fi
}

version_repository_list() {
    local entry
    local alias_name
    local resolved_version
    local entries

    console_view_versions

    IFS=';' read -r -a entries <<< "${NOP_VERSION_ALIASES}"

    for entry in "${entries[@]}"; do
        alias_name="${entry%%=*}"
        resolved_version="${entry#*=}"
        console_view_value "${alias_name}" "${resolved_version}"
    done

    console_view_info "${MSG_EXACT_VERSION_SUPPORT}"
}
