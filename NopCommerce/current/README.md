# 📄 Dosya Yolu: /NopCommerce/current/README.md
# 📌 Amac: Cok surumlu nopCommerce Linux installer kullanimini, DB secimini ve Docker provisioning davranisini tanimlamak
# 📌 Modul - Markdown
# Version: 1.5.0
# Aciklama: nopCommerce 4.30-4.90 stable ve 5.00 beta icin surum/runtime/DB uyumlu installer dokumani

Bagimli Oldugu Katman: Controller | Service | Repo | Tool | View | Language | Config

# Current Installer

Bu alan nopCommerce 4.30 ve sonrasi desteklenen Linux release paketlerini ayni installer mimarisi ile kurar.

## Destek matrisi

| nopCommerce | Runtime | SQL Server | MySQL | PostgreSQL |
| --- | --- | --- | --- | --- |
| 4.30 | .NET Core 3.1 | external | external/docker | - |
| 4.40 | .NET 5 | external | external/docker | external/docker |
| 4.50.x | .NET 6 | external | external/docker | external/docker |
| 4.60.x | .NET 7 | external | external/docker | external/docker |
| 4.70.x | .NET 8 | external | external/docker | external/docker |
| 4.80.x | .NET 9 | external | external/docker | external/docker |
| 4.90.x | .NET 9 | external | external/docker | external/docker |
| 5.00.0-beta | .NET 10 | external | external/docker | external/docker |

MySQL nopCommerce 4.30 ile, PostgreSQL 4.40 ile desteklenmeye baslar.

SQL Server provider desteklenir ancak bu modulde SQL Server Docker provisioning henuz acik degildir. Harici SQL Server kullanilabilir.

## Surum secimi

```bash
sudo bash installer/controllers/install.sh --version 4.30 --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version 4.60.3 --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version latest-4.80 --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version latest --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version beta --config /etc/nopcommerce-installer.env
```

`latest` stable surume gider. Prerelease otomatik secilmez.

## DB modu

Iki mod vardir:

- `external`: DB sunucusu zaten vardir. Secret dosyasinda tam connection string bulunur.
- `docker`: Installer MySQL veya PostgreSQL containerini olusturur, kalici volume baglar ve connection string'i kendisi uretir.

Varsayilan:

```text
NOP_DB_PROVIDER=web
NOP_DB_MODE=external
```

## External DB

MySQL ornegi:

```bash
sudo cp installer/config/database/mysql.secret.env.example /etc/nopcommerce-db.secret.env
sudo chmod 600 /etc/nopcommerce-db.secret.env
sudo nano /etc/nopcommerce-db.secret.env

sudo bash installer/controllers/install.sh \
  --version 4.90.8 \
  --db mysql \
  --db-mode external \
  --config /etc/nopcommerce-installer.env
```

External secret:

```bash
NOP_DB_CONNECTION_STRING='Server=127.0.0.1;Port=3306;Database=nopcommerce;User=nopcommerce;Password=CHANGE_ME'
```

SQL Server external olarak ayni sekilde kullanilir.

## Docker MySQL

Docker Engine hostta kurulu ve daemon erisilebilir olmalidir.

Secret olustur:

```bash
sudo cp installer/config/database/mysql-docker.secret.env.example /etc/nopcommerce-db.secret.env
sudo chown root:root /etc/nopcommerce-db.secret.env
sudo chmod 600 /etc/nopcommerce-db.secret.env
sudo nano /etc/nopcommerce-db.secret.env
```

Kur:

```bash
sudo bash installer/controllers/install.sh \
  --version 4.30 \
  --db mysql \
  --db-mode docker \
  --config /etc/nopcommerce-installer.env
```

Varsayilan Docker kaynaklari:

```text
image:     mysql:8.4
container: nopcommerce-mysql
volume:    nopcommerce-mysql-data
bind:      127.0.0.1:3306
```

Container sadece host loopback adresine publish edilir. Dis agdan DB portu acilmaz.

## Docker PostgreSQL

Secret olustur:

```bash
sudo cp installer/config/database/postgresql-docker.secret.env.example /etc/nopcommerce-db.secret.env
sudo chown root:root /etc/nopcommerce-db.secret.env
sudo chmod 600 /etc/nopcommerce-db.secret.env
sudo nano /etc/nopcommerce-db.secret.env
```

Kur:

