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
wget https://raw.githubusercontent.com/b1glord/Configs/refs/heads/master/Docker/import-rathena-sql.sh
chmod +x import-rathena-sql.sh

# 2) Varsayilan: minimal (main.sql + logs.sql)
./import-rathena-sql.sh

# 3) Renewal SQL DB kullanacaksan:
SQL_MODE=re ./import-rathena-sql.sh

# 4) Pre-renewal taban istersen:
SQL_MODE=pre ./import-rathena-sql.sh
```
