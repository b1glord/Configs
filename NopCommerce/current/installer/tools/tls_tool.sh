# 📄 Dosya Yolu: /NopCommerce/current/installer/tools/tls_tool.sh
# 📌 Amac: Native veya Docker nopCommerce deploymenti icin Let's Encrypt sertifika alma ve yenilemeyi yonetmek
# 📌 Modul - Shell
# Version: 1.1.0
# Aciklama: Certbot webroot issuance, Docker Certbot image, deploy hook ve systemd renewal timer adaptoru
# Bagimli Oldugu Katman: Config | Repo | View | Language

set -Eeuo pipefail

tls_tool_certificate_host_path() {
    printf '%s/live/%s/fullchain.pem' "${NOP_TLS_CERT_ROOT_RESOLVED}" "${NOP_TLS_DOMAIN}"
}

tls_tool_certificate_exists() {
    [[ -s "$(tls_tool_certificate_host_path)" ]]
}

tls_tool_prepare_directories() {
    mkdir -p         "${NOP_TLS_CERT_ROOT_RESOLVED}"         "${NOP_TLS_WEBROOT_RESOLVED}/.well-known/acme-challenge"

    chmod 755 "${NOP_TLS_WEBROOT_RESOLVED}"
}

tls_tool_staging_args() {
    if [[ "${NOP_TLS_STAGING}" == "1" ]]; then
        printf '%s' "--staging"
    fi
}

tls_tool_issue_native() {
    local staging_arg

    staging_arg="$(tls_tool_staging_args)"

    if ! command -v "${NOP_TLS_NATIVE_CERTBOT_EXECUTABLE}" >/dev/null 2>&1; then
        console_view_error "${ERR_TLS_CERTBOT}: ${NOP_TLS_NATIVE_CERTBOT_EXECUTABLE}"
        return 69
    fi

    console_view_info "${MSG_TLS_ISSUE}"

    if [[ -n "${staging_arg}" ]]; then
        "${NOP_TLS_NATIVE_CERTBOT_EXECUTABLE}" certonly             --webroot             --webroot-path "${NOP_TLS_WEBROOT_RESOLVED}"             --domains "${NOP_TLS_DOMAIN}"             --cert-name "${NOP_TLS_DOMAIN}"             --email "${NOP_TLS_EMAIL}"             --agree-tos             --non-interactive             --keep-until-expiring             "${staging_arg}"
    else
        "${NOP_TLS_NATIVE_CERTBOT_EXECUTABLE}" certonly             --webroot             --webroot-path "${NOP_TLS_WEBROOT_RESOLVED}"             --domains "${NOP_TLS_DOMAIN}"             --cert-name "${NOP_TLS_DOMAIN}"             --email "${NOP_TLS_EMAIL}"             --agree-tos             --non-interactive             --keep-until-expiring
    fi
}

tls_tool_issue_docker() {
    local staging_arg
    local args

    staging_arg="$(tls_tool_staging_args)"
    args=(
        certonly
        --webroot
        --webroot-path "${NOP_TLS_DOCKER_CERTBOT_WEBROOT}"
        --domains "${NOP_TLS_DOMAIN}"
        --cert-name "${NOP_TLS_DOMAIN}"
        --email "${NOP_TLS_EMAIL}"
        --agree-tos
        --non-interactive
        --keep-until-expiring
    )

    if [[ -n "${staging_arg}" ]]; then
        args+=("${staging_arg}")
    fi

    console_view_info "${MSG_TLS_ISSUE}"
    console_view_value "${MSG_TLS_CERTBOT_IMAGE}" "${NOP_TLS_CERTBOT_IMAGE}"

    "${NOP_DOCKER_EXECUTABLE}" pull "${NOP_TLS_CERTBOT_IMAGE}" >/dev/null

    "${NOP_DOCKER_EXECUTABLE}" run --rm         --volume "${NOP_TLS_CERT_ROOT_RESOLVED}:${NOP_TLS_DOCKER_CERTBOT_CERT_ROOT}"         --volume "${NOP_TLS_WEBROOT_RESOLVED}:${NOP_TLS_DOCKER_CERTBOT_WEBROOT}"         "${NOP_TLS_CERTBOT_IMAGE}"         "${args[@]}"
}

