https://www.dynu.com/DynamicDNS/IPUpdateClient
## Install
```
cd /tmp
wget -nc https://raw.githubusercontent.com/b1glord/ispconfig_setup_extra/master/centos7/dynu/dynu.sh
chmod +x ./dynu.sh
./dynu.sh
```

## Commands
### Manage the service using systemd:
```
systemctl enable dynuiuc.service
systemctl start dynuiuc.service
systemctl restart dynuiuc.service
systemctl status dynuiuc.service
```

```
systemctl stop dynuiuc.service
```
### View live log: 
```tail -f /var/log/dynuiuc.log```

### View entire log file: 
```cat /var/log/dynuiuc.log```

### Truncate log file: 
```cat /dev/null > /var/log/dynuiuc.log```

### View service status: 
```systemctl status dynuiuc.service -l```
