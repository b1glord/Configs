# Dosya Yolu: /OFBIZ/README.md
# Amac: OFBiz konfigurasyon paketinin ana giris ve klasor haritasini sunar
# View - Markdown
# Version: 2.1.0
# Aciklama: Release, snapshot, runtime ve Docker araclari icin hizli baslangic rehberi
#
# Bagimli Oldugu Katman: View | Controller | Service | Repo | Tool | Language | Config

# Apache OFBiz Configs

Bu paket Apache OFBiz'in sabit release surumlerini ve branch tabanli snapshot hedeflerini ayni makinede yan yana yonetir.

## Klasor yapisi

~~~text
OFBIZ/
  config/
    runtime.conf
    snapshots.conf
    sources.conf
    versions.conf
  controllers/
    ofbiz.sh
  services/
    release-service.sh
    runtime-service.sh
    snapshot-resolver.sh
    snapshot-service.sh
    version-resolver.sh
  repositories/
    install-repository.sh
  tools/
    ci/
    docker/
    legacy/
    docker-build.sh
    git-tool.sh
    java-tool.sh
    ofbiz-run.sh
    release-tool.sh
    system-tool.sh
  views/
    ARCHITECTURE.md
    README.md
    help-view.sh
  language/
    en.conf
  README.md
~~~

## Release

~~~bash
bash controllers/ofbiz.sh release list
sudo bash controllers/ofbiz.sh release install 24.09.07
sudo bash controllers/ofbiz.sh release install 18.12.10
~~~

## Snapshot / branch

~~~bash
bash controllers/ofbiz.sh snapshot list
sudo bash controllers/ofbiz.sh snapshot install trunk
sudo bash controllers/ofbiz.sh snapshot install 24.09
sudo bash controllers/ofbiz.sh snapshot install 22.01
sudo bash controllers/ofbiz.sh snapshot update trunk
~~~

## Aktif hedef

~~~bash
bash controllers/ofbiz.sh current
sudo bash controllers/ofbiz.sh release use 24.09.07
sudo bash controllers/ofbiz.sh snapshot use trunk
~~~

## Calistirma

~~~bash
bash controllers/ofbiz.sh run start
bash controllers/ofbiz.sh run background
bash controllers/ofbiz.sh run stop
bash controllers/ofbiz.sh run java
~~~

Belirli hedef:

~~~bash
bash controllers/ofbiz.sh run start release:18.12.10
bash controllers/ofbiz.sh run start snapshot:trunk
bash controllers/ofbiz.sh run start snapshot:22.01
~~~

Detayli kullanim: views/README.md

Mimari: views/ARCHITECTURE.md
