## rAthena Auto Database Installer (Otomatik Database Yukleme)

### Kurulum ###
#ADI.sh isimli dosyayi rAthena sql-files dizinine kopyaliyoruz
```
cd ~/rAthena/sql-files
rm -f ~/rAthena/sql-files/ADI.sh
rm -f ~/rAthena/sql-files/custom.sql
rm -f ~/rAthena/sql-files/customaccount.sql

wget https://raw.githubusercontent.com/b1glord/ADI/master/customaccount.sql
wget https://raw.githubusercontent.com/b1glord/ADI/master/custom.sql
wget https://raw.githubusercontent.com/b1glord/ADI/master/ADI.sh
chmod +x ADI.sh
./ADI.sh
```

```
rm -f custom.sql
rm -f customaccount.sql
wget https://raw.githubusercontent.com/b1glord/ADI/master/customaccount.sql
wget https://raw.githubusercontent.com/b1glord/ADI/master/custom.sql

rm -f import-rathena-sql.sh
wget https://raw.githubusercontent.com/b1glord/Configs/refs/heads/master/Docker/import-sql.sh
chmod +x import-sql.sh
SQL_MODE=re import-sql.sh
```

```
# Minimal (main + logs)
SQL_MODE=minimal /opt/rathena/tools/import-sql.sh

# Renewal tam tablo seti (SQL DB modunda)
SQL_MODE=re /opt/rathena/tools/import-sql.sh

# Pre-renewal icin
SQL_MODE=pre /opt/rathena/tools/import-sql.sh
```
