# 📄 Dosya Yolu: NopCommerce/README.md
# 📌 Amac: NopCommerce kurulum, nginx konfigurasyon ve legacy dosyalarinin duzenli envanterini tutmak
# 📌 Modul - Markdown
# Version: 2.0.0
# Aciklama: NopCommerce klasor yapisi, surum durumu ve kullanim sinirlarini dokumante eder

Bagimli Oldugu Katman: Tool

# NopCommerce Configs

Bu klasor nopCommerce icin daha once hazirlanmis kurulum scriptlerini, nginx ayarlarini ve yardimci varliklari saklar.

## Surum durumu

- Resmi nopCommerce guncel surumu, bu duzenleme tarihinde: 4.90.8
- Bu repodaki mevcut kurulum scriptleri: 4.30, 4.40, 4.50 ve 4.60
- Bu nedenle mevcut kurulum scriptleri `legacy` olarak siniflandirilmistir.
- Legacy scriptler yeni bir sunucuda dogrudan production kurulumu icin onerilmez.
- Yeni nesil kurulum calismalari `current/` altinda tutulacaktir.

## Klasor yapisi

```text
NopCommerce/
├── README.md
├── current/
│   └── README.md
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
- `config/nginx/timeout.conf`: Uzun proxy timeout degerleri.
- `archive/notes/nginxsecurity.sh`: Eski guvenlik notlari. Calistirilabilir script olarak kabul edilmemelidir.

## Arsiv

- `.old` ve `.bak` dosyalari `archive/backups/` altina tasinmistir.
- Eski tema ZIP dosyasi `assets/themes/` altina tasinmistir.
- Eski ekran goruntuleri `assets/images/` altinda korunmustur.

## Guvenlik notu

Legacy scriptlerde eski CentOS, .NET Core, MariaDB ve servis varsayimlari bulunabilir. Production ortaminda kullanmadan once surum, paket kaynagi, servis kullanicisi, dosya izinleri, firewall, TLS ve secret yonetimi yeniden gozden gecirilmelidir.

## Sonraki hedef

Yeni kurulum scripti ayri olarak gelistirilmeli ve nopCommerce 4.90.x, desteklenen .NET surumu, modern Linux dagitimlari, idempotent kurulum, systemd, Nginx ve secret/config ayrimini desteklemelidir.
