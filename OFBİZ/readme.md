# 📄 Dosya Yolu: /OFBİZ/readme.md
# 📌 Amac: Apache OFBiz coklu surum kurulum ve Docker kullanimini aciklar
# 📌 View - Markdown
# Version: 3.0.0
# Aciklama: OFBiz 17.12, 18.12 ve 24.09 release serileri icin kurulum, gecis ve calistirma rehberi
#
# Bagimli Oldugu Katman: View | Controller | Service | Tool | Config

# Apache OFBiz Version Manager

Bu klasor artik tek bir OFBiz surumune bagli degildir.

Desteklenen resmi release serileri:

| Seri | Release araligi | Java | Durum |
| --- | --- | ---: | --- |
| 24.09 | 24.09.01 - 24.09.07 | 17 | Guncel seri |
| 18.12 | 18.12.01 - 18.12.19 | 8 | Legacy release serisi |
| 17.12 | 17.12.01 - 17.12.09 | 8 | Legacy release serisi |

22.01 Apache tarafinda branch/snapshot olarak bulunur ancak resmi release ZIP katalogunda yer almadigi icin bu kurucuda release olarak sunulmaz.

## Surumleri listele

~~~bash
bash ofbiz_linux.sh list
~~~

Aliaslar:

~~~text
latest -> 24.09.07
24.09  -> 24.09.07
18.12  -> 18.12.19
17.12  -> 17.12.09
~~~

## Linux kurulum

En guncel release:

~~~bash
sudo bash ofbiz_linux.sh install latest
~~~

Belirli seri icindeki en yeni release:

~~~bash
sudo bash ofbiz_linux.sh install 18.12
~~~

Tam release:

~~~bash
sudo bash ofbiz_linux.sh install 24.09.07
sudo bash ofbiz_linux.sh install 18.12.19
sudo bash ofbiz_linux.sh install 18.12.10
sudo bash ofbiz_linux.sh install 17.12.09
~~~

Kisa kullanim:

~~~bash
sudo bash ofbiz_linux.sh 18.12.10
~~~

Kurucu gerekli Java surumunu sistem Java'sindan ayri olarak indirir:

~~~text
/opt/ofbiz/jdks/temurin-17
/opt/ofbiz/jdks/temurin-8
~~~

Release'ler yan yana tutulur:

~~~text
/opt/ofbiz/releases/apache-ofbiz-24.09.07
/opt/ofbiz/releases/apache-ofbiz-18.12.19
/opt/ofbiz/releases/apache-ofbiz-18.12.10
/opt/ofbiz/releases/apache-ofbiz-17.12.09
~~~

Aktif release yolu:

~~~text
/opt/ofbiz/current
~~~

## Kurulu release'leri goruntule

~~~bash
bash ofbiz_linux.sh installed
~~~

Aktif release'i goruntule:

~~~bash
bash ofbiz_linux.sh current
~~~

## Aktif release degistir

~~~bash
sudo bash ofbiz_linux.sh use 18.12.10
~~~

Tekrar guncel seriye gecmek icin:

~~~bash
sudo bash ofbiz_linux.sh use 24.09.07
~~~

Bu islem release dosyalarini silmez. Sadece /opt/ofbiz/current symlink'ini degistirir.

## OFBiz baslatma

Aktif release:

~~~bash
bash ofbiz-run.sh start
~~~

Arka planda:

~~~bash
bash ofbiz-run.sh background
~~~

Durdurma:

~~~bash
bash ofbiz-run.sh stop
~~~

Belirli kurulu release'i aktif release'i degistirmeden calistirma:

~~~bash
bash ofbiz-run.sh start 18.12.10
~~~

Secilen release icin kullanilan Java'yi kontrol etme:

~~~bash
bash ofbiz-run.sh java 18.12.10
~~~

## Demo veri yukleme

Kurulum sirasinda demo veri yuklemek icin:

~~~bash
sudo OFBIZ_LOAD_DEMO=1 bash ofbiz_linux.sh install 24.09.07
~~~

Eski release:

~~~bash
sudo OFBIZ_LOAD_DEMO=1 bash ofbiz_linux.sh install 18.12.10
~~~

## Yeniden kurulum

~~~bash
sudo OFBIZ_FORCE_REINSTALL=1 bash ofbiz_linux.sh install 18.12.10
~~~

## Docker

Release listesini Docker aracindan da gorebilirsiniz:

~~~bash
bash docker-build.sh list
~~~

Guncel image:

~~~bash
bash docker-build.sh latest
~~~

Belirli image:

~~~bash
bash docker-build.sh 24.09.07
bash docker-build.sh 18.12.19
bash docker-build.sh 18.12.10
bash docker-build.sh 17.12.09
~~~

Varsayilan image isimleri:

~~~text
local/ofbiz:24.09.07
local/ofbiz:18.12.19
local/ofbiz:18.12.10
local/ofbiz:17.12.09
~~~

Belirli image adi:

~~~bash
OFBIZ_IMAGE=turkuaz/ofbiz:18.12.10 bash docker-build.sh 18.12.10
~~~

Eski release paketinde resmi Dockerfile yoksa config/Dockerfile.compat otomatik kullanilir.

Docker demo verisini kapatmak icin:

~~~bash
OFBIZ_DOCKER_LOAD_DEMO=0 bash docker-build.sh 18.12.10
~~~

Compose:

~~~bash
cp .env.example .env
docker compose up -d
~~~

Farkli release image'i:

~~~bash
OFBIZ_IMAGE=local/ofbiz:18.12.10 docker compose up -d
~~~

Log:

~~~bash
docker compose logs -f ofbiz
~~~

Durdurma:

~~~bash
docker compose down
~~~

Varsayilan HTTPS:

~~~text
https://localhost:8443/
~~~

## Dosya yapisi

~~~text
OFBİZ/
  config/
    Dockerfile.compat
    versions.conf
  tools/
    version-resolver.sh
  .env.example
  docker-build.sh
  docker-compose.yml
  ofbiz-run.sh
  ofbiz_linux.sh
  readme.md
~~~

Eski kurulum scriptleri referans amacli korunmustur. Yeni kurulumlarda ofbiz_linux.sh kullanilmalidir.

## Guvenlik

OFBiz ZIP dosyalari Apache SHA-512 dosyasi ile dogrulanir.

Java 8 ve Java 17 paketleri Eclipse Temurin uzerinden indirilir ve SHA-256 checksum ile dogrulanir.

Demo kullanici bilgilerini production ortaminda kullanmayin.

Production ortaminda veritabani, secret, TLS/reverse proxy ve erisim politikalari ayri olarak yonetilmelidir.

## Kaynaklar

- Apache OFBiz Downloads: https://ofbiz.apache.org/download
- Apache OFBiz Archive: https://archive.apache.org/dist/ofbiz/
- Apache OFBiz System Requirements: https://cwiki.apache.org/confluence/display/OFBIZ/System+Requirements
- Eclipse Temurin API: https://adoptium.net/installation/ci-scripts/