tls_tool_issue_certificate() {
    if [[ "${NOP_TLS_MODE_RESOLVED}" != "letsencrypt" ]]; then
        return 0
    fi

    tls_tool_prepare_directories

    if tls_tool_certificate_exists; then
        console_view_info "${MSG_TLS_CERT_EXISTS}"
        return 0
    fi

    case "${NOP_APP_MODE_RESOLVED}" in
        native)
            tls_tool_issue_native
            ;;
        docker)
            tls_tool_issue_docker
            ;;
        *)
            console_view_error "${ERR_APP_MODE}: ${NOP_APP_MODE_RESOLVED}"
            return 64
            ;;
    esac

    if ! tls_tool_certificate_exists; then
        console_view_error "${ERR_TLS_CERTIFICATE}: ${NOP_TLS_DOMAIN}"
        return 70
    fi

    console_view_info "${MSG_TLS_CERT_READY}"
}

tls_tool_write_deploy_hook() {
    local hook_path="${NOP_TLS_DEPLOY_HOOK}"

    mkdir -p "$(dirname "${hook_path}")"

    case "${NOP_APP_MODE_RESOLVED}" in
        native)
            cat > "${hook_path}" <<'EOF'
#!/usr/bin/env bash
# 📄 Dosya Yolu: /usr/local/sbin/nopcommerce-tls-deploy-hook
# 📌 Amac: Yenilenen Let's Encrypt sertifikasi sonrasi native Nginx'i guvenli yeniden yuklemek
# 📌 Modul - Shell
# Version: 1.0.0
# Aciklama: nginx config testinden sonra systemd reload uygular
# Bagimli Oldugu Katman: Tool

set -Eeuo pipefail

nginx -t
systemctl reload nginx.service
EOF
            ;;
        docker)
            cat > "${hook_path}" <<EOF
#!/usr/bin/env bash
# 📄 Dosya Yolu: ${hook_path}
# 📌 Amac: Yenilenen Let's Encrypt sertifikasi sonrasi Docker Nginx'i guvenli yeniden yuklemek
# 📌 Modul - Shell
# Version: 1.0.0
# Aciklama: Compose Nginx config testinden sonra container reload uygular
# Bagimli Oldugu Katman: Tool

set -Eeuo pipefail

if [[ -f "${NOP_DB_SECRET_FILE}" ]]; then
    set -a
    source "${NOP_DB_SECRET_FILE}"
    set +a
fi

"${NOP_DOCKER_EXECUTABLE}" compose \
    -p "${NOP_DOCKER_STACK_PROJECT}" \
    -f "${NOP_DOCKER_STACK_COMPOSE_FILE}" \
    exec -T "${NOP_DOCKER_STACK_NGINX_SERVICE}" nginx -t

"${NOP_DOCKER_EXECUTABLE}" compose \
    -p "${NOP_DOCKER_STACK_PROJECT}" \
    -f "${NOP_DOCKER_STACK_COMPOSE_FILE}" \
    exec -T "${NOP_DOCKER_STACK_NGINX_SERVICE}" nginx -s reload
EOF
            ;;
        *)
            console_view_error "${ERR_APP_MODE}: ${NOP_APP_MODE_RESOLVED}"
            return 64
            ;;
    esac

    chmod 755 "${hook_path}"
}

tls_tool_write_renew_script() {
    local script_path="${NOP_TLS_RENEW_SCRIPT}"

    mkdir -p "$(dirname "${script_path}")"

    case "${NOP_APP_MODE_RESOLVED}" in
        native)
            cat > "${script_path}" <<EOF
#!/usr/bin/env bash
# 📄 Dosya Yolu: ${script_path}
# 📌 Amac: Native Let's Encrypt sertifikalarini yenilemek
# 📌 Modul - Shell
# Version: 1.0.0
# Aciklama: Certbot renew ve yalniz basarili renewal sonrasi Nginx deploy hook calistirir
# Bagimli Oldugu Katman: Tool

