# 📄 Dosya Yolu: /NopCommerce/current/README.md
# 📌 Amac: Cok surumlu nopCommerce Linux installer kullanimini ve destek matrisini tanimlamak
# 📌 Modul - Markdown
# Version: 1.2.0
# Aciklama: nopCommerce 4.30-4.90 stable surumleri icin katmanli installer dokumani

Bagimli Oldugu Katman: Controller | Service | Repo | Tool | View | Language | Config

# Current Installer

Bu alan nopCommerce 4.30 ve sonrasi stable Linux release paketlerini ayni installer mimarisi ile kurmak icin kullanilir.

## Desteklenen surum aileleri

| nopCommerce | Runtime |
| --- | --- |
| 4.30 | .NET Core 3.1 |
| 4.40 | .NET 5 |
| 4.50.x | .NET 6 |
| 4.60.x | .NET 7 |
| 4.70.x | .NET 8 |
| 4.80.x | .NET 9 |
| 4.90.x | .NET 9 |

Runtime eslestirmeleri nopCommerce resmi sistem gereksinimleri ile uyumludur.

## Surum secimi

Temel surum:

```bash
sudo bash installer/controllers/install.sh --version 4.30 --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version 4.50 --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version 4.90 --config /etc/nopcommerce-installer.env
```

Belirli patch surumu:

```bash
sudo bash installer/controllers/install.sh --version 4.60.3 --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version 4.80.9 --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version 4.90.8 --config /etc/nopcommerce-installer.env
```

Bir surum ailesinin son bilinen stable patch'i:

```bash
sudo bash installer/controllers/install.sh --version latest-4.60 --config /etc/nopcommerce-installer.env
sudo bash installer/controllers/install.sh --version latest-4.80 --config /etc/nopcommerce-installer.env
```

Genel son stable profil:

```bash
sudo bash installer/controllers/install.sh --version latest --config /etc/nopcommerce-installer.env
```

Secenekleri listelemek icin root yetkisi gerekmez:

```bash
bash installer/controllers/install.sh --list-versions
```

## Alias davranisi

- `4.30` -> 4.30
- `4.40` -> 4.40
- `4.50` -> 4.50.0
- `4.60` -> 4.60.0
- `4.70` -> 4.70.0
- `4.80` -> 4.80.0
- `4.90` -> 4.90.0
- `latest-4.40` -> 4.40.4
- `latest-4.50` -> 4.50.4
- `latest-4.60` -> 4.60.6
- `latest-4.70` -> 4.70.5
- `latest-4.80` -> 4.80.9
- `latest-4.90` -> 4.90.8
- `latest` -> 4.90.8

Tam patch surumleri alias katalogunda bulunmak zorunda degildir. Ornegin `4.60.2` verildiginde installer GitHub release metadata uzerinden paketin gercekten var oldugunu kontrol eder.

## Runtime yonetimi

.NET runtime paketleri sistem apt deposuna tek bir major surum olarak sabitlenmez. Installer Microsoft `dotnet-install.sh` mekanizmasini kullanarak runtime'lari `/opt/dotnet` altinda side-by-side tutar.

Bu sayede farkli nopCommerce surumlerinin gerektirdigi runtime'lar ayni host uzerinde bulunabilir.

Eski .NET runtime'lari artik modern Linux dagitimlarinin tum kutuphane kombinasyonlari ile uyumlu olmayabilir. Ozellikle 4.30 ve 4.40 gibi eski nopCommerce surumleri icin kurulum yapilabilse bile uygulama runtime uyumlulugu hedef sunucuda test edilmelidir.

## Release dogrulamasi

Installer once resmi GitHub release API kaydini okur.

- Release yoksa kurulum durur.
- Linux x64 NoSource asset yoksa kurulum durur.
- GitHub SHA-256 digest yayinlamissa cryptographic checksum kontrol edilir.
- Eski release kaydinda digest yoksa dosya boyutu kontrol edilir ve acik uyari verilir.
- `NOP_ALLOW_LEGACY_WITHOUT_SHA256=0` yapilirsa digest olmayan eski release paketleri reddedilir.

## Mimari

```text
installer/
├── controllers/
│   └── install.sh
├── services/
│   └── install_service.sh
├── repositories/
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
    ├── installer.env.example
    ├── version-catalog.env
    ├── nginx.conf.tpl
    └── nopcommerce.service.tpl
```

Controller sadece istegi Service katmanina iletir. Surum ve release bilgisi Repository katmaninda cozulur. OS, runtime, Nginx ve systemd entegrasyonlari Tool katmanindadir. Konsol ciktilari View, metinler Language katmanindadir.

## Config

```bash
cp installer/config/installer.env.example /etc/nopcommerce-installer.env
sudo nano /etc/nopcommerce-installer.env
```

Eski kullanim sekli de korunur. Surum verilmezse `NOP_DEFAULT_VERSION` kullanilir:

```bash
sudo bash installer/controllers/install.sh /etc/nopcommerce-installer.env
```

## Veritabani notlari

- MySQL destegi nopCommerce 4.30 ile baslar.
- PostgreSQL destegi nopCommerce 4.40 ile baslar.
- Bu installer halen veritabani provisioning yapmaz.
- Farkli nopCommerce surumlerini ayni veritabanina sirayla baglamak upgrade islemi degildir ve veri kaybina yol acabilir.

## Sinirlar

- Bu mekanizma yeni kurulum/deployment icindir; otomatik database upgrade sistemi degildir.
- TLS/Let's Encrypt henuz ayri modul olarak eklenmemistir.
- Docker deployment henuz ayri modul olarak eklenmemistir.
- Eski .NET runtime'larinin modern OS uyumlulugu garanti edilmez.
