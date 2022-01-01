apache ofbiz 

// java 8 ile çalışıyor üst sürümlere uyumlu degil

sudo yum -y install java-1.8.0-openjdk-devel
sudo yum -y install java-1.8.0-openjdk


$javahomedir = dirname $(readlink $(readlink $(which java)))
echo JAVA_HOME="$javahomedir" > /etc/profile.d/java.sh

//source /etc/profile.d/java.sh
//echo $JAVA_HOME

//kontrol ediyoruz
java –version


// gradle kurulumu https://gradle.org/releases/
cd /tmp
wget https://services.gradle.org/distributions/gradle-7.3.3-all.zip

sudo mkdir /opt/gradle
sudo unzip -d /opt/gradle gradle-7.3.3-all.zip
export PATH=$PATH:/opt/gradle/gradle-7.3.3/bin

//kontrol ediyoruz
gradle –v



cd /home/ofbiz/
git clone https://github.com/apache/ofbiz.git 
git clone https://gitbox.apache.org/repos/asf/ofbiz-plugins.git plugins 
git clone https://gitbox.apache.org/repos/asf/ofbiz-framework.git ofbiz-framework 
git pull


./gradlew cleanAll loadAll

