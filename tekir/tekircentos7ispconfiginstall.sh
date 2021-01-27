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
  Selection    Command
-----------------------------------------------
*+ 1           /usr/java/jdk1.7.0_71/bin/java

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
chkconfig --levels 235 mysql on
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

echo "" > /etc/my.cnf
echo "[mysqld]" > /etc/my.cnf
echo "character_set_server=utf8" > /etc/my.cnf
echo "character_set_client=utf8" > /etc/my.cnf
echo "skip-name-resolve" > /etc/my.cnf
echo "[client]" > /etc/my.cnf
echo "default-character-set=utf8" > /etc/my.cnf
echo "[mysql]" > /etc/my.cnf
echo "default-character-set=utf8" > /etc/my.cnf



cd /tmp
wget http://sourceforge.net/projects/jboss/files/JBoss/JBoss-4.2.3.GA/jboss-4.2.3.GA.zip
unzip jboss-4.2.3.GA.zip
mv jboss-4.2.3.GA /opt/tekir/
rm -f /tmp/jboss-4.2.3.GA.zip



#Çalışma ayarını yapmak için /opt/tekir/bin/run.conf dosyasındaki x$JAVA_OPTS parametrelerini tanımlayalım:


echo " if [ "x$JAVA_OPTS" = "x" ]; then" > /opt/tekir/bin/run.conf
echo "  JAVA_OPTS="-Xms1024m -Xmx1024m -XX:MaxPermSize=1024m" > /opt/tekir/bin/run.conf
echo "  -Dsun.rmi.dgc.client.gcInterval=3600000" > /opt/tekir/bin/run.conf
echo "	-Dsun.rmi.dgc.server.gcInterval=3600000" > /opt/tekir/bin/run.conf
echo "  -Duser.language=en -Duser.country=US"" " > /opt/tekir/bin/run.conf
echo " fi" > /opt/tekir/bin/run.conf


#Jboss için bir tekir kullanıcısı oluşturuyoruz
useradd -r tekir -d /opt/tekir
chown tekir: -R /opt/tekir

 
# Jbossu çalıştırıp kapatabilmek için opt/tekir/bin dizinindeki run.sh ve shutdown.sh dosyalarının çalıştırılabilir olması gerekir:
chmod +x /opt/tekir/bin/run.sh
chmod +x /opt/tekir/bin/shutdown.sh



# Jboss servisini kullanabilmek için /etc/init.d dizinine tekir adında bir servis dosyası oluşturun. Dosya içeriği aşağıdaki gibi olmalıdır:
wget https://raw.githubusercontent.com/b1glord/Configs/master/tekir/tekir -P /etc/init.d/tekir
chkconfig --levels 235 tekir on



cd /tmp
curl -L $(yadisk-direct https://yadi.sk/d/R-LTDlP1wJa1uQ) -o tekir-2.1-linux-install.tar.gz
tar -xvf tekir-2.1-linux-install.tar.gz
chown tekir:tekir -R /tmp/tekir-2.1-linux-install
rm -f tekir-2.1-linux-install.tar.gz



mysql -u root -p
mysql> CREATE DATABASE $database collate utf8_turkish_ci;
CREATE USER '$username'@'$hostname' IDENTIFIED BY '$database';
mysql> GRANT ALL PRIVILEGES ON $username.* TO 'root'@'$hostname';
mysql> FLUSH PRIVILEGES;
mysql> exit


mysql -u root -p $password -h $hostname -p $database < /tmp/tekir-2.1-linux-install/tekir/tekir.sql

