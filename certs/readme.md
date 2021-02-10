# Openssl ile kendi sertifikanızı oluşturun

## openssl
### Öncelikle Openssl windows versiyon indirilir.

```
https://sourceforge.net/projects/openssl/
```

### Sonra indirilen sıkıştırılmış dosya açılır. Açılan klasörün içindeki “bin” klasörüne Komut istemcisi(Yönetici Modunda) ile gidilir.

### Sonrasında aşağıdaki örnek komutlar ile kendi sertifikanızı oluşturabilirsiniz.
```
openssl req -new -newkey rsa:4096 -nodes -keyout burakcert.key -out burakcert.csr
```

```
openssl x509 -req -days 365 -in burakcert.csr -signkey burakcert.key -out burakcert.cer
```

```
openssl pkcs12 -export -in burakcert.cer -inkey burakcert.key -out burakcert.pfx
```

##### Not: “365” sertifikanın süresini belirtmektedir.

##### Sonrasında; .cer, .pfx formatında sertifika dosyalarını elde edeceksiniz.
