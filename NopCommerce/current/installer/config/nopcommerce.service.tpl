# 📄 Dosya Yolu: /NopCommerce/current/installer/config/nopcommerce.service.tpl
# 📌 Amac: nopCommerce systemd service unit sablonunu tanimlamak
# 📌 Modul - Config
# Version: 1.0.1
# Aciklama: Runtime path, kullanici ve ASP.NET URL degerleri Tool katmani tarafindan doldurulur
# Bagimli Oldugu Katman: Tool

[Unit]
Description=nopCommerce service
After=network-online.target
Wants=network-online.target

[Service]
WorkingDirectory=__APP_DIR__
ExecStart=__DOTNET_EXECUTABLE__ __APP_DIR__/Nop.Web.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=__SERVICE_NAME__
User=__SERVICE_USER__
Group=__SERVICE_GROUP__
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=ASPNETCORE_URLS=__ASPNETCORE_URLS__
Environment=DOTNET_NOLOGO=true
NoNewPrivileges=true
PrivateTmp=true
UMask=0002

[Install]
WantedBy=multi-user.target
