# 📄 Dosya Yolu: /NopCommerce/current/installer/config/tls-renew.timer.tpl
# 📌 Amac: Let's Encrypt renewal servisini periyodik calistirmak
# 📌 Modul - Config
# Version: 1.0.0
# Aciklama: Gunde iki kez renewal kontrolu yapar ve rastgele gecikme uygular
# Bagimli Oldugu Katman: Tool

[Unit]
Description=nopCommerce Let's Encrypt renewal timer

[Timer]
OnCalendar=__ON_CALENDAR__
RandomizedDelaySec=__RANDOM_DELAY__
Persistent=true

[Install]
WantedBy=timers.target
