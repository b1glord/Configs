# Dosya Yolu: /OFBIZ/views/ARCHITECTURE.md
# Amac: OFBiz konfigurasyon araclarinin katmanli mimarisini ve sorumluluk sinirlarini dokumante eder
# View - Markdown
# Version: 1.1.0
# Aciklama: Controller, Service, Repo, Tool, View, Language ve Config akisini gelistirici icin aciklar
#
# Bagimli Oldugu Katman: View | Controller | Service | Repo | Tool | Language | Config

# OFBiz Configuration Architecture

## Katmanlar

~~~text
controllers/
    |
    v
services/
    |
    v
repositories/
    |
    v
tools/

views/
    |
    v
language/

config/
~~~

Controller sadece CLI istegini yonlendirir.

Service release, snapshot ve runtime is kurallarini koordine eder.

Repository yerel storage, metadata ve current symlink islemlerini yonetir.

Tool Git, Curl, Java, paket yoneticisi ve Gradle gibi dis dunya adaptorlerini icerir.

View yardim ve dokumantasyon ciktisini sunar.

Language kullaniciya gosterilen etiketleri merkezi olarak tutar.

Config release katalogu, snapshot katalogu, dis kaynaklar ve runtime path sabitlerini tutar.

## Kurulum modeli

Release hedefleri:

~~~text
/opt/ofbiz/releases/apache-ofbiz-24.09.07
/opt/ofbiz/releases/apache-ofbiz-18.12.19
~~~

Snapshot hedefleri:

~~~text
/opt/ofbiz/snapshots/apache-ofbiz-snapshot-trunk
/opt/ofbiz/snapshots/apache-ofbiz-snapshot-release24.09
/opt/ofbiz/snapshots/apache-ofbiz-snapshot-release22.01
~~~

JDK hedefleri:

~~~text
/opt/ofbiz/jdks/temurin-8
/opt/ofbiz/jdks/temurin-17
~~~

Aktif hedef:

~~~text
/opt/ofbiz/current
~~~

Her yeni kurulum dizininde .ofbiz-meta dosyasi bulunur. Runtime Service bu metadata ile release/snapshot turunu ve gerekli Java major surumunu belirler.

Release kurulumlari Apache ZIP paketlerinden gelir ve SHA-512 ile dogrulanir.

Snapshot kurulumlari Apache Git branch'lerinden gelir. snapshot update komutu ilgili branch'in son commit'ini getirir.

22.01 resmi release ZIP serisi olmadigi icin snapshot/branch modeliyle desteklenir.
