# 📄 Dosya Yolu: /OFBİZ/ofbiz_linux.sh
# 📌 Amac: Secilen Apache OFBiz release surumunu uygun JDK ile yan yana kurar ve aktif surumu yonetir
# 📌 Controller - Shell
# Version: 3.0.1
# Aciklama: OFBiz release listeleme, kurma, aktif surum secme ve kurulu surum goruntuleme komutlari
#
# Bagimli Oldugu Katman: Controller | Service | Config | Tool

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION_RESOLVER="${SCRIPT_DIR}/tools/version-resolver.sh"

[[ -f "${VERSION_RESOLVER}" ]] || {
    printf 'ERROR: Version resolver not found: %s\n' "${VERSION_RESOLVER}" >&2
    exit 1
}

# shellcheck source=/dev/null
source "${VERSION_RESOLVER}"

OFBIZ_INSTALL_ROOT="${OFBIZ_INSTALL_ROOT:-/opt/ofbiz}"
OFBIZ_LOAD_DEMO="${OFBIZ_LOAD_DEMO:-0}"
OFBIZ_FORCE_REINSTALL="${OFBIZ_FORCE_REINSTALL:-0}"

readonly RELEASES_DIR="${OFBIZ_INSTALL_ROOT}/releases"
readonly JDKS_DIR="${OFBIZ_INSTALL_ROOT}/jdks"
readonly CURRENT_LINK="${OFBIZ_INSTALL_ROOT}/current"

WORK_DIR=""

log() {
    printf '[ofbiz] %s\n' "$*"
}

fail() {
    printf '[ofbiz] ERROR: %s\n' "$*" >&2
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
  bash ofbiz_linux.sh list
  bash ofbiz_linux.sh installed
  bash ofbiz_linux.sh current
  sudo bash ofbiz_linux.sh install [latest|24.09|18.12|17.12|exact-version]
  sudo bash ofbiz_linux.sh use <exact-version>

Examples:
  sudo bash ofbiz_linux.sh install latest
  sudo bash ofbiz_linux.sh install 24.09.07
  sudo bash ofbiz_linux.sh install 18.12
  sudo bash ofbiz_linux.sh install 18.12.10
  sudo bash ofbiz_linux.sh install 17.12.09
  sudo bash ofbiz_linux.sh use 18.12.19

Optional environment variables:
  OFBIZ_INSTALL_ROOT=/opt/ofbiz
  OFBIZ_LOAD_DEMO=1
  OFBIZ_FORCE_REINSTALL=1
EOF
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        fail "This command requires root. Run it with sudo."
    fi
}

install_base_packages() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install -y curl unzip tar ca-certificates
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y curl unzip tar ca-certificates
    elif command -v yum >/dev/null 2>&1; then
        yum install -y curl unzip tar ca-certificates
    elif command -v zypper >/dev/null 2>&1; then
        zypper --non-interactive install curl unzip tar ca-certificates
    else
        fail "Supported package manager not found. Install curl, unzip, tar and ca-certificates manually."
    fi

    command -v sha256sum >/dev/null 2>&1 || fail "sha256sum command was not found"
    command -v sha512sum >/dev/null 2>&1 || fail "sha512sum command was not found"
}

detect_adoptium_arch() {
    case "$(uname -m)" in
        x86_64|amd64)
            printf 'x64\n'
            ;;
        aarch64|arm64)
            printf 'aarch64\n'
            ;;
        armv7l|armv7)
            printf 'arm\n'
            ;;
        ppc64le)
            printf 'ppc64le\n'
            ;;
        s390x)
            printf 's390x\n'
            ;;
        *)
            fail "Unsupported CPU architecture for automatic JDK install: $(uname -m)"
            ;;
    esac
}

install_temurin_jdk() {
    local java_major="${1:?java major required}"
    local java_home="${JDKS_DIR}/temurin-${java_major}"
    local arch
    local api_url
    local fetch_url
    local archive_file
    local checksum_file
    local expected_checksum

    if [[ -x "${java_home}/bin/javac" ]]; then
        log "JDK ${java_major} already installed: ${java_home}"
        printf '%s\n' "${java_home}"
        return
    fi

    arch="$(detect_adoptium_arch)"
    api_url="${ADOPTIUM_API_BASE_URL}/${java_major}/ga/linux/${arch}/jdk/hotspot/normal/eclipse"

    mkdir -p "${JDKS_DIR}"
    WORK_DIR="$(mktemp -d)"

    log "Resolving Eclipse Temurin JDK ${java_major} for ${arch}"
    fetch_url="$(curl --fail --silent --show-error --output /dev/null --write-out '%{redirect_url}' "${api_url}")"
    [[ -n "${fetch_url}" ]] || fail "Adoptium API did not return a JDK download URL"

    archive_file="${WORK_DIR}/temurin-${java_major}.tar.gz"
    checksum_file="${WORK_DIR}/temurin-${java_major}.sha256"

    log "Downloading Eclipse Temurin JDK ${java_major}"
    curl --fail --location --retry 3 --output "${archive_file}" "${fetch_url}"
    curl --fail --location --retry 3 --output "${checksum_file}" "${fetch_url}.sha256.txt"

    expected_checksum="$(awk 'NR == 1 {print $1}' "${checksum_file}")"
    [[ -n "${expected_checksum}" ]] || fail "Temurin checksum file is empty"

    printf '%s  %s\n' "${expected_checksum}" "${archive_file}" | sha256sum --check --status         || fail "Temurin JDK checksum verification failed"

    rm -rf "${java_home}"
    mkdir -p "${java_home}"
    tar -xzf "${archive_file}" -C "${java_home}" --strip-components=1

    [[ -x "${java_home}/bin/javac" ]] || fail "JDK installation is incomplete: ${java_home}"

    rm -rf "${WORK_DIR}"
    WORK_DIR=""

    printf '%s\n' "${java_home}"
}

