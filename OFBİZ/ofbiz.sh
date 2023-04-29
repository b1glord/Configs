# apache ofbiz 
# java 8 ile çalışıyor üst sürümlere uyumlu degil
cd /tmp
wget https://raw.githubusercontent.com/b1glord/Configs/master/OFBİZ/install_oraclejdk8.sh
chmod +x install_oraclejdk8.sh
./install_oraclejdk8.sh

# == Install Required programs
yum -y install perl-Digest-SHA

# == Quick start
# === Download the Gradle wrapper:
# rm -f -r /usr/local/ofbiz    //need delete all files
mkdir /usr/local/ofbiz
cd /usr/local/ofbiz
wget https://dlcdn.apache.org/ofbiz/apache-ofbiz-18.12.07.zip --no-check-certificate
unzip apache-ofbiz-18.12.07.zip -d /usr/local/ofbiz


#=== Run Gradle:
cd /usr/local/ofbiz/apache-ofbiz-18.12.07
sh gradle/init-gradle-wrapper.sh

./gradlew loadAll ofbiz



#=== Bugları düzeltiyoruz
#== Düzeltme 1
cp /usr/local/ofbiz/apache-ofbiz-18.12.07/themes/rainbowstone/webapp/rainbowstone/rainbowstone-saphir.less /usr/local/ofbiz/apache-ofbiz-18.12.07/themes/rainbowstone/webapp/rainbowstone/raınbowstone-saphır.less
#== Düzeltme 2
/usr/local/ofbiz/apache-ofbiz-18.12.07/framework/security/config/security.properties
host-headers-allowed=localhost,127.0.0.1,demo-trunk.ofbiz.apache.org,demo-stable.ofbiz.apache.org,demo-next.ofbiz.apache.org,192.168.1.170

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

echo "https://localhost:8443/ordermgr     [Order Back Office]"

echo "https://localhost:8443/accounting   [Accounting Back Office]"

echo "https://localhost:8443/webtools     [Administrator interface]"

echo "You can log in with the user *admin* and password *ofbiz*."
