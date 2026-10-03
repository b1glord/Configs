# Dosya Yolu: /OFBIZ/views/README.md
# Amac: Apache OFBiz release, snapshot, runtime ve Docker kullanimini aciklar
# View - Markdown
# Version: 4.0.0
# Aciklama: OFBiz 17.12, 18.12, 24.09 release ve trunk/22.01/24.09 snapshot rehberi
#
# Bagimli Oldugu Katman: View | Controller | Service | Repo | Tool | Config

# Apache OFBiz Version Manager

## Release katalogu

| Seri | Release araligi | Java |
| --- | --- | ---: |
| 24.09 | 24.09.01 - 24.09.07 | 17 |
| 18.12 | 18.12.01 - 18.12.19 | 8 |
| 17.12 | 17.12.01 - 17.12.09 | 8 |

~~~bash
bash controllers/ofbiz.sh release list
sudo bash controllers/ofbiz.sh release install latest
sudo bash controllers/ofbiz.sh release install 24.09.07
sudo bash controllers/ofbiz.sh release install 18.12.10
~~~

Eski komutlar geriye uyumludur:

~~~bash
bash controllers/ofbiz.sh list
sudo bash controllers/ofbiz.sh install 18.12.10
~~~

## Snapshot katalogu

Snapshot kurulumu ZIP release degil, Apache Git branch'i kullanir.

| Alias | Apache branch | Java |
| --- | --- | ---: |
| trunk | trunk | 17 |
| 24.09 | release24.09 | 17 |
| 22.01 | release22.01 | 17 |

~~~bash
bash controllers/ofbiz.sh snapshot list
sudo bash controllers/ofbiz.sh snapshot install trunk
sudo bash controllers/ofbiz.sh snapshot install 24.09
sudo bash controllers/ofbiz.sh snapshot install 22.01
~~~

Snapshot guncelleme:

~~~bash
sudo bash controllers/ofbiz.sh snapshot update trunk
sudo bash controllers/ofbiz.sh snapshot update 22.01
~~~

Kurulu snapshotlar:

~~~bash
bash controllers/ofbiz.sh snapshot installed
~~~

## Aktif hedef secme

Release:

~~~bash
sudo bash controllers/ofbiz.sh release use 24.09.07
~~~

Snapshot:

~~~bash
sudo bash controllers/ofbiz.sh snapshot use trunk
~~~

Aktif hedefi gor:

~~~bash
bash controllers/ofbiz.sh current
~~~

## Calistirma

~~~bash
bash controllers/ofbiz.sh run start
bash controllers/ofbiz.sh run background
bash controllers/ofbiz.sh run stop
bash controllers/ofbiz.sh run java
~~~

Belirli release:

~~~bash
bash controllers/ofbiz.sh run start release:18.12.10
~~~

Belirli snapshot:

~~~bash
bash controllers/ofbiz.sh run start snapshot:trunk
bash controllers/ofbiz.sh run start snapshot:22.01
~~~

## Demo veri

~~~bash
sudo OFBIZ_LOAD_DEMO=1 bash controllers/ofbiz.sh release install 24.09.07
sudo OFBIZ_LOAD_DEMO=1 bash controllers/ofbiz.sh snapshot install trunk
~~~

## Zorla yeniden kurulum

~~~bash
sudo OFBIZ_FORCE_REINSTALL=1 bash controllers/ofbiz.sh release install 18.12.10
sudo OFBIZ_FORCE_REINSTALL=1 bash controllers/ofbiz.sh snapshot install 22.01
~~~

## Docker release image

~~~bash
bash tools/docker-build.sh list
bash tools/docker-build.sh 24.09.07
bash tools/docker-build.sh 18.12.10
~~~

## Docker Compose

~~~bash
cd tools/docker
cp .env.example .env
docker compose -f compose.yml up -d
docker compose -f compose.yml logs -f ofbiz
docker compose -f compose.yml down
~~~

## CI dogrulama

Local:

~~~bash
bash tools/ci/validate-structure.sh
~~~

GitHub Actions yalnizca OFBIZ altindaki degisikliklerde syntax, klasor yapisi, header ve resolver testlerini calistirir.

## Legacy

tools/legacy altindaki scriptler tarihsel referans icindir ve aktif kurulum akisi tarafindan cagirilmaz.

## Mimari

Detayli katman aciklamasi icin views/ARCHITECTURE.md dosyasina bakin.
