# ref url https://www.tekir.com.tr/indir/tekir-linux-kurulum/
# Tekir’i kurarken aşağıdaki uygulamaları kuracağız

# Java : Sun-JDK 7
# Veritabanı Sunucusu : Percona Mysql 5.6
# Uygulama Sunucusu : JBoss AS 4.2.3.GA (RedHat)
# Web Sunucusu : Nginx 1.8.0

cd /tmp
wget -c --no-check-certificate --no-cookies --header 'Cookie: oraclelicense=accept-securebackup-cookie' http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.rpm -O jdk-7u71-linux-x64.rpm
yum install -y jdk-7u71-linux-x64.rpm
rm -f jdk-7u71-linux-x64.rpm
