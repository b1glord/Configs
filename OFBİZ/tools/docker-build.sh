# Dosya Yolu: /OFBIZ/tools/docker-build.sh
# Amac: Secilen Apache OFBiz release surumu icin Docker image olusturur
# Tool - Shell
# Version: 2.1.0
# Aciklama: Release katalogundan surum ve Java secerek resmi veya uyumluluk Dockerfile'i ile image build eder
#
# Bagimli Oldugu Katman: Tool | Service | Config

set -euo pipefail

readonly TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly OFBIZ_ROOT_DIR="$(cd "${TOOL_DIR}/.." && pwd)"
readonly VERSION_RESOLVER="${OFBIZ_ROOT_DIR}/services/version-resolver.sh"
readonly COMPAT_DOCKERFILE="${OFBIZ_ROOT_DIR}/tools/docker/Dockerfile.compat"

# shellcheck source=/dev/null
source "${VERSION_RESOLVER}"

OFBIZ_DOCKER_LOAD_DEMO="${OFBIZ_DOCKER_LOAD_DEMO:-1}"
OFBIZ_DOCKER_TARGET="${OFBIZ_DOCKER_TARGET:-demo}"

WORK_DIR=""

log() {
    printf '[ofbiz-docker-build] %s\n' "$*" >&2
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

usage() {
    cat <<EOF
Usage:
  bash tools/docker-build.sh list
  bash tools/docker-build.sh [latest|24.09|18.12|17.12|exact-version]

Examples:
  bash tools/docker-build.sh latest
  bash tools/docker-build.sh 24.09.07
  bash tools/docker-build.sh 18.12.19
  bash tools/docker-build.sh 18.12.10
  bash tools/docker-build.sh 17.12.09

Environment:
  OFBIZ_IMAGE=local/ofbiz:<version>
  OFBIZ_DOCKER_LOAD_DEMO=1
  OFBIZ_DOCKER_TARGET=demo
EOF
}

check_dependencies() {
    command -v docker >/dev/null 2>&1 || fail "docker command was not found"
    command -v curl >/dev/null 2>&1 || fail "curl command was not found"
    command -v unzip >/dev/null 2>&1 || fail "unzip command was not found"
    command -v sha512sum >/dev/null 2>&1 || fail "sha512sum command was not found"
    [[ -f "${COMPAT_DOCKERFILE}" ]] || fail "Compatibility Dockerfile not found: ${COMPAT_DOCKERFILE}"
}

download_release() {
    local version="${1:?version required}"
    local archive_name="apache-ofbiz-${version}.zip"
    local archive_file="${WORK_DIR}/${archive_name}"
    local checksum_file="${archive_file}.sha512"
    local base_url
    local found="0"

    for base_url in "${OFBIZ_CURRENT_BASE_URL}" "${OFBIZ_ARCHIVE_BASE_URL}"; do
        log "Trying release source: ${base_url}"

        if curl --fail --location --retry 2 --output "${archive_file}" "${base_url}/${archive_name}"; then
            if curl --fail --location --retry 2 --output "${checksum_file}" "${base_url}/${archive_name}.sha512"; then
                found="1"
                break
            fi
        fi
    done

    [[ "${found}" == "1" ]] || fail "Release package could not be downloaded: ${version}"

    (
        cd "${WORK_DIR}"
        sha512sum --check "${archive_name}.sha512"
    ) || fail "OFBiz SHA-512 verification failed"
}

build_image() {
    local requested="${1:-latest}"
    local version
    local java_major
    local image_name
    local source_dir

    version="$(ofbiz_resolve_version "${requested}")"
    java_major="$(ofbiz_required_java "${version}")"
    image_name="${OFBIZ_IMAGE:-local/ofbiz:${version}}"

    WORK_DIR="$(mktemp -d)"
    download_release "${version}"

    unzip -q "${WORK_DIR}/apache-ofbiz-${version}.zip" -d "${WORK_DIR}"
    source_dir="${WORK_DIR}/apache-ofbiz-${version}"

    [[ -d "${source_dir}" ]] || fail "Extracted release directory not found: ${source_dir}"

    log "Building OFBiz ${version} with Java ${java_major}"
    log "Image: ${image_name}"

    if [[ -f "${source_dir}/Dockerfile" ]]; then
        log "Using release Dockerfile"

        if docker build             --target "${OFBIZ_DOCKER_TARGET}"             --tag "${image_name}"             "${source_dir}"; then
            log "Build completed: ${image_name}"
            return
        fi

        log "Release Dockerfile target failed; using compatibility Dockerfile"
    else
        log "Release Dockerfile not found; using compatibility Dockerfile"
    fi

    cp "${COMPAT_DOCKERFILE}" "${source_dir}/Dockerfile.compat"

    docker build         --file "${source_dir}/Dockerfile.compat"         --build-arg "JAVA_MAJOR=${java_major}"         --build-arg "OFBIZ_LOAD_DEMO=${OFBIZ_DOCKER_LOAD_DEMO}"         --tag "${image_name}"         "${source_dir}"

    log "Build completed: ${image_name}"
}

main() {
    local command="${1:-latest}"

    trap cleanup EXIT

    case "${command}" in
        list)
            ofbiz_list_versions
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            check_dependencies
            build_image "${command}"
            ;;
    esac
}

main "$@"
