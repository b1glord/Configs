# 📄 Dosya Yolu: /Configs/nova.ai/openwebui/README.md
# 📌 Amac: Nova AI Open WebUI marka varliklarinin klasor eslemesini belgelemek
# 📌 View - Markdown
# Version: 1.0.0
# Aciklama: Branding ve upstream-original dizinlerinin rollerini ve hedef yollarini aciklar
# Bagimli Oldugu Katman: View

# Nova AI - Open WebUI Assets

Bu dizin iki farkli amaci ayirir: Nova markalamasi ve upstream referans dosyalari.

## branding

Nova AI icin ozellestirilmis dosyalar burada tutulur.

- `branding/backend-static/`: Backend static hedefi icin Nova favicon ve logo varliklari.
- `branding/build-root/`: Build root hedefi icin Nova favicon ve kullanici gorseli.
- `branding/build-static/`: Build static hedefi icin Nova favicon ve logo varliklari.

## upstream-original

Open WebUI tarafindan gelen orijinal dosyalar karsilastirma ve geri donus referansi olarak burada tutulur.

- `upstream-original/backend_static/`
- `upstream-original/build_root/`
- `upstream-original/build_static/`

Bu dizindeki dosyalar Nova branding dosyalariyla karistirilmamalidir.

## Guncelleme Akisi

1. Yeni Open WebUI surumunun orijinal varliklarini `upstream-original/` altinda yenile.
2. Orijinal dosyalar ile `branding/` dosyalarini karsilastir.
3. Gerekli Nova logo, favicon ve kullanici varliklarini guncelle.
4. Uygulama hedef yollarina kopyalama eslemesini kontrol et.
5. Degisiklikleri tek bir surumlu commit ile kaydet.
