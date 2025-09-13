```
docker cp .env rathena:/opt/rathena/.env
docker exec -it rathana bash
```


```
git clone https://github.com/b1glord/rathena.git /opt/rathena

cd /opt/rathena
git remote -v

git remote add upstream https://github.com/rathena/rathena.git

git remote -v
git pull upstream master
```

```
## rAthena Auto Database Installer (Otomatik Database Yukleme)
### Kurulum ###

cd /opt/rathena/sql-files

rm -f custom.sql
rm -f customaccount.sql
wget https://raw.githubusercontent.com/b1glord/ADI/master/customaccount.sql
wget https://raw.githubusercontent.com/b1glord/ADI/master/custom.sql

rm -f import-sql.sh
wget https://raw.githubusercontent.com/b1glord/Configs/refs/heads/master/Docker/import-sql.sh

set -a; . /opt/rathena/.env; set +a
echo "SQL_DIR=$SQL_DIR"

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
cd /opt/rathena/
rm -f ./dockerrathenaconfig.sh
wget -nc https://raw.githubusercontent.com/b1glord/Configs/refs/heads/master/Docker/dockerrathenaconfig.sh
chmod +x dockerrathenaconfig.sh
./dockerrathenaconfig.sh
```

```
github.com/rathena/rathena/wiki/Install-on-Ubuntu/

./configure 
make clean && make server
```
