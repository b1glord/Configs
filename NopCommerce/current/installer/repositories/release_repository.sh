# 📄 Dosya Yolu: /NopCommerce/current/installer/repositories/release_repository.sh
# 📌 Amac: Secilen nopCommerce release paketini cozumlemek, indirmek, dogrulamak ve deploy etmek
# 📌 Modul - Shell
# Version: 1.1.0
# Aciklama: GitHub release metadata, paket butunlugu, release storage ve current symlink yonetimi
# Bagimli Oldugu Katman: Config | View | Language

set -Eeuo pipefail

release_repository_archive_path() {
    printf '%s/%s' "${NOP_TEMP_DIR}" "${NOP_PACKAGE_NAME}"
}

release_repository_release_dir() {
    printf '%s/%s' "${NOP_RELEASES_DIR}" "${NOP_VERSION}"
}

release_repository_resolve_metadata() {
    local metadata_url
    local release_json
    local asset_json
    local digest

    metadata_url="${NOP_RELEASE_API_BASE}/${NOP_RELEASE_TAG}"

    if ! release_json="$(curl --fail --silent --show-error --location --retry 3 "${metadata_url}")"; then
        console_view_error "${ERR_RELEASE_METADATA}: ${NOP_RELEASE_TAG}"
        return 69
    fi

    asset_json="$(jq -c --arg name "${NOP_PACKAGE_NAME}" '.assets[] | select(.name == $name)' <<< "${release_json}" | head -n 1)"

    if [[ -z "${asset_json}" ]]; then
        console_view_error "${ERR_RELEASE_ASSET}: ${NOP_PACKAGE_NAME}"
        return 69
    fi

    export NOP_PACKAGE_DOWNLOAD_URL
    export NOP_PACKAGE_SIZE
    export NOP_PACKAGE_SHA256

    NOP_PACKAGE_DOWNLOAD_URL="$(jq -r '.browser_download_url' <<< "${asset_json}")"
    NOP_PACKAGE_SIZE="$(jq -r '.size' <<< "${asset_json}")"
    digest="$(jq -r '.digest // empty' <<< "${asset_json}")"

    if [[ -n "${NOP_PACKAGE_SHA256_OVERRIDE:-}" ]]; then
        NOP_PACKAGE_SHA256="${NOP_PACKAGE_SHA256_OVERRIDE}"
    elif [[ "${digest}" == sha256:* ]]; then
        NOP_PACKAGE_SHA256="${digest#sha256:}"
    else
        NOP_PACKAGE_SHA256=""
    fi

    console_view_info "${MSG_RELEASE_VERIFIED}"
}

release_repository_prepare() {
    mkdir -p         "${NOP_INSTALL_ROOT}"         "${NOP_RELEASES_DIR}"         "${NOP_BACKUP_DIR}"         "${NOP_TEMP_DIR}"

    chown -R "${NOP_SERVICE_USER}:${NOP_SERVICE_GROUP}" "${NOP_INSTALL_ROOT}"
}

release_repository_verify_size() {
    local archive_path="$1"
    local actual_size

    actual_size="$(stat -c '%s' "${archive_path}")"

    if [[ "${actual_size}" != "${NOP_PACKAGE_SIZE}" ]]; then
        console_view_error "${ERR_PACKAGE_SIZE}"
        return 74
    fi

    console_view_info "${MSG_SIZE_VERIFIED}"
}

release_repository_download() {
    local archive_path

    archive_path="$(release_repository_archive_path)"

    console_view_info "${MSG_DOWNLOAD}"
    curl --fail --location --retry 3 --output "${archive_path}" "${NOP_PACKAGE_DOWNLOAD_URL}"

    release_repository_verify_size "${archive_path}" || {
        rm -f "${archive_path}"
        return 74
    }

    if [[ -n "${NOP_PACKAGE_SHA256}" ]]; then
        printf '%s  %s\n' "${NOP_PACKAGE_SHA256}" "${archive_path}" | sha256sum --check --status || {
            console_view_error "${ERR_CHECKSUM}"
            rm -f "${archive_path}"
            return 74
        }

        console_view_info "${MSG_SHA256_VERIFIED}"
        return 0
    fi

    if [[ "${NOP_ALLOW_LEGACY_WITHOUT_SHA256}" != "1" ]]; then
        console_view_error "${ERR_MISSING_DIGEST}"
        rm -f "${archive_path}"
        return 74
    fi

    console_view_warn "${MSG_NO_DIGEST}"
}

release_repository_prepare_writable_paths() {
    local release_dir="$1"
    local relative_path
    local paths

    IFS=':' read -r -a paths <<< "${NOP_WRITABLE_PATHS}"

    for relative_path in "${paths[@]}"; do
        mkdir -p "${release_dir}/${relative_path}"
        chown -R "${NOP_SERVICE_USER}:${NOP_SERVICE_GROUP}" "${release_dir}/${relative_path}"
        chmod -R u+rwX,g+rwX "${release_dir}/${relative_path}"
    done
}

release_repository_deploy() {
    local archive_path
    local release_dir
    local staging_dir
    local backup_target

    archive_path="$(release_repository_archive_path)"
    release_dir="$(release_repository_release_dir)"
    staging_dir="${NOP_TEMP_DIR}/staging-${NOP_VERSION}"

    if [[ ! -f "${release_dir}/Nop.Web.dll" ]]; then
        rm -rf "${staging_dir}"
        mkdir -p "${staging_dir}"

        console_view_info "${MSG_DEPLOY}"
        unzip -q "${archive_path}" -d "${staging_dir}"

        if [[ ! -f "${staging_dir}/Nop.Web.dll" ]]; then
            console_view_error "${ERR_PACKAGE_CONTENT}"
            return 65
        fi

        rm -rf "${release_dir}"
        mv "${staging_dir}" "${release_dir}"
    fi

    release_repository_prepare_writable_paths "${release_dir}"
    chown -R "${NOP_SERVICE_USER}:${NOP_SERVICE_GROUP}" "${release_dir}"

    if [[ -e "${NOP_CURRENT_DIR}" && ! -L "${NOP_CURRENT_DIR}" ]]; then
        backup_target="${NOP_BACKUP_DIR}/current-$(date +%Y%m%d%H%M%S)"
        mv "${NOP_CURRENT_DIR}" "${backup_target}"
    fi

    ln -sfn "${release_dir}" "${NOP_CURRENT_DIR}"
}
