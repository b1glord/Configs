https://www.dynu.com/en-US/Resources/Downloads
## Install
```
cd /tmp
wget -nc https://raw.githubusercontent.com/b1glord/Configs/e66cc5baaa98b5bac5138adb0e57a2fb12f697fa/centos/dynu/dynu.sh?token=ABWFSSCBD42M3A4CI6GAFXDBI6LZA
chmod 755 ./dynu.sh
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
