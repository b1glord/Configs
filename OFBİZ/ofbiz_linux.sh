# If sitename field is blank, it will error out.(test)
read -p "Please enter your website name (ornek xxx.com): " website
if [[ -z "$website" ]]; then
        echo "ERROR: The website name is invalid or blank."
        exit
fi
# apache ofbiz 
# java 8 ile çalışıyor üst sürümlere uyumlu degil
cd /tmp
wget https://raw.githubusercontent.com/b1glord/Configs/master/OFBİZ/install_oraclejdk8.sh
chmod +x install_oraclejdk8.sh
./install_oraclejdk8.sh

# == Install Required programs
yum -y install perl-Digest-SHA

# == Quick start
# == Ref Documantation
# https://cwiki.apache.org/confluence/display/OFBIZ/How+to+install+OFBiz+with+the+Demo+Data
# === Download the Gradle wrapper:
# rm -f -r /usr/local/ofbiz    //need delete all files
mkdir /usr/local/ofbiz
cd /usr/local/ofbiz
wget https://dlcdn.apache.org/ofbiz/apache-ofbiz-18.12.07.zip --no-check-certificate
unzip apache-ofbiz-18.12.07.zip -d /usr/local/ofbiz

#---------------------------------------------------------------------
# Global variables
#---------------------------------------------------------------------
IP_ADDRESS=( $(hostname -I) );
#=== Bugları düzeltiyoruz
#== Düzeltme 1
cp /usr/local/ofbiz/apache-ofbiz-18.12.07/themes/rainbowstone/webapp/rainbowstone/rainbowstone-saphir.less /usr/local/ofbiz/apache-ofbiz-18.12.07/themes/rainbowstone/webapp/rainbowstone/raınbowstone-saphır.less
#== Düzeltme 2
sed -i "s/host-headers-allowed=localhost,127.0.0.1,demo-trunk.ofbiz.apache.org,demo-stable.ofbiz.apache.org,demo-next.ofbiz.apache.org/host-headers-allowed=localhost,127.0.0.1,demo-trunk.ofbiz.apache.org,demo-stable.ofbiz.apache.org,demo-next.ofbiz.apache.org,$website,${IP_ADDRESS[0]}/" /usr/local/ofbiz/apache-ofbiz-18.12.07/framework/security/config/security.properties

#== Düzeltme 3 deneysel
#==https://cwiki.apache.org/confluence/display/OFBIZ/Install+OFBiz+with+MariaDB%2C+Apache2+Proxy+and+SSL
#sed -i "s/no.http=Y/no.http=N/" /usr/local/ofbiz/apache-ofbiz-18.12.07/framework/webapp/config/url.properties
#sed -i "s/port.https.enabled=Y/port.https.enabled=N/" /usr/local/ofbiz/apache-ofbiz-18.12.07/framework/webapp/config/url.properties
#sed -i "s/no.http=Y/no.http=N/" /usr/local/ofbiz/apache-ofbiz-18.12.07/framework/webapp/config/url.properties
#sed -i "s/port.http=8080/port.http=/" /usr/local/ofbiz/apache-ofbiz-18.12.07/framework/webapp/config/url.properties

# certbot bozuk silip tekrar yüklüyoruz
#cd /tmp
#wget https://raw.githubusercontent.com/b1glord/Configs/master/OFB%C4%B0Z/certbot.sh
#chmod +x certbot.sh
#./certbot.sh
#sudo certbot --apache certonly -n -d $website


#=== Run Gradle:
cd /usr/local/ofbiz/apache-ofbiz-18.12.07
sh gradle/init-gradle-wrapper.sh

./gradlew loadAll ofbiz


#=== Prepare OFBiz:
#==== Clean system and load the complete OFBiz data
# ./gradlew cleanAll loadAll

# =====Note: As the later step, to install without the demo data follow: (beware this is for development or production, not trying)
# ./gradlew cleanAll "ofbiz --load-data readers=seed,seed-initial" loadAdminUserLogin -PuserLoginId=admin

#=== Start OFBiz:
cd /usr/local/ofbiz/apache-ofbiz-18.12.07
#=== Start OFBiz:
./gradlew ofbiz
#=== Start OFBiz Background:
# ./gradlew "ofbizBackground --start"





#=== Visit OFBiz through your browser:

echo "https://$website:8443/ordermgr     [Order Back Office]"

echo "https://$website:8443/accounting   [Accounting Back Office]"

echo "https://$website:8443/webtools     [Administrator interface]"

echo "You can log in with the user *admin* and password *ofbiz*."
