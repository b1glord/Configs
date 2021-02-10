# Openssl ile kendi sertifikanızı oluşturun

## openssl
### Öncelikle Openssl windows versiyon indirilir.

```
https://sourceforge.net/projects/openssl/
```

### Sonra indirilen sıkıştırılmış dosya açılır. Açılan klasörün içindeki “bin” klasörüne Komut istemcisi(Yönetici Modunda) ile gidilir.

### Sonrasında aşağıdaki örnek komutlar ile kendi sertifikanızı oluşturabilirsiniz.
```
openssl req -new -newkey rsa:2048 -nodes -keyout orbilisim.net.key -out orbilisim.net.csr
```

```
openssl x509 -req -days 365 -in orbilisim.net.csr -signkey orbilisim.net.key -out orbilisim.net.cer
```

```
openssl pkcs12 -export -in orbilisim.net.cer -inkey orbilisim.net.key -out orbilisim.net.pfx
```
#### Not: “365” sertifikanın süresini belirtmektedir.

#### Sonrasında; .cer, .pfx formatında sertifika dosyalarını elde edeceksiniz.
