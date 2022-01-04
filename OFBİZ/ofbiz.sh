# apache ofbiz 
# java 8 ile çalışıyor üst sürümlere uyumlu degil
# export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
# adapt https://www.codegrepper.com/code-examples/java/export+java+home
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel
cat > /etc/profile.d/java8.sh <<EOF 
export JAVA_HOME_BIN=`which java`
export PATH=\$PATH:\$JAVA_HOME/bin
export CLASSPATH=.:\$JAVA_HOME/jre/lib:\$JAVA_HOME/lib:\$JAVA_HOME/lib/tools.jar
EOF
source /etc/profile.d/java8.sh
# kontrol ediyoruz
java –version

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
./gradlew ofbiz

# === Visit OFBiz through your browser:

https://localhost:8443/webtools


git clone https://gitbox.apache.org/repos/asf/ofbiz-framework.git ofbiz-framework 
