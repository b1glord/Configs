# 📄 Dosya Yolu: /NopCommerce/current/installer/tools/nginx_tool.sh
# 📌 Amac: nopCommerce Nginx reverse proxy konfigurasyonunu uretmek ve etkinlestirmek
# 📌 Modul - Shell
# Version: 1.0.1
# Aciklama: Nginx dis dunya adaptoru
# Bagimli Oldugu Katman: Config | Language

set -Eeuo pipefail

nginx_tool_escape_sed() {
    printf '%s' "$1" | sed 's/[&|]/\\&/g'
}

nginx_tool_install() {
    local template_path
    local public_host
    local upstream

    template_path="${INSTALLER_ROOT}/config/nginx.conf.tpl"
    public_host="$(nginx_tool_escape_sed "${NOP_PUBLIC_HOST}")"
    upstream="$(nginx_tool_escape_sed "${NOP_ASPNETCORE_URLS}")"

    printf '%s\n' "${MSG_NGINX}"

    sed         -e "s|__PUBLIC_HOST__|${public_host}|g"         -e "s|__UPSTREAM__|${upstream}|g"         "${template_path}" > "${NOP_NGINX_SITE_AVAILABLE}"

    ln -sfn "${NOP_NGINX_SITE_AVAILABLE}" "${NOP_NGINX_SITE_ENABLED}"

    if [[ "${NOP_DISABLE_DEFAULT_NGINX_SITE:-0}" == "1" ]]; then
        rm -f "${NOP_DEFAULT_NGINX_SITE}"
    fi

    nginx -t
    systemctl enable nginx.service
    systemctl reload nginx.service
}