set -Eeuo pipefail

"${NOP_TLS_NATIVE_CERTBOT_EXECUTABLE}" renew \
    --quiet \
    --deploy-hook "${NOP_TLS_DEPLOY_HOOK}"
EOF
            ;;
        docker)
            cat > "${script_path}" <<EOF
#!/usr/bin/env bash
# 📄 Dosya Yolu: ${script_path}
# 📌 Amac: Docker Let's Encrypt sertifikalarini Certbot container ile yenilemek
# 📌 Modul - Shell
# Version: 1.0.0
# Aciklama: Renewal olursa marker uretir ve host deploy hook ile Nginx container reload yapar
# Bagimli Oldugu Katman: Tool

set -Eeuo pipefail

MARKER="${NOP_TLS_WEBROOT_RESOLVED}/.nopcommerce-renewed"
rm -f "\${MARKER}"

"${NOP_DOCKER_EXECUTABLE}" run --rm \
    --volume "${NOP_TLS_CERT_ROOT_RESOLVED}:${NOP_TLS_DOCKER_CERTBOT_CERT_ROOT}" \
    --volume "${NOP_TLS_WEBROOT_RESOLVED}:${NOP_TLS_DOCKER_CERTBOT_WEBROOT}" \
    "${NOP_TLS_CERTBOT_IMAGE}" \
    renew \
    --quiet \
    --deploy-hook 'touch ${NOP_TLS_DOCKER_CERTBOT_WEBROOT}/.nopcommerce-renewed'

if [[ -f "\${MARKER}" ]]; then
    rm -f "\${MARKER}"
    "${NOP_TLS_DEPLOY_HOOK}"
fi
EOF
            ;;
        *)
            console_view_error "${ERR_APP_MODE}: ${NOP_APP_MODE_RESOLVED}"
            return 64
            ;;
    esac

    chmod 755 "${script_path}"
}

tls_tool_disable_renewal_timer() {
    local timer_unit

    if [[ "${NOP_TLS_MODE_RESOLVED}" != "off" ]]; then
        return 0
    fi

    timer_unit="$(basename "${NOP_TLS_RENEW_TIMER}")"

    systemctl disable --now "${timer_unit}" >/dev/null 2>&1 || true

    rm -f \
        "${NOP_TLS_RENEW_SERVICE}" \
        "${NOP_TLS_RENEW_TIMER}" \
        "${NOP_TLS_RENEW_SCRIPT}" \
        "${NOP_TLS_DEPLOY_HOOK}"

    systemctl daemon-reload
}

tls_tool_install_renewal_timer() {
    local service_template
    local timer_template
    local renew_script
    local on_calendar
    local random_delay

    if [[ "${NOP_TLS_MODE_RESOLVED}" != "letsencrypt" ]]; then
        return 0
    fi

    service_template="${INSTALLER_ROOT}/config/tls-renew.service.tpl"
    timer_template="${INSTALLER_ROOT}/config/tls-renew.timer.tpl"
    renew_script="$(printf '%s' "${NOP_TLS_RENEW_SCRIPT}" | sed 's/[&|]/\\&/g')"
    on_calendar="$(printf '%s' "${NOP_TLS_RENEW_ON_CALENDAR}" | sed 's/[&|]/\\&/g')"
    random_delay="$(printf '%s' "${NOP_TLS_RENEW_RANDOM_DELAY_SEC}" | sed 's/[&|]/\\&/g')"

    tls_tool_write_deploy_hook
    tls_tool_write_renew_script

    sed         -e "s|__RENEW_SCRIPT__|${renew_script}|g"         "${service_template}" > "${NOP_TLS_RENEW_SERVICE}"

    sed         -e "s|__ON_CALENDAR__|${on_calendar}|g"         -e "s|__RANDOM_DELAY__|${random_delay}|g"         "${timer_template}" > "${NOP_TLS_RENEW_TIMER}"

    systemctl daemon-reload
    systemctl enable --now "$(basename "${NOP_TLS_RENEW_TIMER}")"

    console_view_info "${MSG_TLS_RENEWAL_ENABLED}"
}
