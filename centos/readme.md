## centos 7
### hızlı hatırlama notlarım

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

####systemd servislerini yenileme
```
systemctl daemon-reload
```
