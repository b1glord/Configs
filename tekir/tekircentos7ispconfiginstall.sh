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

  cat > /etc/init.d/tekir << EOF
#!/bin/sh
#
# $Id: jboss_init_redhat.sh 71252 2008-03-25 17:52:00Z dbhole $
#
# JBoss Control Script
#
# To use this script run it as root - it will switch to the specified user
#
# Here is a little (and extremely primitive) startup/shutdown script
# for RedHat systems. It assumes that JBoss lives in /usr/local/jboss,
# it's run by user 'jboss' and JDK binaries are in /usr/local/jdk/bin.
# All this can be changed in the script itself. 
#
# Either modify this script for your requirements or just ensure that
# the following variables are set correctly before calling the script.
# chkconfig: - 64 36
# description: Jboss Start|Restart|Stop Application Server
# pidfile: /var/run/jboss.pid
#define where jboss is - this is the directory containing directories log, bin, conf etc
JBOSS_HOME=${JBOSS_HOME:-"/opt/tekir"}

#define the user under which jboss will run, or use 'RUNASIS' to run as the current user
JBOSS_USER=${JBOSS_USER:-"tekir"}

#make sure java is in your path
JAVAPTH=${JAVAPTH:-"/usr/java/default/bin"}

#configuration to use, usually one of 'minimal', 'default', 'all'
JBOSS_CONF=${JBOSS_CONF:-"default"}

#if JBOSS_HOST specified, use -b to bind jboss services to that address
JBOSS_HOST="127.0.0.1" 
JBOSS_BIND_ADDR=${JBOSS_HOST:+"-b $JBOSS_HOST"}

#define the script to use to start jboss
JBOSSSH=${JBOSSSH:-"$JBOSS_HOME/bin/run.sh -c $JBOSS_CONF $JBOSS_BIND_ADDR"}

if [ "$JBOSS_USER" = "RUNASIS" ]; then
  SUBIT="" 
else
  SUBIT="su -s /bin/bash - $JBOSS_USER -c " 
fi

if [ -n "$JBOSS_CONSOLE" -a ! -d "$JBOSS_CONSOLE" ]; then
  # ensure the file exists
  touch $JBOSS_CONSOLE
  if [ ! -z "$SUBIT" ]; then
    chown $JBOSS_USER $JBOSS_CONSOLE
  fi 
fi

if [ -n "$JBOSS_CONSOLE" -a ! -f "$JBOSS_CONSOLE" ]; then
  echo "WARNING: location for saving console log invalid: $JBOSS_CONSOLE" 
  echo "WARNING: ignoring it and using /dev/null" 
  JBOSS_CONSOLE="/dev/null" 
fi

#define what will be done with the console log
JBOSS_CONSOLE=${JBOSS_CONSOLE:-"/dev/null"}

JBOSS_CMD_START="cd $JBOSS_HOME/bin; $JBOSSSH" 

if [ -z "`echo $PATH | grep $JAVAPTH`" ]; then
  export PATH=$PATH:$JAVAPTH
fi

if [ ! -d "$JBOSS_HOME" ]; then
  echo JBOSS_HOME does not exist as a valid directory : $JBOSS_HOME
  exit 1
fi

echo JBOSS_CMD_START = $JBOSS_CMD_START

function procrunning() {
   procid=0
   JBOSSSCRIPT=$(echo $JBOSSSH | awk '{print $1}')
   for procid in `/sbin/pidof -x "$JBOSSSCRIPT"`; do
       ps -fp $procid | grep "${JBOSSSH% *}" > /dev/null && pid=$procid
   done
}

stop() {
    pid=0
    procrunning
    if [ $pid = '0' ]; then
        echo -n -e "\nNo JBossas is currently running\n" 
        exit 1
    fi

    RETVAL=1

    # If process is still running

    # First, try to kill it nicely
    for id in `ps --ppid $pid | awk '{print $1}' | grep -v "^PID$"`; do
       if [ -z "$SUBIT" ]; then
           kill -15 $id
       else
           $SUBIT "kill -15 $id" 
       fi
    done

    sleep=0
    while [ $sleep -lt 120 -a $RETVAL -eq 1 ]; do
        echo -n -e "\nwaiting for processes to stop";
        sleep 10
        sleep=`expr $sleep + 10`
        pid=0
        procrunning
        if [ $pid == '0' ]; then
            RETVAL=0
        fi
    done

    # Still not dead... kill it

    count=0
    pid=0
    procrunning

    if [ $RETVAL != 0 ] ; then
        echo -e "\nTimeout: Shutdown command was sent, but process is still running with PID $pid" 
        exit 1
    fi

    echo
    exit 0
}

case "$1" in
start)
    cd $JBOSS_HOME/bin
    if [ -z "$SUBIT" ]; then
        eval $JBOSS_CMD_START >${JBOSS_CONSOLE} 2>&1 &
    else
        $SUBIT "$JBOSS_CMD_START >${JBOSS_CONSOLE} 2>&1 &" 
    fi
    ;;
stop)
    stop
    ;;
restart)
    $0 stop
    $0 start
    ;;
*)
    echo "usage: $0 (start|stop|restart|help)" 
esac
EOF

chkconfig --levels 235 tekir on




cd /tmp
curl -L $(yadisk-direct https://yadi.sk/d/R-LTDlP1wJa1uQ) -o tekir-2.1-linux-install.tar.gz
tar -xvf tekir-2.1-linux-install.tar.gz
chown tekir:tekir -R /tmp/tekir-2.1-linux-install
rm -f tekir-2.1-linux-install.tar.gz



mysql -u root -p
mysql> CREATE DATABASE tekir collate utf8_turkish_ci;
CREATE USER 'tekir'@'127.0.0.1' IDENTIFIED BY 'ragnarok';
mysql> GRANT ALL PRIVILEGES ON tekir.* TO 'root'@'127.0.0.1';
mysql> FLUSH PRIVILEGES;
mysql> exit


mysql -u root -p ragnarok -h 127.0.0.1 -p tekir < /tmp/tekir-2.1-linux-install/tekir/tekir.sql

