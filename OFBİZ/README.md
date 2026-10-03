# Dosya Yolu: /OFBIZ/README.md
# Amac: OFBiz konfigurasyon paketinin ana giris ve klasor haritasini sunar
# View - Markdown
# Version: 1.0.0
# Aciklama: Katmanli klasor yapisi, temel komutlar ve detayli dokumana yonlendirme
#
# Bagimli Oldugu Katman: View | Controller | Service | Tool | Config

# Apache OFBiz Configs

Bu klasor coklu OFBiz release kurulumu, aktif surum secimi ve Docker image olusturma araclarini barindirir.

## Klasor yapisi

~~~text
OFBIZ/
  controllers/
    ofbiz.sh
  services/
    version-resolver.sh
  config/
    versions.conf
  tools/
    ofbiz-run.sh
    docker-build.sh
    docker/
      Dockerfile.compat
      compose.yml
      .env.example
    legacy/
      java/
      ofbiz/
      server/
  views/
    README.md
  README.md
~~~

## Hizli kullanim

Surumleri listele:

~~~bash
bash controllers/ofbiz.sh list
~~~

Belirli surumu kur:

~~~bash
sudo bash controllers/ofbiz.sh install 24.09.07
sudo bash controllers/ofbiz.sh install 18.12.10
~~~

Aktif surumu degistir:

~~~bash
sudo bash controllers/ofbiz.sh use 18.12.10
~~~

Baslat:

~~~bash
bash tools/ofbiz-run.sh start
~~~

Docker image olustur:

~~~bash
bash tools/docker-build.sh 24.09.07
~~~

Detayli kullanim icin views/README.md dosyasina bakin.