download_ofbiz_release() {
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

prepare_release() {
    local version="${1:?version required}"
    local java_home="${2:?java home required}"
    local release_dir="${RELEASES_DIR}/apache-ofbiz-${version}"

    if [[ -d "${release_dir}" && "${OFBIZ_FORCE_REINSTALL}" != "1" ]]; then
        log "Release already installed: ${version}"
        ln -sfn "${release_dir}" "${CURRENT_LINK}"
        return
    fi

    rm -rf "${release_dir}"
    mkdir -p "${RELEASES_DIR}"

    download_ofbiz_release "${version}"
    unzip -q "${WORK_DIR}/apache-ofbiz-${version}.zip" -d "${RELEASES_DIR}"

    [[ -d "${release_dir}" ]] || fail "Expected release directory was not created: ${release_dir}"

    export JAVA_HOME="${java_home}"
    export PATH="${JAVA_HOME}/bin:${PATH}"

    cd "${release_dir}"

    if [[ -f "gradle/init-gradle-wrapper.sh" ]]; then
        bash gradle/init-gradle-wrapper.sh
    fi

    if [[ "${OFBIZ_LOAD_DEMO}" == "1" ]]; then
        log "Loading demo data for ${version}"
        ./gradlew --no-daemon loadAll
    fi

    ln -sfn "${release_dir}" "${CURRENT_LINK}"
}

install_release() {
    local requested="${1:-latest}"
    local version
    local java_major
    local java_home

    require_root
    install_base_packages

    version="$(ofbiz_resolve_version "${requested}")"
    java_major="$(ofbiz_required_java "${version}")"

    log "Selected OFBiz: ${version}"
    log "Required Java: ${java_major}"

    java_home="$(install_temurin_jdk "${java_major}")"

    WORK_DIR="$(mktemp -d)"
    prepare_release "${version}" "${java_home}"

    log "Installed and activated OFBiz ${version}"
    log "JAVA_HOME: ${java_home}"
    log "Start with: bash ${SCRIPT_DIR}/ofbiz-run.sh start"
}

list_installed() {
    local item
    local found="0"

    if [[ ! -d "${RELEASES_DIR}" ]]; then
        printf 'No OFBiz releases are installed.\n'
        return
    fi

    for item in "${RELEASES_DIR}"/apache-ofbiz-*; do
        [[ -d "${item}" ]] || continue
        found="1"
        printf '%s\n' "$(basename "${item}" | sed 's/^apache-ofbiz-//')"
    done

    if [[ "${found}" == "0" ]]; then
        printf 'No OFBiz releases are installed.\n'
    fi
}

show_current() {
    if [[ -L "${CURRENT_LINK}" ]]; then
        basename "$(readlink -f "${CURRENT_LINK}")" | sed 's/^apache-ofbiz-//'
    else
        printf 'No active OFBiz release.\n'
    fi
}

use_release() {
    local requested="${1:-}"
    local version
    local release_dir

    require_root
    [[ -n "${requested}" ]] || fail "Version is required for use command"

    version="$(ofbiz_resolve_version "${requested}")"
    release_dir="${RELEASES_DIR}/apache-ofbiz-${version}"

    [[ -d "${release_dir}" ]] || fail "Release is not installed: ${version}"

    ln -sfn "${release_dir}" "${CURRENT_LINK}"
    log "Active OFBiz release: ${version}"
}

main() {
    local command="${1:-install}"

    trap cleanup EXIT

    case "${command}" in
        list)
            ofbiz_list_versions
            ;;
        installed)
            list_installed
            ;;
        current)
            show_current
            ;;
        install)
            install_release "${2:-latest}"
            ;;
        use)
            use_release "${2:-}"
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            if ofbiz_is_known_release "$(ofbiz_resolve_alias "${command}")"; then
                install_release "${command}"
            else
                usage
                fail "Unknown command or version: ${command}"
            fi
            ;;
    esac
}

main "$@"