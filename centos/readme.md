## centos 7
### hızlı hatırlama notlarım

#### Yardımcı site
```
https://ius.io/
```

```
https://www.softwarecollections.org/en/
```


#### İp adresi ögrenme
```
ip add
```

#### yum paket yöneticisinde paket arama
yum whatprovides can find package with specific command or lib, for example:
```
sudo yum whatprovides libmysqlclient*
```

#### ldconfig komutu
ldconfig loader tarafından kullanılan .so dosyalarını cache'lemek için kullanılır.
```
ldconfig
```

#### systemd servislerini yenileme
```
systemctl daemon-reload
```

#### Acık portlari kontrol etmek
```
netstat -plntu
```
```
netstat -tulpn | less
```
```
ss -tulpn | less
```
