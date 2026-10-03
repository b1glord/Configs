# 📄 Dosya Yolu: /Configs/nova.ai/README.md
# 📌 Amac: Nova AI ile ilgili saklanan konfigurasyon ve marka varliklarini tanimlamak
# 📌 View - Markdown
# Version: 1.0.1
# Aciklama: Nova AI arsivinin klasor yapisini, kapsamini ve kullanim amacini belgeler
# Bagimli Oldugu Katman: View

# Nova AI Config Archive

Bu klasor, eski `b1glord/nova.ai` deposundan Configs reposuna aktarilan Nova AI dosyalarini saklar.

## Kapsam

- `openwebui/branding/`: Nova icin kullanilan ozellestirilmis Open WebUI marka varliklari.
- `openwebui/upstream-original/`: Karsilastirma ve geri donus icin saklanan orijinal Open WebUI varliklari.
- `openwebui/README.md`: Open WebUI alt yapisinin klasor ve kullanim aciklamasi.

## Kurallar

1. `branding/` altindaki dosyalar Nova ozellestirmeleridir.
2. `upstream-original/` altindaki dosyalar referans kopyadir; Nova markalamasi olarak kullanilmaz.
3. Kaynak uygulamanin gercek hedef dizinlerini gosteren `backend-static`, `backend_static`, `build-root`, `build_root` ve `build-static` adlari bilerek korunmustur.
4. Yeni Open WebUI surumlerinde dosyalar degisirse once upstream kopya guncellenmeli, sonra Nova branding farklari kontrol edilmelidir.

## Kaynak

Aktarim kaynagi: `b1glord/nova.ai`

Bu klasor artik Configs icindeki merkezi arsiv konumudur.
