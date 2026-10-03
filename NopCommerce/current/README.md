# 📄 Dosya Yolu: /NopCommerce/current/README.md
# 📌 Amac: Cok surumlu nopCommerce installer kullanimini, native/tam-Docker deployment ve DB modlarini tanimlamak
# 📌 Modul - Markdown
# Version: 1.7.0
# Aciklama: nopCommerce 4.30-4.90 stable ve 5.00 beta icin surum/runtime/DB/deployment/TLS uyumlu installer dokumani

Bagimli Oldugu Katman: Controller | Service | Repo | Tool | View | Language | Config

# Current Installer

Current installer ayni resmi nopCommerce NoSource Linux release paketini iki farkli uygulama deployment modu ile kurabilir:

- `native`: host .NET runtime + systemd + host Nginx.
- `docker`: nopCommerce + container Nginx + opsiyonel DB servisi Docker Compose stack olarak.

## Destek matrisi

| nopCommerce | Runtime | Native | Docker app | SQL Server | MySQL | PostgreSQL |
| --- | --- | --- | --- | --- | --- | --- |
| 4.30 | .NET Core 3.1 | evet | evet | external | external/docker | - |
| 4.40 | .NET 5 | evet | evet | external | external/docker | external/docker |
| 4.50.x | .NET 6 | evet | evet | external | external/docker | external/docker |
| 4.60.x | .NET 7 | evet | evet | external | external/docker | external/docker |
| 4.70.x | .NET 8 | evet | evet | external | external/docker | external/docker |
| 4.80.x | .NET 9 | evet | evet | external | external/docker | external/docker |
| 4.90.x | .NET 9 | evet | evet | external | external/docker | external/docker |
| 5.00.0-beta | .NET 10 | evet | evet | external | external/docker | external/docker |

MySQL nopCommerce 4.30 ile, PostgreSQL 4.40 ile desteklenmeye baslar.

## Uygulama modlari

Listele:

```bash
bash installer/controllers/install.sh --list-app-modes
bash installer/controllers/install.sh --list-tls-modes
```

### Native

Mevcut klasik Linux kurulumu korunur:

```bash
sudo bash installer/controllers/install.sh \
  --version 4.90.8 \
  --app-mode native \
  --db mysql \
  --db-mode external \
  --config /etc/nopcommerce-installer.env
```

Native mod:

- gerekli ASP.NET Core runtime'i hosta kurar,
- nopCommerce'i systemd servisi olarak calistirir,
- host Nginx reverse proxy kurar,
- `db-mode=docker` secilirse yalniz DB'yi container olarak calistirabilir.

### Tam Docker stack

```bash
sudo bash installer/controllers/install.sh \
  --version 4.90.8 \
  --app-mode docker \
  --db postgresql \
  --db-mode docker \
  --config /etc/nopcommerce-installer.env
```

Docker app modunda host .NET runtime ve host Nginx kurulmaz.

Compose stack:

```text
Internet
   |
   v
Nginx container :80
   |
   v
nopCommerce app container :80
   |
   +------> external DB
   |
   +------> MySQL/PostgreSQL Compose DB service
```

## Docker runtime profilleri

Installer NoSource release'i tekrar derlemez. Resmi release ZIP dogrulanir, acilir ve nopCommerce'in ilgili surumde kullandigi ASP.NET runtime tabanina paketlenir.

| nopCommerce | Docker runtime base |
| --- | --- |
| 4.30 | `mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine` |
| 4.40 | `mcr.microsoft.com/dotnet/aspnet:5.0-alpine` |
| 4.50 | `mcr.microsoft.com/dotnet/aspnet:6.0-alpine` |
| 4.60 | `mcr.microsoft.com/dotnet/aspnet:7.0-alpine` |
| 4.70 | `mcr.microsoft.com/dotnet/aspnet:8.0-alpine` |
| 4.80 / 4.90 | `mcr.microsoft.com/dotnet/aspnet:9.0-alpine` |
| 5.00 beta | `mcr.microsoft.com/dotnet/aspnet:10.0-alpine` |

Runtime paket profilleri resmi nopCommerce Dockerfile davranisina gore uretilir.

Bu nedenle eski 4.30/4.40 surumlerinde Docker app modu, EOL .NET runtime'i modern host isletim sistemine dogrudan kurmak zorunda kalmadan izole eder. Eski container base image/tag erisilebilirligi yine upstream Microsoft container registry'ye baglidir.

## Tam Docker + MySQL

Secret:

```bash
sudo cp installer/config/database/mysql-docker.secret.env.example /etc/nopcommerce-db.secret.env
sudo chown root:root /etc/nopcommerce-db.secret.env
sudo chmod 600 /etc/nopcommerce-db.secret.env
sudo nano /etc/nopcommerce-db.secret.env
```

Kurulum:

```bash
sudo bash installer/controllers/install.sh \
  --version latest \
  --app-mode docker \
  --db mysql \
  --db-mode docker \
  --config /etc/nopcommerce-installer.env
```

