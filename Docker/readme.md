## rAthena Auto Database Installer (Otomatik Database Yukleme)

### Kurulum ###

```
rm -f custom.sql
rm -f customaccount.sql
wget https://raw.githubusercontent.com/b1glord/ADI/master/customaccount.sql
wget https://raw.githubusercontent.com/b1glord/ADI/master/custom.sql

rm -f import-rathena-sql.sh
wget https://raw.githubusercontent.com/b1glord/Configs/refs/heads/master/Docker/import-sql.sh
chmod +x import-sql.sh
./import-sql.sh --re
```

```
# Renewal icin
SQL_MODE=minimal /opt/rathena/tools/import-sql.sh

# Renewal tam tablo seti (SQL DB modunda)
SQL_MODE=re /opt/rathena/tools/import-sql.sh --re

# Pre-renewal icin
SQL_MODE=pre /opt/rathena/tools/import-sql.sh --pre-re

# Minimal (main + logs)
SQL_MODE=pre /opt/rathena/tools/import-sql.sh --minimal
```

```

```
# rAthena Config 

### Config 1
```
cd /opt/rathena/rathena
rm -f ./dockerrathenaconfig.sh
wget -nc https://raw.githubusercontent.com/b1glord/Configs/refs/heads/master/Docker/dockerrathenaconfig.sh
chmod +x dockerrathenaconfig.sh
./dockerrathenaconfig.sh
```
