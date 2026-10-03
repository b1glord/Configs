# 📄 Dosya Yolu: /NopCommerce/current/installer/config/docker/nginx.conf.tpl
# 📌 Amac: Docker stack icindeki Nginx reverse proxy virtual host sablonunu tanimlamak
# 📌 Modul - Config
# Version: 1.1.0
# Aciklama: Compose app servisini internal HTTP portu uzerinden proxy eder
# Bagimli Oldugu Katman: Tool

server {
    listen 80;
    listen [::]:80;

    server_name __PUBLIC_HOST__;
    client_max_body_size 100m;

    location / {
        proxy_pass http://__APP_SERVICE__:__APP_PORT__;
        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_connect_timeout 60s;
        proxy_send_timeout 120s;
        proxy_read_timeout 120s;
    }
}
