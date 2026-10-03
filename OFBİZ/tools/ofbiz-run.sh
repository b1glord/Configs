# Dosya Yolu: /OFBIZ/tools/ofbiz-run.sh
# Amac: Aktif veya belirtilen OFBiz surumunu dogru JDK ile baslatir ve durdurur
# Tool - Shell
# Version: 1.1.0
# Aciklama: Kurulu release metadata bilgisinden uygun JDK secerek OFBiz calistirma araci
#
# Bagimli Oldugu Katman: Tool | Service | Config

set -euo pipefail

readonly TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly OFBIZ_ROOT_DIR="$(cd "${TOOL_DIR}/.." && pwd)"
readonly VERSION_RESOLVER="${OFBIZ_ROOT_DIR}/services/version-resolver.sh"

# shellcheck source=/dev/null
source "${VERSION_RESOLVER}"

OFBIZ_INSTALL_ROOT="${OFBIZ_INSTALL_ROOT:-/opt/ofbiz}"

readonly RELEASES_DIR="${OFBIZ_INSTALL_ROOT}/releases"
readonly JDKS_DIR="${OFBIZ_INSTALL_ROOT}/jdks"
readonly CURRENT_LINK="${OFBIZ_INSTALL_ROOT}/current"

fail() {
    printf '[ofbiz-run] ERROR: %s\n' "$*" >&2
    exit 1
}

resolve_active_version() {
    local requested="${1:-}"

    if [[ -n "${requested}" ]]; then
        ofbiz_resolve_version "${requested}"
        return
    fi

    [[ -L "${CURRENT_LINK}" ]] || fail "No active release. Use controllers/ofbiz.sh use <version> first."

    basename "$(readlink -f "${CURRENT_LINK}")" | sed 's/^apache-ofbiz-//'
}

main() {
    local action="${1:-start}"
    local requested="${2:-}"
    local version
    local java_major
    local java_home
    local release_dir

    version="$(resolve_active_version "${requested}")"
    java_major="$(ofbiz_required_java "${version}")"
    java_home="${JDKS_DIR}/temurin-${java_major}"
    release_dir="${RELEASES_DIR}/apache-ofbiz-${version}"

    [[ -x "${java_home}/bin/java" ]] || fail "Required JDK is not installed: ${java_home}"
    [[ -d "${release_dir}" ]] || fail "OFBiz release is not installed: ${version}"

    export JAVA_HOME="${java_home}"
    export PATH="${JAVA_HOME}/bin:${PATH}"

    cd "${release_dir}"

    case "${action}" in
        start)
            printf '[ofbiz-run] Starting OFBiz %s with Java %s\n' "${version}" "${java_major}"
            ./gradlew ofbiz
            ;;
        background)
            printf '[ofbiz-run] Starting OFBiz %s in background with Java %s\n' "${version}" "${java_major}"
            ./gradlew "ofbizBackground --start"
            ;;
        stop)
            printf '[ofbiz-run] Stopping OFBiz %s\n' "${version}"
            ./gradlew "ofbiz --shutdown"
            ;;
        java)
            "${JAVA_HOME}/bin/java" -version
            ;;
        *)
            fail "Unknown action. Use: start, background, stop or java"
            ;;
    esac
}

main "$@"
