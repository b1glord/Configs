https://www.dynu.com/en-US/Resources/Downloads
## Install
```
cd /tmp
wget -nc https://raw.githubusercontent.com/b1glord/Configs/master/centos/dynu/dynu.sh
chmod a+x ./dynu.sh
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