```bash
sudo bash installer/controllers/install.sh \
  --version 4.90.8 \
  --db postgresql \
  --db-mode docker \
  --config /etc/nopcommerce-installer.env
```

Varsayilan Docker kaynaklari:

```text
image:     postgres:17
container: nopcommerce-postgresql
volume:    nopcommerce-postgresql-data
bind:      127.0.0.1:5432
```

## Docker provisioning davranisi

Installer:

1. Docker executable ve daemon erisimini kontrol eder.
2. DB secret dosyasini ve `chmod 600` kuralini kontrol eder.
3. Provider/surum uyumlulugunu kontrol eder.
4. Ilk kurulumda image'i ceker ve kalici named volume ile container olusturur.
5. Container daha once olusturulmussa silmez; non-secret config fingerprint ayniysa gerekiyorsa yeniden baslatir. Image/DB adi/kullanici/bind/port degismisse config drift hatasi verir.
6. MySQL icin kimlik dogrulamali `SELECT 1`, PostgreSQL icin `psql SELECT 1` ile gercek DB erisimini dogrular.
7. DB hazir olduktan sonra geriye uyumlu `App_Data/dataSettings.json` dosyasini yazar.
8. nopCommerce systemd servisini baslatir.

Docker image, port, DB adi, kullanici, container/volume prefix ve timeout degerleri `installer.env` ile degistirilebilir.

## Kalici veri ve parola degisikligi

Named volume veriyi installer tekrar calistiginda korur.

Mevcut volume ile secret dosyasindaki parolayi degistirmek veritabani icindeki kullanici parolasini otomatik degistirmez. Kimlik dogrulamali readiness sorgusu bu uyusmazligi hata olarak yakalar. Parola rotasyonu veritabani icinde ayrica uygulanmalidir.

Installer mevcut DB volume'unu otomatik silmez.

## Secret guvenligi

Secret dosyasi varsayilan olarak:

```text
/etc/nopcommerce-db.secret.env
```

Dosya group/world readable ise kurulum durur:

```bash
sudo chown root:root /etc/nopcommerce-db.secret.env
sudo chmod 600 /etc/nopcommerce-db.secret.env
```

Connection string ve parolalar installer tarafindan konsola yazdirilmaz.

Docker Engine'e root yetkisi olan kullanicilar container environment metadata'sina erisebilir. Docker modu host root guven modelini esas alir.

## dataSettings.json uyumlulugu

Installer geriye uyumlu formati uretir:

```json
{
  "DataConnectionString": "...",
  "DataProvider": "MySql"
}
```

4.30/4.40 bu formati dogrudan okuyabilir. Yeni nopCommerce surumleri eski `dataSettings.json` dosyasini yeni `DataConfig` yapisina migrate edebilir.

Provider isimleri:

- `SqlServer`
- `MySql`
- `PostgreSQL`

## Listeleme

```bash
bash installer/controllers/install.sh --list-versions
bash installer/controllers/install.sh --list-databases
```

## Mimari

```text
installer/
├── controllers/
│   └── install.sh
├── services/
│   └── install_service.sh
├── repositories/
│   ├── database_repository.sh
│   ├── release_repository.sh
│   └── version_repository.sh
├── tools/
│   ├── docker_database_tool.sh
│   ├── nginx_tool.sh
│   ├── os_tool.sh
│   └── systemd_tool.sh
├── views/
│   └── console_view.sh
├── language/
│   └── tr.labels
└── config/
    ├── database/
    │   ├── mysql.secret.env.example
    │   ├── mysql-docker.secret.env.example
    │   ├── postgresql.secret.env.example
    │   ├── postgresql-docker.secret.env.example
    │   └── sqlserver.secret.env.example
    ├── database-catalog.env
    ├── installer.env.example
    ├── version-catalog.env
    ├── nginx.conf.tpl
    └── nopcommerce.service.tpl
```

## Sinirlar

- SQL Server Docker provisioning henuz yoktur; external SQL Server desteklenir.
- Docker Engine kurulumu bu modulun sorumlulugunda degildir.
- Bu mekanizma database upgrade/migration zinciri degildir.
- TLS/Let's Encrypt ayri modul olarak eklenmelidir.
- Tum nopCommerce uygulamasini container olarak calistiran Docker deployment ayri bir moduldur.
- Eski .NET runtime'larinin modern OS uyumlulugu garanti edilmez.
