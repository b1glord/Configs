# 📄 Dosya Yolu: /OFBİZ/docker-build.sh
# 📌 Amac: Resmi Apache OFBiz paketini dogrulayip resmi Dockerfile ile local image olusturur
# 📌 Tool - Shell
# Version: 1.0.1
# Aciklama: OFBiz 24.09.x kaynak paketini SHA-512 ile dogrular ve demo/runtime image build eder
#
# Bagimli Oldugu Katman: Tool

set -euo pipefail

readonly DEFAULT_OFBIZ_VERSION="24.09.07"
readonly DEFAULT_DOCKER_TARGET="demo"

OFBIZ_VERSION="${OFBIZ_VERSION:-${DEFAULT_OFBIZ_VERSION}}"
OFBIZ_IMAGE="${OFBIZ_IMAGE:-local/ofbiz:${OFBIZ_VERSION}}"
OFBIZ_DOCKER_TARGET="${OFBIZ_DOCKER_TARGET:-${DEFAULT_DOCKER_TARGET}}"
WORK_DIR=""

readonly ARCHIVE_NAME="apache-ofbiz-${OFBIZ_VERSION}.zip"
readonly DOWNLOAD_BASE_URL="https://dlcdn.apache.org/ofbiz"

log() {
    printf '[ofbiz-docker-build] %s\n' "$*"
}

fail() {
    printf '[ofbiz-docker-build] ERROR: %s\n' "$*" >&2
    exit 1
}

cleanup() {
    if [[ -n "${WORK_DIR}" && -d "${WORK_DIR}" ]]; then
        rm -rf "${WORK_DIR}"
    fi
}

check_dependencies() {
    command -v docker >/dev/null 2>&1 || fail "docker command was not found"
    command -v curl >/dev/null 2>&1 || fail "curl command was not found"
    command -v unzip >/dev/null 2>&1 || fail "unzip command was not found"
    command -v sha512sum >/dev/null 2>&1 || fail "sha512sum command was not found"

    case "${OFBIZ_DOCKER_TARGET}" in
        demo|runtime)
            ;;
        *)
            fail "OFBIZ_DOCKER_TARGET must be demo or runtime"
            ;;
    esac
}

main() {
    local source_dir

    trap cleanup EXIT
    check_dependencies

    WORK_DIR="$(mktemp -d)"

    log "Downloading OFBiz ${OFBIZ_VERSION}"
    curl --fail --location --retry 3 --output "${WORK_DIR}/${ARCHIVE_NAME}" "${DOWNLOAD_BASE_URL}/${ARCHIVE_NAME}"
    curl --fail --location --retry 3 --output "${WORK_DIR}/${ARCHIVE_NAME}.sha512" "${DOWNLOAD_BASE_URL}/${ARCHIVE_NAME}.sha512"

    (
        cd "${WORK_DIR}"
        sha512sum --check "${ARCHIVE_NAME}.sha512"
    )

    unzip -q "${WORK_DIR}/${ARCHIVE_NAME}" -d "${WORK_DIR}"
    source_dir="${WORK_DIR}/apache-ofbiz-${OFBIZ_VERSION}"

    [[ -f "${source_dir}/Dockerfile" ]] || fail "Official Dockerfile was not found in the release package"

    log "Building image ${OFBIZ_IMAGE} with target ${OFBIZ_DOCKER_TARGET}"
    docker build --target "${OFBIZ_DOCKER_TARGET}" --tag "${OFBIZ_IMAGE}" "${source_dir}"

    log "Build completed: ${OFBIZ_IMAGE}"
}

main "$@"
