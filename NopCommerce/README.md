# 📄 Dosya Yolu: /NopCommerce/README.md
# 📌 Amac: NopCommerce current installer, legacy script, nginx konfigurasyon ve arsiv yapisini dokumante etmek
# 📌 Modul - Markdown
# Version: 2.4.0
# Aciklama: Cok surumlu native/tam-Docker current installer ile tarihsel dosyalarin ayrimini aciklar

Bagimli Oldugu Katman: Controller | Service | Repo | Tool | View | Language | Config

# NopCommerce Configs

Bu klasor nopCommerce icin guncel cok surumlu installer'i, eski kurulum scriptlerini, Nginx ayarlarini ve tarihsel varliklari saklar.

## Current installer yetenekleri

- 4.30-4.90 stable surum aileleri desteklenir.
- 5.00.0-beta yalniz acikca secilirse kurulur.
- `native` mod: host .NET + systemd + host Nginx.
- `docker` mod: nopCommerce + container Nginx + opsiyonel MySQL/PostgreSQL Docker Compose stack.
- Native app ile DB-only Docker modu korunur.
- SQL Server external olarak desteklenir.
- MySQL Docker provisioning: `mysql:8.4`.
- PostgreSQL Docker provisioning: `postgres:17`.
- Docker Nginx: `nginx:1.30.5-alpine`.
- Tam Docker DB servisleri hosta port publish etmez.
- Release paketi resmi GitHub metadata ile dogrulanir.
- Eski installer dosyalari `legacy/` altinda korunur.

## Hizli kullanim

Listele:

```bash
bash NopCommerce/current/installer/controllers/install.sh --list-versions
bash NopCommerce/current/installer/controllers/install.sh --list-databases
bash NopCommerce/current/installer/controllers/install.sh --list-app-modes
```

Native:

```bash
sudo bash NopCommerce/current/installer/controllers/install.sh \
  --version latest \
  --app-mode native \
  --db mysql \
  --db-mode external \
  --config /etc/nopcommerce-installer.env
```

Tam Docker:

```bash
sudo bash NopCommerce/current/installer/controllers/install.sh \
  --version latest \
  --app-mode docker \
  --db postgresql \
  --db-mode docker \
  --config /etc/nopcommerce-installer.env
```

Detayli surum/runtime/DB matrisi, secret dosyalari, persistent path'ler ve Docker davranisi icin `current/README.md` dosyasina bak.

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

Eski `installcentos430.sh` ve `installcentos440.sh` dosyalari ayni tarihsel Git blob icerigine sahipti; kayit kaybolmasin diye ikisi de legacy alanda korunur.

## Guvenlik ve uyumluluk

Legacy scriptler yeni sunucularda production installer olarak kullanilmamalidir.

Native modda eski .NET runtime'lari modern Linux dagitimlarinda sistem kutuphanesi uyumsuzlugu yasayabilir. Tam Docker modu bu runtime'i container icine izole eder; ancak EOL Microsoft base image tag'lerinin registry erisilebilirligi upstream'e baglidir.

DB secret dosyalari repo disinda ve `chmod 600` ile tutulur. Tam Docker stack icindeki DB servisi hosta port publish etmez. Installer mevcut persistent uygulama klasorlerini veya DB volume'larini otomatik silmez.

Prerelease surumler `latest` tarafindan otomatik secilmez.

## Arsiv

- `.old` ve `.bak` dosyalari `archive/backups/` altindadir.
- Eski tema ZIP dosyasi `assets/themes/` altindadir.
- Eski ekran goruntuleri `assets/images/` altinda korunur.
