#https://www.tekir.com.tr/indir/tekir-linux-kurulum/

read -p "Please enter your MySQL username: " username
if [[ -z "$username" ]]; then
        echo "ERROR: That username is invalid or you didn't enter a value."
        exit
        # If username is valid or field is not blank continue and ask for the password
elif [[ -n "$username" ]]; then
        read -sp "Please enter your MySQL Password: " password
fi

# This checks if the password is valid and the field is not blank.
# Also checks if the confirmation password is valid and not blank.
# Then checks and compares the two passwords.
# If one password is typed incorrectly it will error out.
if [[ -z "$password" ]]; then
        echo ""
        echo "ERROR: That password is invalid or you didn't enter a value."
        exit
        # Password is valid.
elif [[ -n "$password" ]]; then
        echo ""
        read -sp "Please re-enter your MySQL Password: " password2
        # Confirmation Password is invalid.
        if [[ -z "$password2" ]]; then
                echo ""
                echo "ERROR: The second password entered was invalid or you didn't enter a value."
                exit
        fi
fi
# Password comparing
if [[ -n "$password2" ]] && [[ "$password" == "$password2" ]]; then
        echo ""
        echo ""
        echo "Passwords match continuing..."
        echo ""
        read -p "Please provide us your hostname for MySQL (default is localhost): " hostname

        # Checks if Passwords do not match
elif [[ -n "$password2" ]] && [[ "$password" != "$password2" ]]; then
        echo ""
        echo ""
        echo "ERROR: Passwords do not match."
        exit
fi

# Ask what hostname this can be executed locally, but localhost is default.
if [[ -z "$hostname" ]]; then
        echo ""
        echo "ERROR: Please set a proper hostname such as localhost."
        exit
        # If hostname is not blank, we will continue.
elif [[ -n "$hostname" ]]; then
        read -p "Please enter your MySQL database: " database
fi

# If database field is blank, it will error out.
if [[ -z "$database" ]]; then
        echo ""
        echo "ERROR: The database name is invalid or blank."
        exit
fi

# Öncelikle 80 portunun açık olduğundan ve selinuxun kapalı olduğundan emin olun. 80 portu kapalıysa açmak için /etc/sysconfig/iptables dosyasına aşağıdaki satırı ekleyin:
setenforce 0
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT


yum -y install wget curl python3-pip expect
pip3 install wldhx.yadisk-direct



