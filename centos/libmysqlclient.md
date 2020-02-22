### libmysqlclient.so konumu devamlı degistigi icin derleme yaparken sorunlar oluyor
#### Son Buldugum orjinal konumu burası
```
/usr/lib64/mysql/libmysqlclient.so
```


#### Sorunu cozmek icin gerekli konuma kısayol ekliyoruz

```
cd /usr/lib64/mysql/
ln -s /usr/lib64/mysql/libmysqlclient.so /usr/lib/libmysqlclient.so
```