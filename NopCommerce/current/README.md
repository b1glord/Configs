# 📄 Dosya Yolu: /NopCommerce/current/README.md
# 📌 Amac: Cok surumlu nopCommerce Linux installer kullanimini, veritabani secimini ve destek matrisini tanimlamak
# 📌 Modul - Markdown
# Version: 1.4.0
# Aciklama: nopCommerce 4.30-4.90 stable ve acikca secilen 5.00 beta icin surum/runtime/DB uyumlu installer dokumani

Bagimli Oldugu Katman: Controller | Service | Repo | Tool | View | Language | Config

# Current Installer

Bu alan nopCommerce 4.30 ve sonrasi desteklenen Linux release paketlerini ayni installer mimarisi ile kurmak icin kullanilir.

## Desteklenen surum aileleri

| nopCommerce | Runtime | Veritabani |
| --- | --- | --- |
| 4.30 | .NET Core 3.1 | SQL Server, MySQL |
| 4.40 | .NET 5 | SQL Server, MySQL, PostgreSQL |
| 4.50.x | .NET 6 | SQL Server, MySQL, PostgreSQL |
| 4.60.x | .NET 7 | SQL Server, MySQL, PostgreSQL |
| 4.70.x | .NET 8 | SQL Server, MySQL, PostgreSQL |
| 4.80.x | .NET 9 | SQL Server, MySQL, PostgreSQL |
| 4.90.x | .NET 9 | SQL Server, MySQL, PostgreSQL |
| 5.00.0-beta | .NET 10 | SQL Server, MySQL, PostgreSQL |

MySQL nopCommerce 4.30 ile, PostgreSQL nopCommerce 4.40 ile desteklenmeye baslar.

## Surum secimi

```bash
sudo bash installer/controllers/install.sh --version 4.30 --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version 4.60.3 --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version latest-4.80 --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version latest --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version beta --config /etc/nopcommerce-installer.env
```

`latest` stable surume gider. Prerelease otomatik secilmez.

## Veritabani secimi

Varsayilan davranis `web` provideridir. Bu durumda installer veritabani bilgisi yazmaz ve nopCommerce ilk kurulum sihirbazi kullanilir.

```bash
sudo bash installer/controllers/install.sh \
  --version 4.90.8 \
  --db web \
  --config /etc/nopcommerce-installer.env
```

Otomatik DB config icin once secret dosyasini hazirla:

```bash
sudo cp installer/config/database/mysql.secret.env.example /etc/nopcommerce-db.secret.env
sudo chmod 600 /etc/nopcommerce-db.secret.env
sudo nano /etc/nopcommerce-db.secret.env
```

Sonra provideri sec:

```bash
sudo bash installer/controllers/install.sh \
  --version 4.90.8 \
  --db mysql \
  --config /etc/nopcommerce-installer.env
```

SQL Server:

```bash
sudo cp installer/config/database/sqlserver.secret.env.example /etc/nopcommerce-db.secret.env
sudo chmod 600 /etc/nopcommerce-db.secret.env

sudo bash installer/controllers/install.sh \
  --version 4.30 \
  --db sqlserver \
  --config /etc/nopcommerce-installer.env
```

PostgreSQL:

```bash
sudo cp installer/config/database/postgresql.secret.env.example /etc/nopcommerce-db.secret.env
sudo chmod 600 /etc/nopcommerce-db.secret.env

sudo bash installer/controllers/install.sh \
  --version 4.40 \
  --db postgresql \
  --config /etc/nopcommerce-installer.env
```

4.30 ile PostgreSQL secilirse installer kurulum baslamadan hata verir.

## Secret yapisi

Secret dosyasi repo icine commit edilmez. Varsayilan konum:

```text
/etc/nopcommerce-db.secret.env
```

Icerik tek secret degiskenidir:

```bash
NOP_DB_CONNECTION_STRING='...'
```

Dosya group veya world tarafindan okunabiliyorsa installer varsayilan olarak islemi durdurur. Tavsiye edilen izin:

```bash
sudo chown root:root /etc/nopcommerce-db.secret.env
sudo chmod 600 /etc/nopcommerce-db.secret.env
```

Connection string konsola yazdirilmaz.

## DB config uyumlulugu

Installer `App_Data/dataSettings.json` dosyasini geriye uyumlu sekilde uretir:

```json
{
  "DataConnectionString": "...",
  "DataProvider": "MySql"
}
```

4.30 ve 4.40 bu dosyayi dogrudan okuyabilir. Yeni nopCommerce surumleri eski `dataSettings.json` formatini okuyup yeni `DataConfig` yapisina tasiyabilir. Bu nedenle tek adapter eski ve yeni kurulumlarda kullanilir.

Provider isimleri nopCommerce'in bekledigi resmi enum isimleriyle yazilir:

- `SqlServer`
- `MySql`
- `PostgreSQL`

## Listeleme

```bash
bash installer/controllers/install.sh --list-versions
bash installer/controllers/install.sh --list-databases
```

## Runtime yonetimi

.NET runtime paketleri `/opt/dotnet` altinda side-by-side tutulur. Eski .NET runtime'lari modern Linux dagitimlarinda ek kutuphane veya eski OS gerektirebilir.

## Release dogrulamasi

- Release resmi GitHub API uzerinden dogrulanir.
- Linux x64 NoSource asset yoksa kurulum durur.
- SHA-256 digest varsa checksum kontrol edilir.
- Eski release kaydinda digest yoksa dosya boyutu kontrol edilir ve uyari verilir.

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
    │   ├── postgresql.secret.env.example
    │   └── sqlserver.secret.env.example
    ├── database-catalog.env
    ├── installer.env.example
    ├── version-catalog.env
    ├── nginx.conf.tpl
    └── nopcommerce.service.tpl
```

## Sinirlar

- DB provider ve connection config otomatiklestirildi; veritabani sunucusunun kendisi henuz provisioning edilmez.
- Bu mekanizma database upgrade/migration zinciri degildir.
- TLS/Let's Encrypt ayri modul olarak eklenmelidir.
- Docker deployment ayri modul olarak eklenmelidir.
- Eski .NET runtime'larinin modern OS uyumlulugu garanti edilmez.