Bu modda MySQL portu hosta publish edilmez. nopCommerce DB'ye Compose internal network uzerinden `database:3306` ile baglanir.

## Tam Docker + PostgreSQL

```bash
sudo cp installer/config/database/postgresql-docker.secret.env.example /etc/nopcommerce-db.secret.env
sudo chown root:root /etc/nopcommerce-db.secret.env
sudo chmod 600 /etc/nopcommerce-db.secret.env

sudo bash installer/controllers/install.sh \
  --version 4.90.8 \
  --app-mode docker \
  --db postgresql \
  --db-mode docker \
  --config /etc/nopcommerce-installer.env
```

PostgreSQL de hosta publish edilmez; app container `database:5432` kullanir.

## Tam Docker + external DB

External SQL Server/MySQL/PostgreSQL de kullanilabilir:

```bash
sudo bash installer/controllers/install.sh \
  --version 4.90.8 \
  --app-mode docker \
  --db sqlserver \
  --db-mode external \
  --config /etc/nopcommerce-installer.env
```

External connection string container icinden erisilebilir bir host/domain kullanmalidir.

Host makinedeki DB'ye baglanmak gerekiyorsa connection string icinde `127.0.0.1` yerine `host.docker.internal` kullanilabilir. Compose app servisine `host-gateway` eslestirmesi otomatik eklenir.

## Web installer modu

DB config installer tarafindan yazilmasin istenirse:

```bash
sudo bash installer/controllers/install.sh \
  --version latest \
  --app-mode docker \
  --db web \
  --db-mode external \
  --config /etc/nopcommerce-installer.env
```

Bu durumda nopCommerce ilk web kurulum ekrani kullanilir.

## Docker Nginx

Varsayilan container image:

```text
nginx:1.30.5-alpine
```

Varsayilan public bind:

```text
0.0.0.0:80
```

Degistirmek icin:

```bash
NOP_DOCKER_STACK_HTTP_BIND_HOST="127.0.0.1"
NOP_DOCKER_STACK_HTTP_PORT="8080"
```

Installer ayni Compose projesine ait mevcut Nginx container'i yoksa ve secilen host portu baska bir servis tarafindan dinleniyorsa kurulumdan once hata verir.


## TLS / Let's Encrypt

TLS varsayilan olarak kapali kalir:

```text
NOP_TLS_MODE="off"
```

Desteklenen modlari listelemek icin:

```bash
bash installer/controllers/install.sh --list-tls-modes
```

Let's Encrypt icin config dosyasinda gercek domain ve email tanimlanir:

```bash
NOP_TLS_DOMAIN="shop.example.com"
NOP_TLS_EMAIL="admin@example.com"
NOP_TLS_STAGING="0"
```

Native HTTPS kurulumu:

```bash
sudo bash installer/controllers/install.sh \
  --version latest \
  --app-mode native \
  --tls-mode letsencrypt \
  --db mysql \
  --db-mode external \
  --config /etc/nopcommerce-installer.env
```

Tam Docker HTTPS kurulumu:

```bash
sudo bash installer/controllers/install.sh \
  --version latest \
  --app-mode docker \
  --tls-mode letsencrypt \
  --db postgresql \
  --db-mode docker \
  --config /etc/nopcommerce-installer.env
```

Installer once HTTP konfigurasyonunu baslatir ve `/.well-known/acme-challenge/` webroot yolunu sunar. Sertifika basariyla alindiktan sonra Nginx HTTPS konfigurasyonuna gecilir ve HTTP istekleri HTTPS'e yonlendirilir.

Let's Encrypt modu tek bir FQDN domain kullanir. HTTP-01 challenge nedeniyle domain DNS kaydinin hedef sunucuya gelmesi ve public port 80'in sertifika alma sirasinda erisilebilir olmasi gerekir. Wildcard sertifika bu webroot modulunun kapsami disindadir.

### Native Certbot

Native app modunda host paket yoneticisinden `certbot` kurulur ve webroot authenticator kullanilir.

Varsayilan yollar:

```text
certificates: /etc/letsencrypt
webroot:      /var/lib/nopcommerce/acme
```

### Docker Certbot

Docker app modunda hosta Certbot paketi kurulmaz. Sabit image kullanilir:

```text
certbot/certbot:v5.8.0
```

Host persistent TLS alanlari:

```text
/opt/nopcommerce/docker/tls/letsencrypt
/opt/nopcommerce/docker/tls/webroot
```

Nginx container bunlari salt-okunur olarak:

```text
/etc/letsencrypt
/var/www/certbot
```

altinda gorur.

HTTPS aktifken Docker Nginx varsayilan olarak hem `80` hem `443` portlarini publish eder. MySQL/PostgreSQL servisleri yine hosta publish edilmez.

### Otomatik renewal

Installer kendi systemd timer'ini kurar:

```text
nopcommerce-certbot-renew.timer
```

Varsayilan kontrol plani gunde iki kezdir ve ayni anda cok sayida hostun CA'ya gitmesini engellemek icin rastgele gecikme uygulanir.

