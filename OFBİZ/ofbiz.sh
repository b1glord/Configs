# apache ofbiz 
# java 8 ile çalışıyor üst sürümlere uyumlu degil
cd /tmp
wget https://raw.githubusercontent.com/b1glord/Configs/master/OFBİZ/install_oraclejdk8.sh
chmod +x install_oraclejdk8.sh
./install_oraclejdk8.sh

# == Quick start
# === Download the Gradle wrapper:
cd /tmp
wget https://dlcdn.apache.org/ofbiz/apache-ofbiz-18.12.04.zip --no-check-certificate
unzip apache-ofbiz-18.12.04.zip
mv /tmp/apache-ofbiz-18.12.04 /home/ofbiz
git clone https://gitbox.apache.org/repos/asf/ofbiz-plugins.git ~/home/ofbiz/plugins 

yum -y install perl-Digest-SHA 
cd /home/ofbiz
sh gradle/init-gradle-wrapper.sh

=== Prepare OFBiz:

==== Clean system and load the complete OFBiz data
./gradlew cleanAll loadAll

# =====Note: As the later step, to install without the demo data follow: (beware this is for development or production, not trying)
./gradlew cleanAll "ofbiz --load-data readers=seed,seed-initial" loadAdminUserLogin -PuserLoginId=admin

#=== Start OFBiz:
cd /home/ofbiz
./gradlew "ofbizBackground --start"

# === Visit OFBiz through your browser:

https://localhost:8443/ordermgr     [Order Back Office]

https://localhost:8443/accounting   [Accounting Back Office]

https://localhost:8443/webtools     [Administrator interface]

You can log in with the user *admin* and password *ofbiz*.


git clone https://gitbox.apache.org/repos/asf/ofbiz-framework.git ofbiz-framework 
