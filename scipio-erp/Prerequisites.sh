# github 2.x
wget -nc https://raw.githubusercontent.com/b1glord/ispconfig_setup_extra/master/centos7/git/install_github.sh -P /tmp
chmod +x /tmp/install_github.sh
/tmp/install_github.sh

# java 1.8 ile çalışıyor üst sürümlere uyumlu degil
wget -nc https://raw.githubusercontent.com/b1glord/Configs/master/scipio-erp/install_java-180-openjdk.sh -P /tmp
chmod +x /tmp/install_java-180-openjdk.sh
/tmp/install_java-180-openjdk.sh

# ant
yum -y install ant
