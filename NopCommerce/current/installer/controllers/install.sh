# 📄 Dosya Yolu: /NopCommerce/current/installer/controllers/install.sh
# 📌 Amac: CLI girdisini alarak nopCommerce kurulum servisini cagirmak
# 📌 Modul - Shell
# Version: 1.0.1
# Aciklama: Controller katmani; is kurali barindirmaz
# Bagimli Oldugu Katman: Service

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${INSTALLER_ROOT}/services/install_service.sh"

install_service_run "${INSTALLER_ROOT}" "$@"