Native modda Certbot `renew --deploy-hook` kullanir. Nginx yalniz basarili sertifika yenilenmesinden sonra config test edilerek reload edilir.

Docker modunda Certbot container renewal sonrasi paylasilan webroot'a marker birakir. Host renewal scripti bu marker'i gorurse Compose Nginx servisini `nginx -t` ile kontrol edip reload eder.

TLS daha sonra `off` yapilirsa installer kendi renewal timer/script/hook dosyalarini devre disi birakir ve siler; mevcut sertifika arsivi otomatik silinmez.

### Staging

Rate-limit riski olmadan akisi test etmek icin:

```bash
NOP_TLS_STAGING="1"
```

kullanilabilir. Staging sertifikasi tarayicida guvenilir kabul edilmez; production gecisinde bu deger tekrar `0` yapilmalidir.

### HTTPS guvenlik ayarlari

Uretilen HTTPS Nginx profili:

- TLS 1.2 ve TLS 1.3,
- HTTP -> HTTPS redirect,
- `Strict-Transport-Security: max-age=31536000`,
- Let's Encrypt fullchain/private key,
- reverse proxy `X-Forwarded-Proto https`

ayarlarini uygular.

## Kalici uygulama verisi

Docker stack verileri varsayilan olarak:

```text
/opt/nopcommerce/docker/persist
```

altinda tutulur.

Kalici yollar:

- `App_Data`
- `Plugins`
- `logs`
- `wwwroot/bundles`
- `wwwroot/db_backups`
- `wwwroot/files/exportimport`
- `wwwroot/icons`
- `wwwroot/images`
- `wwwroot/sitemaps`

Ilk Docker deployment'ta resmi release'deki mevcut icerik persistent alana seed edilir. Sonraki installer calismalarinda mevcut persistent klasorler otomatik silinmez veya sifirlanmaz.

## Docker DB verisi

Tam Docker stack icinde MySQL/PostgreSQL icin Compose named volume kullanilir:

```text
<project>_database-data
```

DB servisi hosta port publish etmez.

Native app + `db-mode=docker` seceneginde ise onceki standalone DB container davranisi korunur ve DB varsayilan olarak `127.0.0.1` uzerine publish edilir.

## Secret guvenligi

Secret dosyasi:

```text
/etc/nopcommerce-db.secret.env
```

Varsayilan olarak `chmod 600` olmak zorundadir.

Tam Docker Compose YAML dosyasi gercek DB parolasini yazmaz; yalniz environment degiskeni referanslarini tutar. Parolalar connection string disinda loglanmaz.

`App_Data/dataSettings.json` persistent klasorde `600` izinle uretilir.

## Uretilen Docker dosyalari

Varsayilan:

```text
/opt/nopcommerce/docker/docker-compose.yml
/opt/nopcommerce/docker/nginx.conf
/opt/nopcommerce/releases/<version>/.installer-docker/Dockerfile
```

Dockerfile installer tarafindan secilen nopCommerce surum ailesine gore uretilir.

## Listeleme

```bash
bash installer/controllers/install.sh --list-versions
bash installer/controllers/install.sh --list-databases
bash installer/controllers/install.sh --list-app-modes
```

## Mimari

```text
installer/
├── controllers/
│   └── install.sh
├── services/
│   └── install_service.sh
├── repositories/
│   ├── application_repository.sh
│   ├── database_repository.sh
│   ├── release_repository.sh
│   ├── tls_repository.sh
│   └── version_repository.sh
├── tools/
│   ├── docker_database_tool.sh
│   ├── docker_stack_tool.sh
│   ├── nginx_tool.sh
│   ├── os_tool.sh
│   ├── systemd_tool.sh
│   └── tls_tool.sh
├── views/
│   └── console_view.sh
├── language/
│   └── tr.labels
└── config/
    ├── application-catalog.env
    ├── database-catalog.env
    ├── tls-catalog.env
    ├── database/
    ├── docker/
    │   ├── nginx.conf.tpl
    │   └── nginx.tls.conf.tpl
    ├── installer.env.example
    ├── version-catalog.env
    ├── nginx.conf.tpl
    ├── nginx.tls.conf.tpl
    ├── nopcommerce.service.tpl
    ├── tls-renew.service.tpl
    └── tls-renew.timer.tpl
```

## Sinirlar

- SQL Server Docker DB provisioning henuz yoktur; external SQL Server desteklenir.
- Docker Engine ve Compose plugin installer tarafindan kurulmaz; mevcut olmalidir.
- Bu mekanizma database upgrade/migration zinciri degildir.
- Eski ve yeni nopCommerce surumlerini ayni DB uzerinde gelisiguzel calistirmak upgrade degildir.
- Let's Encrypt webroot modu wildcard sertifika vermez; wildcard icin ileride DNS-01 provider modulu gerekir.
- 4.30/4.40 gibi EOL runtime/container base tag'leri upstream registry erisilebilirligine baglidir.
