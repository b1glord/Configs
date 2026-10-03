# 📄 Dosya Yolu: /NopCommerce/README.md
# 📌 Amac: NopCommerce current installer, legacy script, nginx konfigurasyon ve arsiv yapisini dokumante etmek
# 📌 Modul - Markdown
# Version: 2.3.0
# Aciklama: Cok surumlu current installer, DB secimi ve Docker DB provisioning ile tarihsel dosyalarin ayrimini aciklar

Bagimli Oldugu Katman: Controller | Service | Repo | Tool | View | Language | Config

# NopCommerce Configs

Bu klasor nopCommerce icin guncel cok surumlu installer'i, eski kurulum scriptlerini, Nginx ayarlarini ve tarihsel varliklari saklar.

## Surum durumu

- Current installer 4.30-4.90 stable ailelerini destekler.
- Genel `latest` alias'i bu duzenleme tarihinde 4.90.8'e gider.
- 5.00.0-beta yalniz acikca secilirse kurulur.
- Tam patch surumu verilebilir; release varligi resmi GitHub metadata ile dogrulanir.
- SQL Server/MySQL/PostgreSQL provider secimi surume gore dogrulanir.
- MySQL ve PostgreSQL istege bagli Docker DB provisioning ile kurulabilir.
- SQL Server Docker provisioning henuz yoktur; external SQL Server desteklenir.
- Eski CentOS/ISPConfig/Pardus scriptleri `legacy/` altinda tarihsel referans olarak korunur.

## Klasor yapisi

```text
NopCommerce/
├── README.md
├── current/
│   ├── README.md
│   └── installer/
├── legacy/
│   └── installers/
├── config/
│   └── nginx/
├── assets/
└── archive/
```

## Current installer ornekleri

Surumleri listele:

```bash
bash NopCommerce/current/installer/controllers/install.sh --list-versions
bash NopCommerce/current/installer/controllers/install.sh --list-databases
```

External DB:

```bash
sudo bash NopCommerce/current/installer/controllers/install.sh \
  --version 4.90.8 \
  --db mysql \
  --db-mode external \
  --config /etc/nopcommerce-installer.env
```

Docker MySQL:

```bash
sudo bash NopCommerce/current/installer/controllers/install.sh \
  --version 4.90.8 \
  --db mysql \
  --db-mode docker \
  --config /etc/nopcommerce-installer.env
```

Docker PostgreSQL:

```bash
sudo bash NopCommerce/current/installer/controllers/install.sh \
  --version 4.90.8 \
  --db postgresql \
  --db-mode docker \
  --config /etc/nopcommerce-installer.env
```

Detayli kullanim, secret dosyalari, Docker volume davranisi ve destek matrisi icin `current/README.md` dosyasina bak.

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

Not: Eski `installcentos430.sh` ve `installcentos440.sh` dosyalari ayni Git blob icerigine sahipti. Tarihsel kayit kaybolmasin diye ikisi de legacy alanda korunmustur.

## Nginx

- `config/nginx/reverse-proxy.location.conf`: Eski reverse proxy blogu.
- `config/nginx/timeout.conf`: Eski uzun proxy timeout degerleri.
- `archive/notes/nginxsecurity.sh`: Eski guvenlik notlari.
- Current installer kendi Nginx template'ini `current/installer/config/nginx.conf.tpl` altinda tutar.

## Guvenlik ve uyumluluk

Legacy scriptler yeni sunucularda production installer olarak kullanilmamalidir.

Current installer eski nopCommerce surumlerini kurabilir; eski .NET runtime'lari modern Linux dagitimlarinda ek sistem kutuphanesi veya eski OS gerektirebilir.

DB secret dosyalari repo disinda ve `chmod 600` ile tutulur. Docker DB portlari varsayilan olarak yalniz `127.0.0.1` adresine bind edilir. Installer mevcut DB volume'larini otomatik silmez.

Eski GitHub release kayitlarinda SHA-256 digest bulunmadiginda dosya boyutu kontrol edilir. Prerelease surumler `latest` tarafindan otomatik secilmez.

## Arsiv

- `.old` ve `.bak` dosyalari `archive/backups/` altindadir.
- Eski tema ZIP dosyasi `assets/themes/` altindadir.
- Eski ekran goruntuleri `assets/images/` altinda korunur.
