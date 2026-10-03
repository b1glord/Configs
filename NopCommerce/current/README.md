# 📄 Dosya Yolu: NopCommerce/current/README.md
# 📌 Amac: Guncel nopCommerce kurulum otomasyonunun hedefini ve kabul kriterlerini tanimlamak
# 📌 Modul - Markdown
# Version: 1.0.0
# Aciklama: Legacy scriptlerden bagimsiz yeni nesil installer icin baslangic noktasi

Bagimli Oldugu Katman: Tool

# Current Installer

Bu dizinde henuz production-ready kurulum scripti yoktur.

Duzenleme tarihinde resmi nopCommerce guncel surumu 4.90.8'dir. Yeni installer legacy scriptleri kopyalamak yerine sifirdan, guncel platform gereksinimlerine gore hazirlanmalidir.

## Hedefler

- Desteklenen nopCommerce 4.90.x surumu
- Desteklenen .NET runtime/SDK surumu
- Modern Linux dagitimlari
- Idempotent kurulum
- Nginx reverse proxy
- systemd service
- Environment/config ve secret ayrimi
- TLS hazirligi
- Log ve backup stratejisi
- Kurulum oncesi dependency validation
- Surum parametresi ile tekrar kullanilabilir yapi

Legacy referanslar `../legacy/installers/` altindadir.
