# Dosya Yolu: /OFBIZ/views/help-view.sh
# Amac: OFBiz CLI yardim metnini kullaniciya sunar
# View - Shell
# Version: 1.0.0
# Aciklama: Language etiketlerini kullanarak release, snapshot ve runtime komutlarini gosterir
#
# Bagimli Oldugu Katman: View | Language

set -euo pipefail

readonly HELP_VIEW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HELP_ROOT_DIR="$(cd "${HELP_VIEW_DIR}/.." && pwd)"

# shellcheck source=/dev/null
source "${HELP_ROOT_DIR}/language/en.conf"

ofbiz_view_help() {
    cat <<EOF
${OFBIZ_LABEL_USAGE}:

${OFBIZ_LABEL_RELEASE}:
  bash controllers/ofbiz.sh release list
  sudo bash controllers/ofbiz.sh release install <version>
  bash controllers/ofbiz.sh release installed
  sudo bash controllers/ofbiz.sh release use <version>

${OFBIZ_LABEL_SNAPSHOT}:
  bash controllers/ofbiz.sh snapshot list
  sudo bash controllers/ofbiz.sh snapshot install <trunk|24.09|22.01>
  sudo bash controllers/ofbiz.sh snapshot update <trunk|24.09|22.01>
  bash controllers/ofbiz.sh snapshot installed
  sudo bash controllers/ofbiz.sh snapshot use <trunk|24.09|22.01>

${OFBIZ_LABEL_RUNTIME}:
  bash controllers/ofbiz.sh current
  bash controllers/ofbiz.sh run <start|background|stop|java> [target]

${OFBIZ_LABEL_BACKWARD_COMPATIBLE}:
  list
  install <version>
  installed
  use <version>
EOF
}
