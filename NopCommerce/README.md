# 📄 Dosya Yolu: /NopCommerce/README.md
# 📌 Amac: NopCommerce current installer, legacy script, nginx konfigurasyon ve arsiv yapisini dokumante etmek
# 📌 Modul - Markdown
# Version: 2.2.0
# Aciklama: Cok surumlu stable/prerelease current installer ile tarihsel dosyalarin ayrimini aciklar

Bagimli Oldugu Katman: Controller | Service | Repo | Tool | View | Language | Config

# NopCommerce Configs

Bu klasor nopCommerce icin guncel cok surumlu installer'i, eski kurulum scriptlerini, Nginx ayarlarini ve tarihsel varliklari saklar.

## Surum durumu

- Current installer 4.30-4.90 stable ailelerini destekler.
- Genel `latest` alias'i bu duzenleme tarihinde 4.90.8'e gider.
- 5.00.0-beta yalniz `beta` veya tam prerelease surumu acikca secilirse kurulur.
- Tam patch surumu verilebilir; release varligi resmi GitHub metadata ile dogrulanir.
- Eski CentOS/ISPConfig/Pardus scriptleri `legacy/` altinda tarihsel referans olarak korunur.
- Yeni kurulumlar icin `current/installer/` kullanilmalidir.

## Klasor yapisi

```text
NopCommerce/
├── README.md
├── current/
│   ├── README.md
│   └── installer/
├── legacy/
│   └── installers/
│       ├── centos/
│       │   ├── standalone/
│       │   └── ispconfig/
│       └── pardus/
├── config/
│   └── nginx/
├── assets/
│   ├── images/
│   └── themes/
└── archive/
    ├── backups/
    └── notes/
```

## Current installer

Current installer tek bir nopCommerce surumune sabit degildir.

Ornek:

```bash
bash NopCommerce/current/installer/controllers/install.sh --list-versions
sudo bash NopCommerce/current/installer/controllers/install.sh --version 4.30 --config /etc/nopcommerce-installer.env
sudo bash NopCommerce/current/installer/controllers/install.sh --version 4.60.6 --config /etc/nopcommerce-installer.env
sudo bash NopCommerce/current/installer/controllers/install.sh --version latest --config /etc/nopcommerce-installer.env
sudo bash NopCommerce/current/installer/controllers/install.sh --version beta --config /etc/nopcommerce-installer.env
```

Detayli kullanim icin `current/README.md` dosyasina bak.

## Legacy installer envanteri

| Platform | Tip | nopCommerce |
| --- | --- | --- |
| CentOS | Standalone | 4.30 |
| CentOS | Standalone | 4.40 |
| CentOS | ISPConfig | 4.30 |
| CentOS | ISPConfig | 4.40 |
| CentOS | ISPConfig | 4.50 |
| CentOS | ISPConfig | 4.60 |
| Pardus | Standalone | 4.30 |

Not: Eski `installcentos430.sh` ve `installcentos440.sh` dosyalari ayni Git blob icerigine sahipti. Ikisi de tarihsel kayit kaybolmasin diye farkli surum adlariyla legacy alanda korunmustur.

## Nginx

- `config/nginx/reverse-proxy.location.conf`: Eski nopCommerce reverse proxy location blogu.
- `config/nginx/timeout.conf`: Eski uzun proxy timeout degerleri.
- `archive/notes/nginxsecurity.sh`: Eski guvenlik notlari.

Current installer kendi Nginx template'ini `current/installer/config/nginx.conf.tpl` altinda tutar.

## Guvenlik ve uyumluluk

Legacy scriptler yeni sunucularda production installer olarak kullanilmamalidir.

Current installer eski nopCommerce surumlerini de kurabilir; ancak .NET Core 3.1, .NET 5, .NET 6 ve .NET 7 gibi eski runtime'lar modern Linux dagitimlarinda ek sistem kutuphanesi veya eski OS gerektirebilir. Installer bu durumu uyari olarak bildirir.

Eski GitHub release kayitlarinda SHA-256 digest bulunmadiginda dosya boyutu kontrol edilir. Bu davranis config uzerinden kapatilabilir.

Prerelease surumler `latest` tarafindan otomatik secilmez.

## Arsiv

- `.old` ve `.bak` dosyalari `archive/backups/` altindadir.
- Eski tema ZIP dosyasi `assets/themes/` altindadir.
- Eski ekran goruntuleri `assets/images/` altinda korunur.
