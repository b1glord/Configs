# 📄 Dosya Yolu: /NopCommerce/current/installer/tools/nginx_tool.sh
# 📌 Amac: Native nopCommerce Nginx HTTP/HTTPS reverse proxy konfigurasyonunu uretmek ve etkinlestirmek
# 📌 Modul - Shell
# Version: 1.2.1
# Aciklama: HTTP bootstrap veya Let's Encrypt TLS template'ini doldurur, test eder ve Nginx'i reload eder
# Bagimli Oldugu Katman: Config | Repo | View | Language

set -Eeuo pipefail

nginx_tool_escape_sed() {
    printf '%s' "$1" | sed 's/[&|]/\\&/g'
}

nginx_tool_install() {
    local phase="${1:-http}"
    local template_path
    local public_host
    local upstream
    local acme_webroot
    local fullchain
    local privkey

    public_host="$(nginx_tool_escape_sed "${NOP_PUBLIC_HOST}")"
    upstream="$(nginx_tool_escape_sed "${NOP_ASPNETCORE_URLS}")"
    acme_webroot="$(nginx_tool_escape_sed "${NOP_TLS_WEBROOT_RESOLVED:-${NOP_TLS_NATIVE_WEBROOT}}")"

    mkdir -p "${NOP_TLS_WEBROOT_RESOLVED:-${NOP_TLS_NATIVE_WEBROOT}}/.well-known/acme-challenge"

    case "${phase}" in
        http)
            template_path="${INSTALLER_ROOT}/config/nginx.conf.tpl"

            sed                 -e "s|__PUBLIC_HOST__|${public_host}|g"                 -e "s|__UPSTREAM__|${upstream}|g"                 -e "s|__ACME_WEBROOT__|${acme_webroot}|g"                 "${template_path}" > "${NOP_NGINX_SITE_AVAILABLE}"
            ;;
        tls)
            template_path="${INSTALLER_ROOT}/config/nginx.tls.conf.tpl"
            fullchain="$(nginx_tool_escape_sed "${NOP_TLS_FULLCHAIN_PATH}")"
            privkey="$(nginx_tool_escape_sed "${NOP_TLS_PRIVKEY_PATH}")"

            sed                 -e "s|__PUBLIC_HOST__|${public_host}|g"                 -e "s|__UPSTREAM__|${upstream}|g"                 -e "s|__ACME_WEBROOT__|${acme_webroot}|g"                 -e "s|__TLS_FULLCHAIN__|${fullchain}|g"                 -e "s|__TLS_PRIVKEY__|${privkey}|g"                 "${template_path}" > "${NOP_NGINX_SITE_AVAILABLE}"
            ;;
        *)
            console_view_error "${ERR_TLS_NGINX_PHASE}: ${phase}"
            return 64
            ;;
    esac

    console_view_info "${MSG_NGINX}"

    ln -sfn "${NOP_NGINX_SITE_AVAILABLE}" "${NOP_NGINX_SITE_ENABLED}"

    if [[ "${NOP_DISABLE_DEFAULT_NGINX_SITE:-0}" == "1" ]]; then
        rm -f "${NOP_DEFAULT_NGINX_SITE}"
    fi

    nginx -t
    systemctl enable --now nginx.service
    systemctl reload nginx.service
}
