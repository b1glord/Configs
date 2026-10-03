# 📄 Dosya Yolu: /NopCommerce/current/installer/config/tls-renew.service.tpl
# 📌 Amac: Let's Encrypt sertifika renewal scriptini systemd ile calistirmak
# 📌 Modul - Config
# Version: 1.0.0
# Aciklama: Installer tarafindan uretilen renewal scriptini oneshot servis olarak cagirir
# Bagimli Oldugu Katman: Tool

[Unit]
Description=nopCommerce Let's Encrypt renewal
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=__RENEW_SCRIPT__
