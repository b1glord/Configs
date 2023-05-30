# github 2.x
wget -nc https://raw.githubusercontent.com/b1glord/ispconfig_setup_extra/master/centos7/git/install_github.sh -P /tmp
chmod +x /tmp/install_github.sh
/tmp/install_github.sh

## java 1.8 ile çalışıyor üst sürümlere uyumlu degil
# wget -nc https://raw.githubusercontent.com/b1glord/Configs/master/scipio-erp/install_java-180-openjdk.sh -P /tmp
# chmod +x /tmp/install_java-180-openjdk.sh
# /tmp/install_java-180-openjdk.sh

# java 8 ile çalışıyor üst sürümlere uyumlu degil
cd /tmp
#wget https://raw.githubusercontent.com/b1glord/Configs/master/OFBİZ/install_oraclejdk8.sh
wget https://raw.githubusercontent.com/b1glord/Configs/master/scipio-erp/install_java-180-openjdk.sh
chmod +x install_oraclejdk8.sh
./install_oraclejdk8.sh

# ant
yum -y install ant
