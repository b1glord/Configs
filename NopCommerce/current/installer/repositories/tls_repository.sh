# 📄 Dosya Yolu: /NopCommerce/current/installer/repositories/tls_repository.sh
# 📌 Amac: TLS modunu, domain/email kurallarini ve native/docker sertifika yollarini cozumlemek
# 📌 Modul - Shell
# Version: 1.0.0
# Aciklama: Let's Encrypt webroot profile business kurallarini merkezi olarak uygular
# Bagimli Oldugu Katman: Config | View | Language

set -Eeuo pipefail

tls_repository_colon_list_contains() {
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

tls_repository_validate_domain() {
    local domain="$1"

    if ! [[ "${domain}" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,63}$ ]] ||        [[ "${domain}" == *".."* ]] ||        [[ "${domain}" == -* ]] ||        [[ "${domain}" == *-.* ]] ||        [[ "${domain}" == *".-"* ]] ||        [[ "${domain}" == *"-" ]]; then
        console_view_error "${ERR_TLS_DOMAIN}: ${domain}"
        return 64
    fi
}

tls_repository_validate_email() {
    local email="$1"

    if ! [[ "${email}" =~ ^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$ ]]; then
        console_view_error "${ERR_TLS_EMAIL}: ${email}"
        return 64
    fi
}

tls_repository_resolve_mode() {
    local requested_mode="$1"
    local normalized

    normalized="$(printf '%s' "${requested_mode}" | tr '[:upper:]' '[:lower:]')"

    if ! tls_repository_colon_list_contains "${NOP_TLS_MODES}" "${normalized}"; then
        console_view_error "${ERR_TLS_MODE}: ${requested_mode}"
        return 64
    fi

    export NOP_TLS_MODE_RESOLVED="${normalized}"
    console_view_value "${MSG_TLS_MODE}" "${NOP_TLS_MODE_RESOLVED}"

    if [[ "${NOP_TLS_MODE_RESOLVED}" == "off" ]]; then
        return 0
    fi

    tls_repository_validate_domain "${NOP_TLS_DOMAIN}"
    tls_repository_validate_email "${NOP_TLS_EMAIL}"

    export NOP_PUBLIC_HOST="${NOP_TLS_DOMAIN}"

    case "${NOP_APP_MODE_RESOLVED}" in
        native)
            export NOP_TLS_CERT_ROOT_RESOLVED="${NOP_TLS_NATIVE_CERT_ROOT}"
            export NOP_TLS_WEBROOT_RESOLVED="${NOP_TLS_NATIVE_WEBROOT}"
            export NOP_TLS_NGINX_CERT_ROOT_RESOLVED="${NOP_TLS_NATIVE_CERT_ROOT}"
            export NOP_TLS_NGINX_WEBROOT_RESOLVED="${NOP_TLS_NATIVE_WEBROOT}"
            ;;
        docker)
            export NOP_TLS_CERT_ROOT_RESOLVED="${NOP_TLS_DOCKER_CERT_ROOT}"
            export NOP_TLS_WEBROOT_RESOLVED="${NOP_TLS_DOCKER_WEBROOT}"
            export NOP_TLS_NGINX_CERT_ROOT_RESOLVED="${NOP_TLS_DOCKER_NGINX_CERT_ROOT}"
            export NOP_TLS_NGINX_WEBROOT_RESOLVED="${NOP_TLS_DOCKER_NGINX_WEBROOT}"
            ;;
        *)
            console_view_error "${ERR_APP_MODE}: ${NOP_APP_MODE_RESOLVED}"
            return 64
            ;;
    esac

    export NOP_TLS_FULLCHAIN_PATH="${NOP_TLS_NGINX_CERT_ROOT_RESOLVED}/live/${NOP_TLS_DOMAIN}/fullchain.pem"
    export NOP_TLS_PRIVKEY_PATH="${NOP_TLS_NGINX_CERT_ROOT_RESOLVED}/live/${NOP_TLS_DOMAIN}/privkey.pem"
}

tls_repository_list() {
    console_view_info "${MSG_TLS_MODES}"
    printf '%s\n' "off: HTTP"
    printf '%s\n' "letsencrypt: HTTP-01 webroot + otomatik renewal"
}