# JDK ( JAVA DEVELOPMENT KİT ) KURULUMU
cd /tmp
curl -L $(yadisk-direct https://yadi.sk/d/2z77P1RvleP5Lg) -o jdk-7u80-linux-x64.rpm
yum install -y jdk-7u80-linux-x64.rpm
rm -f jdk-7u80-linux-x64.rpm



# Daha sonra java ve alternatiflerinin kurulumu için aşağıdaki komutları çalıştırıyoruz:
alternatives --install /usr/bin/java java /usr/java/jdk1.7.0_71/bin/java 1
alternatives --install /usr/bin/javac javac /usr/java/jdk1.7.0_71/bin/javac 1
alternatives --install /usr/bin/jar jar /usr/java/jdk1.7.0_71/bin/jar 1
alternatives --install /usr/bin/javaws javaws /usr/java/jdk1.7.0_71/bin/javaws 1
alternatives --config java
#  Selection    Command
#-----------------------------------------------
#*+ 1           /usr/java/jdk1.7.0_71/bin/java


#Enter to keep the current selection[+], or type selection number: 1
#alternatives --set jar /usr/java/jdk1.7.0_71/bin/jar
#alternatives --set javac /usr/java/jdk1.7.0_71/bin/javac
#alternatives --set java /usr/java/jdk1.7.0_71/bin/java
#alternatives --set javaws /usr/java/jdk1.7.0_71/bin/javaws


# MYSQL KURULUMU
# https://www.percona.com/doc/percona-server/5.6/installation/yum_repo.html
yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
yum -y install Percona-Server-server-56 Percona-Server-client-56
service mysql start
chkconfig --levels 235 mysqld on
SECURE_MYSQL=$(expect -c "
set timeout 3
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"root password?\"
send \"y\r\"
expect \"New password:\"
send \"$password\r\"
expect \"Re-enter new password:\"
send \"$password\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")


#utf8 çalışmasını sağlama almak için /etc dizinindeki my.cnf dosyasında ilgili bölümlere şu satırları ekleyelim:
service mysql stop
rm -f /etc/my.cnf
wget https://raw.githubusercontent.com/b1glord/Configs/master/tekir/my.cnf -P /etc
service mysql start


cd /tmp
wget http://sourceforge.net/projects/jboss/files/JBoss/JBoss-4.2.3.GA/jboss-4.2.3.GA.zip
unzip jboss-4.2.3.GA.zip
mv jboss-4.2.3.GA /opt/tekir/
rm -f /tmp/jboss-4.2.3.GA.zip



#Çalışma ayarını yapmak için /opt/tekir/bin/run.conf dosyasındaki x$JAVA_OPTS parametrelerini tanımlayalım:
rm -f /opt/tekir/bin/run.conf
wget https://raw.githubusercontent.com/b1glord/Configs/master/tekir/run.conf -P /opt/tekir/bin



#Jboss için bir tekir kullanıcısı oluşturuyoruz
useradd -r tekir -d /opt/tekir
chown tekir: -R /opt/tekir

 
# Jbossu çalıştırıp kapatabilmek için opt/tekir/bin dizinindeki run.sh ve shutdown.sh dosyalarının çalıştırılabilir olması gerekir:
chmod +x /opt/tekir/bin/run.sh
chmod +x /opt/tekir/bin/shutdown.sh



# Jboss servisini kullanabilmek için /etc/init.d dizinine tekir adında bir servis dosyası oluşturun. Dosya içeriği aşağıdaki gibi olmalıdır:
wget https://raw.githubusercontent.com/b1glord/Configs/master/tekir/tekir -P /etc/init.d

#Tekir dosyasını çalıştırılabilir hale getirdikten sonra aşağıdaki komutları kullanarak servisi başlatıp durdurup ya da yeniden başlatabilirsiniz. 
#Jboss’un başlaması bir kaç dakika alabilir:

chmod +x /etc/init.d/tekir
service tekir start
#service tekir stop
#service tekir restart

#Jbossun sistem açılışında çalışması için aşağıdaki komutu veriyoruz:
chkconfig --levels 235 tekir on


cd /tmp
curl -L $(yadisk-direct https://yadi.sk/d/R-LTDlP1wJa1uQ) -o tekir-2.1-linux-install.tar.gz
tar -xvf tekir-2.1-linux-install.tar.gz
chown tekir:tekir -R /tmp/tekir-2.1-linux-install
rm -f tekir-2.1-linux-install.tar.gz



mysql -u root -p$password -e 'CREATE DATABASE '$database';'
mysql -u root -p$password -e "CREATE USER '$username'@'$hostname' IDENTIFIED BY '$password'"
mysql -u root -p$password -e 'GRANT ALL PRIVILEGES on '$database'.* to '$username'@'$hostname';'
mysql -u root -p$password -e 'FLUSH PRIVILEGES;'

mysql -u $username -p$password $database < /tmp/tekir-2.1-linux-install/tekir/tekir.sql



  cat > /tmp/tekir-2.1-linux-install/tekir/tekir-ds.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE datasources
    PUBLIC "-//JBoss//DTD JBOSS JCA Config 1.5//EN"
    "http://www.jboss.org/j2ee/dtd/jboss-ds_1_5.dtd">
    
<datasources>
   
   <local-tx-datasource>
      
      <jndi-name>tekirDatasource</jndi-name>
      <connection-url>jdbc:mysql://$hostname:3306/$database?characterEncoding=UTF-8</connection-url>
      <driver-class>com.mysql.jdbc.Driver</driver-class>
      <user-name>$username</user-name>
      <password>$password</password>
      
   </local-tx-datasource>
    
</datasources>
EOF


#TEKİR’İN JBOSS’A YÜKLENMESİ

#Tekir EAR dosyasını kopyalayın:
cp /tmp/tekir-2.1-linux-install/tekir/tekir.ear /opt/tekir/server/default/deploy

#Veritabanı bağlantı bilgisini kopyalayın:
cp /tmp/tekir-2.1-linux-install/tekir/tekir-ds.xml /opt/tekir/server/default/deploy

#E-posta bağlantı bilgisini kopyalayın:
cp /tmp/tekir-2.1-linux-install/tekir/tekir-mail-service.xml /opt/tekir/server/default/deploy

#Tekir ayar dosyasını kopyalayın:
cp /tmp/tekir-2.1-linux-install/tekir/tekir.properties /opt/tekir/server/default/conf

#MySQL JDBC sürücünü kopyalayın:
cp /tmp/tekir-2.1-linux-install/lib/mysql.jar /opt/tekir/server/default/lib

#Baskı şablonları ve kullanım sırasında yüklenecek olan dosyalar için klasörleri hazırlayın:
mkdir /var/tekir
mkdir /var/tekir/sablonlar
mkdir /var/tekir/dosyalar
cp -r /tmp/tekir-2.1-linux-install/tekir/sablonlar /var/tekir
chown tekir:tekir -R /var/tekir/
rm -rf /tmp/tekir-2.1-linux-install

#Jboss servisini yeniden başlatıyoruz:
service tekir restart

#Yukarıdaki işlemlerin sonucunda Tekir uygulama sunucusuna kurulmuş durumdadır. Denemek için metin tabanlı bir tarayıcıdan(Elinks) ip adresini girebilirsiniz. Elinks yüklemek için aşağıdaki komutu vermeniz yeterlidir. :
yum install -y elinks.x86_64

#Tarayıcıyı ile tekir uygulamasına gitmek için aşağıdaki komutu kulanabilirsiniz(ipadresi yerine sanal makinenizin IP adresini yazın). Tarayıcıdan çıkmak için ctrl+c tuşuna basmanız yeterli:
links 127.0.0.1:8080/tekir


