# 📄 Dosya Yolu: /NopCommerce/current/README.md
# 📌 Amac: Guncel nopCommerce kurulum otomasyonunun kullanimini ve destek matrisini tanimlamak
# 📌 Modul - Markdown
# Version: 1.1.0
# Aciklama: nopCommerce 4.90.x icin katmanli Linux installer dokumani

Bagimli Oldugu Katman: Controller | Service | Repo | Tool | Config | Language

# Current Installer

Bu alan nopCommerce icin guncel kurulum otomasyonunu barindirir.

## Dogrulanan hedef

- nopCommerce: 4.90.8
- .NET: 9.0
- Paket: NoSource Linux x64
- Isletim sistemi: Ubuntu ve Debian
- Reverse proxy: Nginx
- Servis yonetimi: systemd
- Uygulama portu: sadece localhost uzerinden 5000
- Paket butunlugu: SHA-256 kontrolu

Resmi nopCommerce 4.90.8 kaynak agacinda global.json .NET SDK 9.0.100 kullanir ve resmi Dockerfile ASP.NET 9.0 runtime tabanlidir.

## Mimari

```text
installer/
├── controllers/
│   └── install.sh
├── services/
│   └── install_service.sh
├── repositories/
│   └── release_repository.sh
├── tools/
│   ├── nginx_tool.sh
│   ├── os_tool.sh
│   └── systemd_tool.sh
├── config/
│   ├── installer.env.example
│   ├── nginx.conf.tpl
│   └── nopcommerce.service.tpl
└── language/
    └── tr.labels
```

Controller sadece girdiyi Service katmanina aktarir. Kurulum akisi Service icindedir. Release indirme ve disk yerlesimi Repository katmanindadir. OS, Nginx ve systemd islemleri Tool katmanlarindadir.

## Kurulum

Ornek konfigurasyonu sunucuya kopyalayip degerleri kontrol et:

```bash
cp installer/config/installer.env.example /etc/nopcommerce-installer.env
sudo nano /etc/nopcommerce-installer.env
```

Kurulumu calistir:

```bash
sudo bash installer/controllers/install.sh /etc/nopcommerce-installer.env
```

Kurulum tamamlandiktan sonra tarayicidan `NOP_PUBLIC_HOST` degerine git. Ilk nopCommerce kurulum sihirbazinda veritabani baglantisini tamamla.

## Veritabani

Bu installer veritabani sunucusunu otomatik kurmaz. Bunun nedeni uygulama kurulumu ile kalici veri katmanini birbirinden ayirmaktir.

nopCommerce 4.90.8 resmi deposunda MySQL ve PostgreSQL icin Docker Compose ornekleri bulunur. Harici SQL Server, MySQL veya PostgreSQL kullanimi deployment politikasina gore ayrica yapilandirilabilir.

## Idempotency

Ayni surum daha once acilmissa release klasoru tekrar acilmaz. Systemd ve Nginx konfigurasyonlari yeniden uretilir ve servisler yeniden yuklenir.

## Sinirlar

- Otomatik upgrade/migration bu surumde yoktur.
- TLS/Let's Encrypt bu surumde yoktur.
- Docker deployment bu surumde yoktur.
- Veritabani provisioning bu surumde yoktur.

Bu uc alan sonraki minor surumlerde ayri moduller olarak eklenmelidir.
