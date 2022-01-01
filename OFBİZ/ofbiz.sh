# apache ofbiz 
# java 8 ile çalışıyor üst sürümlere uyumlu degil
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel
cat > /etc/profile.d/java8.sh <<EOF
export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
export PATH=\$PATH:\$JAVA_HOME/bin
export CLASSPATH=.:\$JAVA_HOME/jre/lib:\$JAVA_HOME/lib:\$JAVA_HOME/lib/tools.jar
EOF
source /etc/profile.d/java8.sh

# echo $JAVA_HOME
# kontrol ediyoruz
java –version

# gradle kurulumu https://gradle.org/releases/
cd /tmp
wget https://services.gradle.org/distributions/gradle-7.3.3-all.zip
sudo mkdir /opt/gradle
sudo unzip -d /opt/gradle gradle-7.3.3-all.zip
export PATH=$PATH:/opt/gradle/gradle-7.3.3/bin
# kontrol ediyoruz
gradle –v

# apache ofbiz i indiriyoruz
cd /home/ofbiz/
git clone https://github.com/apache/ofbiz.git 
git clone https://gitbox.apache.org/repos/asf/ofbiz-plugins.git plugins 
# git pull

./gradlew cleanAll loadAll



git clone https://gitbox.apache.org/repos/asf/ofbiz-framework.git ofbiz-framework 
