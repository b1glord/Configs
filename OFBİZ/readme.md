# 📄 Dosya Yolu: /OFBİZ/readme.md
# 📌 Amac: Apache OFBiz kurulum dosyalarinin guncel ve legacy kullanimini aciklar
# 📌 View - Markdown
# Version: 2.0.0
# Aciklama: OFBiz 24.09.07, JDK 17, Docker ve eski 18.12 scriptleri icin kullanim rehberi
#
# Bagimli Oldugu Katman: View

# Apache OFBiz Configs

Bu klasorde eski OFBiz 18.12 kurulum notlari korunur, fakat yeni kurulumlar icin varsayilan hedef **Apache OFBiz 24.09.07 + JDK 17** olmalidir.

Apache, en guncel kararlı dalin kullanilmasini onerir. 18.12 serisi kapali bir seridir; yeni kurulumlarda 24.09 kullanin.

## Onerilen yol: Docker

Windows host uzerinde OFBiz'i dogrudan Windows'a kurmak yerine Docker Desktop + WSL2 kullanmak daha temizdir.

1. Ornek ortam dosyasini kopyalayin:

~~~bash
cp .env.example .env
~~~

2. Resmi OFBiz kaynak paketindeki Dockerfile ile local image olusturun:

~~~bash
bash docker-build.sh
~~~

3. Servisi baslatin:

~~~bash
docker compose up -d
~~~

4. Loglari izleyin:

~~~bash
docker compose logs -f ofbiz
~~~

5. Durdurun:

~~~bash
docker compose down
~~~

Varsayilan HTTPS adresi:

~~~text
https://localhost:8443/
~~~

## Linux native kurulum

Yeni script 24.09.07 ve JDK 17 kullanir. Script root yetkisi ister ve Debian/Ubuntu, RHEL/Fedora/CentOS ailesi ile openSUSE paket yoneticilerini destekler.

Kurulum:

~~~bash
sudo bash ofbiz_linux.sh
~~~

Demo verisi ile kurulum:

~~~bash
sudo OFBIZ_LOAD_DEMO=1 bash ofbiz_linux.sh
~~~

Farkli 24.09.x surumu:

~~~bash
sudo OFBIZ_VERSION=24.09.07 bash ofbiz_linux.sh
~~~

Kurulum dizini:

~~~text
/opt/ofbiz/current
~~~

Baslatma:

~~~bash
cd /opt/ofbiz/current
./gradlew ofbiz
~~~

## Dosya durumu

| Dosya | Durum | Not |
| --- | --- | --- |
| ofbiz_linux.sh | CURRENT | 24.09.x + JDK 17 kurulumu |
| docker-build.sh | CURRENT | Resmi OFBiz Dockerfile ile local image build eder |
| docker-compose.yml | CURRENT | Local OFBiz container calistirir |
| .env.example | CURRENT | Docker degiskenleri |
| ofbiz_linux 18.12.sh | LEGACY | Eski 18.12.07 kurulumu; referans icin tutulur |
| AdoptJDK11.sh | LEGACY | Eski CentOS Java 11 yardimcisi |
| AdoptJDK8.sh | LEGACY | AdoptOpenJDK 8 deposu artik guncel akisin parcasi degildir |
| install_oraclejdk8.sh | LEGACY | Eski Oracle JDK 8 paketi; yeni kurulumda kullanmayin |
| certbot.sh | LEGACY | Eski yum/pip tabanli Certbot notu |
| squid.sh | LEGACY | Eski CentOS Squid notu |

## Guvenlik

Demo kullanici bilgilerini production ortaminda kullanmayin. Production kurulumunda sifreleri, secret key'leri, reverse proxy/TLS ayarlarini ve veritabani yapilandirmasini ayrica yonetin.

## Kaynaklar

- Apache OFBiz Downloads: https://ofbiz.apache.org/download
- Apache OFBiz Framework: https://github.com/apache/ofbiz-framework
- Apache OFBiz Dockerfile: https://github.com/apache/ofbiz-framework/blob/trunk/Dockerfile
