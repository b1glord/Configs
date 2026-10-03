# Dosya Yolu: /OFBIZ/controllers/ofbiz.sh
# Amac: OFBiz komut satiri isteklerini alip ilgili Service katmanina yonlendirir
# Controller - Shell
# Version: 4.1.0
# Aciklama: Release, snapshot ve runtime komutlari icin ince routing controller'i
#
# Bagimli Oldugu Katman: Controller | Service | View

set -euo pipefail

readonly CONTROLLER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly OFBIZ_ROOT_DIR="$(cd "${CONTROLLER_DIR}/.." && pwd)"

# shellcheck source=/dev/null
source "${OFBIZ_ROOT_DIR}/services/release-service.sh"
# shellcheck source=/dev/null
source "${OFBIZ_ROOT_DIR}/services/snapshot-service.sh"
# shellcheck source=/dev/null
source "${OFBIZ_ROOT_DIR}/services/runtime-service.sh"
# shellcheck source=/dev/null
source "${OFBIZ_ROOT_DIR}/views/help-view.sh"

ofbiz_controller_release() {
    local action="${1:-list}"
    local target="${2:-latest}"

    case "${action}" in
        list)
            ofbiz_release_service_list
            ;;
        install)
            ofbiz_release_service_install "${target}"
            ;;
        installed)
            ofbiz_release_service_installed
            ;;
        use)
            ofbiz_release_service_use "${target}"
            ;;
        *)
            ofbiz_view_help
            return 1
            ;;
    esac
}

ofbiz_controller_snapshot() {
    local action="${1:-list}"
    local target="${2:-trunk}"

    case "${action}" in
        list)
            ofbiz_snapshot_service_list
            ;;
        install)
            ofbiz_snapshot_service_install "${target}"
            ;;
        update)
            ofbiz_snapshot_service_update "${target}"
            ;;
        installed)
            ofbiz_snapshot_service_installed
            ;;
        use)
            ofbiz_snapshot_service_use "${target}"
            ;;
        *)
            ofbiz_view_help
            return 1
            ;;
    esac
}

ofbiz_controller_main() {
    local domain="${1:-help}"

    case "${domain}" in
        release)
            ofbiz_controller_release "${2:-list}" "${3:-latest}"
            ;;
        snapshot)
            ofbiz_controller_snapshot "${2:-list}" "${3:-trunk}"
            ;;
        current)
            ofbiz_runtime_service_current
            ;;
        run)
            ofbiz_runtime_service_run "${2:-start}" "${3:-current}"
            ;;
        list)
            ofbiz_release_service_list
            ;;
        install)
            ofbiz_release_service_install "${2:-latest}"
            ;;
        installed)
            ofbiz_release_service_installed
            ;;
        use)
            ofbiz_release_service_use "${2:-latest}"
            ;;
        -h|--help|help)
            ofbiz_view_help
            ;;
        *)
            ofbiz_view_help
            return 1
            ;;
    esac
}

ofbiz_controller_main "$@"
