# 📄 Dosya Yolu: /NopCommerce/current/installer/config/docker/nginx.tls.conf.tpl
# 📌 Amac: Docker stack Nginx icin HTTPS + HTTP redirect sablonunu tanimlamak
# 📌 Modul - Config
# Version: 1.0.0
# Aciklama: Container icindeki Let's Encrypt sertifikalari ile app servisini HTTPS uzerinden proxy eder
# Bagimli Oldugu Katman: Tool

server {
    listen 80;
    listen [::]:80;

    server_name __PUBLIC_HOST__;

    location ^~ /.well-known/acme-challenge/ {
        root __ACME_WEBROOT__;
        default_type "text/plain";
        try_files $uri =404;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name __PUBLIC_HOST__;
    client_max_body_size 100m;

    ssl_certificate __TLS_FULLCHAIN__;
    ssl_certificate_key __TLS_PRIVKEY__;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;

    add_header Strict-Transport-Security "max-age=31536000" always;

    location / {
        proxy_pass http://__APP_SERVICE__:__APP_PORT__;
        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;

        proxy_connect_timeout 60s;
        proxy_send_timeout 120s;
        proxy_read_timeout 120s;
    }
}
