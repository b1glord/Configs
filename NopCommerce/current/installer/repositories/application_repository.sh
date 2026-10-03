# 📄 Dosya Yolu: /NopCommerce/current/installer/repositories/application_repository.sh
# 📌 Amac: Uygulama deployment modunu ve Docker runtime profilini cozumlemek
# 📌 Modul - Shell
# Version: 1.0.1
# Aciklama: native/docker modu ile nopCommerce surum ailesini resmi runtime image/profile eslestirmesine baglar
# Bagimli Oldugu Katman: Config | View | Language

set -Eeuo pipefail

application_repository_map_get() {
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

application_repository_colon_list_contains() {
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

application_repository_resolve_mode() {
    local requested_mode="$1"
    local normalized

    normalized="$(printf '%s' "${requested_mode}" | tr '[:upper:]' '[:lower:]')"

    if ! application_repository_colon_list_contains "${NOP_APP_MODES}" "${normalized}"; then
        console_view_error "${ERR_APP_MODE}: ${requested_mode}"
        return 64
    fi

    export NOP_APP_MODE_RESOLVED="${normalized}"
    console_view_value "${MSG_APP_MODE}" "${NOP_APP_MODE_RESOLVED}"

    if [[ "${NOP_APP_MODE_RESOLVED}" != "docker" ]]; then
        return 0
    fi

    export NOP_DOCKER_APP_RUNTIME_IMAGE
    export NOP_DOCKER_APP_RUNTIME_PROFILE

    NOP_DOCKER_APP_RUNTIME_IMAGE="$(application_repository_map_get "${NOP_DOCKER_APP_RUNTIME_IMAGES}" "${NOP_VERSION_FAMILY}" || true)"
    NOP_DOCKER_APP_RUNTIME_PROFILE="$(application_repository_map_get "${NOP_DOCKER_APP_RUNTIME_PROFILES}" "${NOP_VERSION_FAMILY}" || true)"

    if [[ -z "${NOP_DOCKER_APP_RUNTIME_IMAGE}" || -z "${NOP_DOCKER_APP_RUNTIME_PROFILE}" ]]; then
        console_view_error "${ERR_APP_DOCKER_RUNTIME}: ${NOP_VERSION}"
        return 65
    fi

    console_view_value "${MSG_APP_DOCKER_RUNTIME}" "${NOP_DOCKER_APP_RUNTIME_IMAGE}"
}

application_repository_list() {
    console_view_info "${MSG_APP_MODES}"
    printf '%s\n' "native: host .NET + systemd + host Nginx"
    printf '%s\n' "docker: nopCommerce + Nginx + opsiyonel DB Docker Compose stack"
}
