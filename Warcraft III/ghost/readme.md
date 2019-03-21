## GhostOne Temel Ayarlar

GhostOne++ Warcraft III oyununa gerek duymadan sunucuya baglanti kurup port acmadan oyun kurmanızı saglayan bir yazılımdır.

Temel ayarlar Default.cfg icerisindedir. 

Ek komut eklememiz gerektiginde bunu ghost.cfg ye ekleyerek kolayca yapabiliyoruz Ghost.exe Ghost.cfg yi otomatik olarak okur ek ayar gerektirmez.

Sunucu baglatısı icin asagidaki degerlerin dogru olarak girilmesi gerekiyor (ghost.cfg ye ekleyerek)

exeversionhash exeversion gibi degerleri BNCSutil.dll otomatik bulmasi gerekiyor aslında ama uyumluluk nedenlerinden duzgun calısmıyor bu yuzden elle girmek gerekiyor

GHost hashes
1.28.5

* bnet_custom_war3version = 28
* bnet_custom_exeversion = 0 5 28 1
* bnet_custom_exeversionhash = 201 63 116 96  
* bnet_custom_passwordhashtype = pvpgn

1.26a

* bnet_custom_war3version = 26
* bnet_custom_exeversion = 1 0 26 1
* bnet_custom_exeversionhash = 39 240 218 47
* bnet_custom_passwordhashtype = pvpgn

## GhostOne Map Ayarlar
### Mapscfgs

Her map icin ornek dota yada td icin \mapcfgs klasorune ozel bir config olusturmak gerekiyor.

Oyuna girdikten sonra ornek : \mapcfgs dota.cfg dosyasi olusturalim 

!map dota komutu ile ghost a hangi haritayi host edecegini belirmemiz gerekiyor.

Komutu girmedigimiz zaman bug oluyor bot harita secmeden oyun kuruyor

Oyunucunun Haritayi indirecegi Konum bilgisi asagidaki komut ile ayarlaniyor

* map_path = Maps\Download\DotA v6.85k Allstars.w3x       

Bot Klasorundeki Maps Klasorundeki Harita ismidir.(Antihack icin gereklidir.)

* map_localpath = DotA v6.85k Allstars.w3x 

### Maps

Tüm haritalari Maps Klasorune atmak yeterlidir.Klasor olusturmaya gerek yok.
