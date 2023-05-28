# scipio erp
# java 1.8 ile çalışıyor üst sürümlere uyumlu degil
cd /tmp
wget https://raw.githubusercontent.com/b1glord/Configs/master/scipio-erp/install_java-180-openjdk.sh
chmod +x install_java-180-openjdk.sh
./install_java-180-openjdk.sh

yum -y install ant

git clone https://github.com/ilscipio/scipio-erp.git /usr/local/scipio-erp

cd /usr/local/scipio-erp

git checkout 2.x

# solr 8080 default port degistirme cakısmaları onlemek için
sed -i "s/solr.webapp.portOverride=/solr.webapp.portOverride=2480/" /usr/local/scipio-erp/applications/solr/config/solrconfig.properties

./install.sh
