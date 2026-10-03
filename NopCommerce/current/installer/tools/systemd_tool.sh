# 📄 Dosya Yolu: /NopCommerce/current/installer/tools/systemd_tool.sh
# 📌 Amac: nopCommerce systemd unit dosyasini uretmek ve servisi yonetmek
# 📌 Modul - Shell
# Version: 1.1.0
# Aciklama: Cok surumlu .NET runtime yolu ile systemd dis dunya adaptoru
# Bagimli Oldugu Katman: Config | View | Language

set -Eeuo pipefail

systemd_tool_escape_sed() {
    printf '%s' "$1" | sed 's/[&|]/\\&/g'
}

systemd_tool_install() {
    local template_path
    local app_dir
    local service_name
    local service_user
    local service_group
    local aspnetcore_urls
    local dotnet_executable
    local dotnet_root

    template_path="${INSTALLER_ROOT}/config/nopcommerce.service.tpl"
    app_dir="$(systemd_tool_escape_sed "${NOP_CURRENT_DIR}")"
    service_name="$(systemd_tool_escape_sed "${NOP_SERVICE_NAME}")"
    service_user="$(systemd_tool_escape_sed "${NOP_SERVICE_USER}")"
    service_group="$(systemd_tool_escape_sed "${NOP_SERVICE_GROUP}")"
    aspnetcore_urls="$(systemd_tool_escape_sed "${NOP_ASPNETCORE_URLS}")"
    dotnet_executable="$(systemd_tool_escape_sed "${NOP_DOTNET_EXECUTABLE}")"
    dotnet_root="$(systemd_tool_escape_sed "${NOP_DOTNET_ROOT}")"

    console_view_info "${MSG_SYSTEMD}"

    sed         -e "s|__APP_DIR__|${app_dir}|g"         -e "s|__SERVICE_NAME__|${service_name}|g"         -e "s|__SERVICE_USER__|${service_user}|g"         -e "s|__SERVICE_GROUP__|${service_group}|g"         -e "s|__ASPNETCORE_URLS__|${aspnetcore_urls}|g"         -e "s|__DOTNET_EXECUTABLE__|${dotnet_executable}|g"         -e "s|__DOTNET_ROOT__|${dotnet_root}|g"         "${template_path}" > "${NOP_SYSTEMD_UNIT}"

    systemctl daemon-reload
    systemctl enable "${NOP_SERVICE_NAME}.service"
}

systemd_tool_start() {
    systemctl restart "${NOP_SERVICE_NAME}.service"
    systemctl --no-pager --full status "${NOP_SERVICE_NAME}.service"
}
