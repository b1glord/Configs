# 📄 Dosya Yolu: /OFBİZ/ofbiz_linux.sh
# 📌 Amac: Apache OFBiz 24.09.x surumunu JDK 17 ile Linux sistemine kurar
# 📌 Tool - Shell
# Version: 2.0.1
# Aciklama: Guncel OFBiz kurulumu, SHA-512 dogrulamasi ve opsiyonel demo veri yukleme akisi
#
# Bagimli Oldugu Katman: Tool

set -euo pipefail

readonly DEFAULT_OFBIZ_VERSION="24.09.07"
readonly DEFAULT_INSTALL_ROOT="/opt/ofbiz"

OFBIZ_VERSION="${OFBIZ_VERSION:-${DEFAULT_OFBIZ_VERSION}}"
OFBIZ_INSTALL_ROOT="${OFBIZ_INSTALL_ROOT:-${DEFAULT_INSTALL_ROOT}}"
OFBIZ_LOAD_DEMO="${OFBIZ_LOAD_DEMO:-0}"
OFBIZ_FORCE_REINSTALL="${OFBIZ_FORCE_REINSTALL:-0}"
WORK_DIR=""

readonly ARCHIVE_NAME="apache-ofbiz-${OFBIZ_VERSION}.zip"
readonly DOWNLOAD_BASE_URL="https://dlcdn.apache.org/ofbiz"
readonly RELEASES_DIR="${OFBIZ_INSTALL_ROOT}/releases"
readonly RELEASE_DIR="${RELEASES_DIR}/apache-ofbiz-${OFBIZ_VERSION}"
readonly CURRENT_LINK="${OFBIZ_INSTALL_ROOT}/current"

log() {
    printf '[ofbiz-install] %s\n' "$*"
}

fail() {
    printf '[ofbiz-install] ERROR: %s\n' "$*" >&2
    exit 1
}

cleanup() {
    if [[ -n "${WORK_DIR}" && -d "${WORK_DIR}" ]]; then
        rm -rf "${WORK_DIR}"
    fi
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        fail "Run this script as root: sudo bash ofbiz_linux.sh"
    fi
}

install_packages() {
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get install -y curl unzip ca-certificates openjdk-17-jdk
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y curl unzip ca-certificates java-17-openjdk-devel
    elif command -v yum >/dev/null 2>&1; then
        yum install -y curl unzip ca-certificates java-17-openjdk-devel
    elif command -v zypper >/dev/null 2>&1; then
        zypper --non-interactive install curl unzip ca-certificates java-17-openjdk-devel
    else
        fail "Supported package manager not found. Install JDK 17, curl, unzip and ca-certificates manually."
    fi
}

configure_java17() {
    local javac_path
    local java_major

    if command -v javac >/dev/null 2>&1; then
        java_major="$(javac -version 2>&1 | awk '{print $2}' | cut -d. -f1)"
        if [[ "${java_major}" == "17" ]]; then
            export JAVA_HOME
            JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")"
            return
        fi
    fi

    while IFS= read -r javac_path; do
        java_major="$("${javac_path}" -version 2>&1 | awk '{print $2}' | cut -d. -f1)"
        if [[ "${java_major}" == "17" ]]; then
            export JAVA_HOME
            JAVA_HOME="$(dirname "$(dirname "${javac_path}")")"
            export PATH="${JAVA_HOME}/bin:${PATH}"
            return
        fi
    done < <(find /usr/lib/jvm -maxdepth 4 -type f -path '*/bin/javac' 2>/dev/null | sort)

    fail "OFBiz 24.09 requires JDK 17, but a JDK 17 installation could not be selected."
}

download_and_extract() {
    WORK_DIR="$(mktemp -d)"

    if [[ -d "${RELEASE_DIR}" && "${OFBIZ_FORCE_REINSTALL}" != "1" ]]; then
        log "Release already exists: ${RELEASE_DIR}"
        return
    fi

    rm -rf "${RELEASE_DIR}"
    mkdir -p "${RELEASES_DIR}"

    log "Downloading OFBiz ${OFBIZ_VERSION}"
    curl --fail --location --retry 3 --output "${WORK_DIR}/${ARCHIVE_NAME}" "${DOWNLOAD_BASE_URL}/${ARCHIVE_NAME}"
    curl --fail --location --retry 3 --output "${WORK_DIR}/${ARCHIVE_NAME}.sha512" "${DOWNLOAD_BASE_URL}/${ARCHIVE_NAME}.sha512"

    (
        cd "${WORK_DIR}"
        sha512sum --check "${ARCHIVE_NAME}.sha512"
    )

    unzip -q "${WORK_DIR}/${ARCHIVE_NAME}" -d "${RELEASES_DIR}"
    [[ -d "${RELEASE_DIR}" ]] || fail "Expected release directory was not created: ${RELEASE_DIR}"
}

prepare_ofbiz() {
    ln -sfn "${RELEASE_DIR}" "${CURRENT_LINK}"
    cd "${CURRENT_LINK}"

    if [[ -f "gradle/init-gradle-wrapper.sh" ]]; then
        bash gradle/init-gradle-wrapper.sh
    fi

    if [[ "${OFBIZ_LOAD_DEMO}" == "1" ]]; then
        log "Loading demo data"
        ./gradlew --no-daemon loadAll
    fi
}

print_summary() {
    cat <<EOF
OFBiz installation completed.

Version   : ${OFBIZ_VERSION}
Path      : ${CURRENT_LINK}
JAVA_HOME : ${JAVA_HOME}
Java      : $(javac -version 2>&1)

Start:
  cd ${CURRENT_LINK}
  ./gradlew ofbiz

Default HTTPS:
  https://localhost:8443/

Demo data was loaded only when OFBIZ_LOAD_DEMO=1.
EOF
}

main() {
    trap cleanup EXIT
    require_root
    install_packages
    configure_java17
    download_and_extract
    prepare_ofbiz
    print_summary
}

main "$@"
