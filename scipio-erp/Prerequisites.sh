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
wget -O oraclejdk8.sh https://raw.githubusercontent.com/TurkuazLabs/TurkuazOFBiz/main/tools/legacy/java/oraclejdk8.sh
bash oraclejdk8.sh

yum -y install ant
