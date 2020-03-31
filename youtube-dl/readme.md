# Youtube-dl Centos 7 Kurulum ve Bagımlılıklar
## https://github.com/ytdl-org/youtube-dl
### Centos 7 Kurulum
```
yum install -y epel-release youtube-dl
```
#### Youtube-dl Update
```
youtube-dl -U
```
#### Centos 7 Kullanım Ornekleri

- Videoyu mp3 formatına çevirmek için oldukça basit olan şu işlemi yapıyorsunuz.
```
youtube-dl --extract-audio --audio-format mp3 https://www.youtube.com/watch?v=PMxn3LaFVEE
```

- Yapmış olduğunuz bir playlisti indirip otomatik olarak aşağıdaki komutu kullanarak kolay bir şekilde mp3 çevirebilirsiniz.
```
youtube-dl -cit --extract-audio --audio-format mp3 https://www.youtube.com/watch?v=pVLmZMjxfjw&list=RDpVLmZMjxfjw
```

```
youtube-dl --extract-audio --audio-format mp3

```



youtube-dl -o '/Output/qpgTC9MDx1o.mp3' qpgTC9MDx1o -f bestaudio --extract-audio --metadata-from-title "%(artist)s - %(title)s" 2>&1
