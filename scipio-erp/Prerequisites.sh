# Dosya Yolu: /scipio-erp/Prerequisites.sh
# Amac: Scipio ERP icin eski CentOS gelistirme bagimliliklarini kurar
# Tool - Shell
# Version: 1.2.0
# Aciklama: Git, legacy Java 8 ve Ant kurulum adimlarini toplar
#
# Bagimli Oldugu Katman: Tool

#!/bin/bash

wget -nc https://raw.githubusercontent.com/b1glord/ispconfig_setup_extra/master/centos7/git/install_github.sh -P /tmp
chmod +x /tmp/install_github.sh
/tmp/install_github.sh

cd /tmp
wget https://raw.githubusercontent.com/b1glord/Configs/master/OFBIZ/tools/legacy/java/oraclejdk8.sh
chmod +x oraclejdk8.sh
./oraclejdk8.sh

yum -y install ant
