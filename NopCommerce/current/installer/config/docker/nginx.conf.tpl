# 📄 Dosya Yolu: /NopCommerce/current/installer/config/docker/nginx.conf.tpl
# 📌 Amac: Docker stack icindeki Nginx HTTP reverse proxy ve ACME challenge sablonunu tanimlamak
# 📌 Modul - Config
# Version: 1.2.0
# Aciklama: Compose app servisini proxy eder ve Let's Encrypt webroot challenge dosyalarini sunar
# Bagimli Oldugu Katman: Tool

server {
    listen 80;
    listen [::]:80;

    server_name __PUBLIC_HOST__;
    client_max_body_size 100m;

    location ^~ /.well-known/acme-challenge/ {
        root __ACME_WEBROOT__;
        default_type "text/plain";
        try_files $uri =404;
    }

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
