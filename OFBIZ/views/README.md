# Dosya Yolu: /OFBIZ/views/README.md
# Amac: Apache OFBiz coklu surum kurulum, calistirma ve Docker kullanimini aciklar
# View - Markdown
# Version: 3.1.0
# Aciklama: OFBiz 17.12, 18.12 ve 24.09 release serileri icin detayli kullanim rehberi
#
# Bagimli Oldugu Katman: View | Controller | Service | Tool | Config

# Apache OFBiz Version Manager

Aktif akista katmanlar ayridir:

- Controller: controllers/ofbiz.sh
- Service: services/version-resolver.sh
- Config: config/versions.conf
- Tool: tools/ofbiz-run.sh ve tools/docker-build.sh
- Docker: tools/docker/
- Legacy: tools/legacy/

## Desteklenen release serileri

| Seri | Release araligi | Java | Durum |
| --- | --- | ---: | --- |
| 24.09 | 24.09.01 - 24.09.07 | 17 | Guncel seri |
| 18.12 | 18.12.01 - 18.12.19 | 8 | Legacy release serisi |
| 17.12 | 17.12.01 - 17.12.09 | 8 | Legacy release serisi |

22.01 resmi release ZIP katalogunda bulunmadigi icin release kurucusuna eklenmez.

## Surumleri listele

~~~bash
bash controllers/ofbiz.sh list
~~~

Aliaslar:

~~~text
latest -> 24.09.07
24.09  -> 24.09.07
18.12  -> 18.12.19
17.12  -> 17.12.09
~~~

## Linux kurulum

~~~bash
sudo bash controllers/ofbiz.sh install latest
sudo bash controllers/ofbiz.sh install 24.09.07
sudo bash controllers/ofbiz.sh install 18.12.19
sudo bash controllers/ofbiz.sh install 18.12.10
sudo bash controllers/ofbiz.sh install 17.12.09
~~~

Kurulu release listesi:

~~~bash
bash controllers/ofbiz.sh installed
~~~

Aktif release:

~~~bash
bash controllers/ofbiz.sh current
~~~

Aktif release degistirme:

~~~bash
sudo bash controllers/ofbiz.sh use 18.12.10
sudo bash controllers/ofbiz.sh use 24.09.07
~~~

## Calistirma

~~~bash
bash tools/ofbiz-run.sh start
bash tools/ofbiz-run.sh background
bash tools/ofbiz-run.sh stop
bash tools/ofbiz-run.sh java 18.12.10
~~~

Belirli kurulu release'i aktif release'i degistirmeden calistirma:

~~~bash
bash tools/ofbiz-run.sh start 18.12.10
~~~

## Demo veri

~~~bash
sudo OFBIZ_LOAD_DEMO=1 bash controllers/ofbiz.sh install 24.09.07
~~~

## Yeniden kurulum

~~~bash
sudo OFBIZ_FORCE_REINSTALL=1 bash controllers/ofbiz.sh install 18.12.10
~~~

## Docker image

~~~bash
bash tools/docker-build.sh list
bash tools/docker-build.sh 24.09.07
bash tools/docker-build.sh 18.12.10
~~~

Varsayilan image adi:

~~~text
local/ofbiz:<version>
~~~

## Docker Compose

~~~bash
cd tools/docker
cp .env.example .env
docker compose -f compose.yml up -d
docker compose -f compose.yml logs -f ofbiz
docker compose -f compose.yml down
~~~

## Legacy

tools/legacy/ altindaki scriptler sadece tarihsel referans icindir. Yeni kurulumlarda kullanilmaz.

## Guvenlik

OFBiz release ZIP dosyalari Apache SHA-512 dosyasi ile dogrulanir.

Java paketleri Eclipse Temurin kaynagindan indirilir ve checksum kontrolunden gecirilir.

Production ortaminda demo kullanici bilgilerini kullanmayin. Veritabani, secret, TLS ve reverse proxy ayarlarini ayri yonetin.
