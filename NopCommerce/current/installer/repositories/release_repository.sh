# 📄 Dosya Yolu: /NopCommerce/current/installer/repositories/release_repository.sh
# 📌 Amac: nopCommerce release paketini indirmek, dogrulamak ve disk uzerine deploy etmek
# 📌 Modul - Shell
# Version: 1.0.1
# Aciklama: Release storage ve current symlink yonetimi
# Bagimli Oldugu Katman: Config | Language

set -Eeuo pipefail

release_repository_archive_path() {
    printf '%s/%s' "${NOP_TEMP_DIR}" "${NOP_PACKAGE_NAME}"
}

release_repository_release_dir() {
    printf '%s/%s' "${NOP_RELEASES_DIR}" "${NOP_VERSION}"
}

release_repository_release_url() {
    printf '%s/%s/%s' "${NOP_RELEASE_BASE_URL}" "${NOP_RELEASE_TAG}" "${NOP_PACKAGE_NAME}"
}

release_repository_prepare() {
    mkdir -p         "${NOP_INSTALL_ROOT}"         "${NOP_RELEASES_DIR}"         "${NOP_BACKUP_DIR}"         "${NOP_TEMP_DIR}"

    chown -R "${NOP_SERVICE_USER}:${NOP_SERVICE_GROUP}" "${NOP_INSTALL_ROOT}"
}

release_repository_download() {
    local archive_path
    local release_url

    archive_path="$(release_repository_archive_path)"
    release_url="$(release_repository_release_url)"

    printf '%s\n' "${MSG_DOWNLOAD}"
    curl --fail --location --retry 3 --output "${archive_path}" "${release_url}"

    printf '%s  %s\n' "${NOP_PACKAGE_SHA256}" "${archive_path}" | sha256sum --check --status || {
        printf '%s\n' "${ERR_CHECKSUM}" >&2
        rm -f "${archive_path}"
        return 74
    }
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

        printf '%s\n' "${MSG_DEPLOY}"
        unzip -q "${archive_path}" -d "${staging_dir}"

        if [[ ! -f "${staging_dir}/Nop.Web.dll" ]]; then
            printf '%s\n' "${ERR_PACKAGE_CONTENT}" >&2
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
