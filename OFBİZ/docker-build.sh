# 📄 Dosya Yolu: /OFBİZ/docker-build.sh
# 📌 Amac: Resmi Apache OFBiz paketini dogrulayip resmi Dockerfile ile local image olusturur
# 📌 Tool - Shell
# Version: 1.0.0
# Aciklama: OFBiz 24.09.x kaynak paketini SHA-512 ile dogrular ve demo/runtime image build eder
#
# Bagimli Oldugu Katman: Tool

set -euo pipefail

readonly DEFAULT_OFBIZ_VERSION="24.09.07"
readonly DEFAULT_DOCKER_TARGET="demo"

OFBIZ_VERSION="${OFBIZ_VERSION:-${DEFAULT_OFBIZ_VERSION}}"
OFBIZ_IMAGE="${OFBIZ_IMAGE:-local/ofbiz:${OFBIZ_VERSION}}"
OFBIZ_DOCKER_TARGET="${OFBIZ_DOCKER_TARGET:-${DEFAULT_DOCKER_TARGET}}"

readonly ARCHIVE_NAME="apache-ofbiz-${OFBIZ_VERSION}.zip"
readonly DOWNLOAD_BASE_URL="https://dlcdn.apache.org/ofbiz"

log() {
    printf '[ofbiz-docker-build] %s\n' "$*"
}

fail() {
    printf '[ofbiz-docker-build] ERROR: %s\n' "$*" >&2
    exit 1
}

check_dependencies() {
    command -v docker >/dev/null 2>&1 || fail "docker command was not found"
    command -v curl >/dev/null 2>&1 || fail "curl command was not found"
    command -v unzip >/dev/null 2>&1 || fail "unzip command was not found"
    command -v sha512sum >/dev/null 2>&1 || fail "sha512sum command was not found"
}

main() {
    local work_dir
    local source_dir

    check_dependencies

    work_dir="$(mktemp -d)"
    trap 'rm -rf "${work_dir}"' EXIT

    log "Downloading OFBiz ${OFBIZ_VERSION}"
    curl --fail --location --retry 3 --output "${work_dir}/${ARCHIVE_NAME}"         "${DOWNLOAD_BASE_URL}/${ARCHIVE_NAME}"
    curl --fail --location --retry 3 --output "${work_dir}/${ARCHIVE_NAME}.sha512"         "${DOWNLOAD_BASE_URL}/${ARCHIVE_NAME}.sha512"

    (
        cd "${work_dir}"
        sha512sum --check "${ARCHIVE_NAME}.sha512"
    )

    unzip -q "${work_dir}/${ARCHIVE_NAME}" -d "${work_dir}"
    source_dir="${work_dir}/apache-ofbiz-${OFBIZ_VERSION}"

    [[ -f "${source_dir}/Dockerfile" ]] || fail "Official Dockerfile was not found in the release package"

    log "Building image ${OFBIZ_IMAGE} with target ${OFBIZ_DOCKER_TARGET}"
    docker build         --target "${OFBIZ_DOCKER_TARGET}"         --tag "${OFBIZ_IMAGE}"         "${source_dir}"

    log "Build completed: ${OFBIZ_IMAGE}"
}

main "$@"
