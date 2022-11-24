# apache ofbiz 
# install java
yum -y install java-11-openjdk java-11-openjdk-devel

cat > /etc/profile.d/java11.sh <<EOF
export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
EOF

echo "export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))" >> ~/.bash_profile


# == Install Required programs
yum -y install perl-Digest-SHA

# == Quick start
# === Download the Gradle wrapper:
mkdir /home/ofbiz
cd /home/ofbiz
wget https://dlcdn.apache.org/ofbiz/apache-ofbiz-18.12.06.zip --no-check-certificate
unzip apache-ofbiz-18.12.06.zip -d /home/ofbiz
cd /home/ofbiz/apache-ofbiz-18.12.06
git clone https://gitbox.apache.org/repos/asf/ofbiz-plugins.git ~/home/ofbiz/plugins 

#=== install OFBiz Framework:
#git clone https://gitbox.apache.org/repos/asf/ofbiz-framework.git ofbiz-framework 


cd /home/ofbiz//apache-ofbiz-18.12.06
sh gradle/init-gradle-wrapper.sh

#=== Prepare OFBiz:

#==== Clean system and load the complete OFBiz data
./gradlew cleanAll loadAll

# =====Note: As the later step, to install without the demo data follow: (beware this is for development or production, not trying)
./gradlew cleanAll "ofbiz --load-data readers=seed,seed-initial" loadAdminUserLogin -PuserLoginId=admin

#=== Start OFBiz:
cd /home/ofbiz/apache-ofbiz-18.12.06
./gradlew "ofbizBackground --start"





#=== Visit OFBiz through your browser:

echo "https://localhost:8443/ordermgr     [Order Back Office]"

echo "https://localhost:8443/accounting   [Accounting Back Office]"

echo "https://localhost:8443/webtools     [Administrator interface]"

echo "You can log in with the user *admin* and password *ofbiz*."
