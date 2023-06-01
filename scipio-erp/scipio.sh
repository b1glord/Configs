# https://www.scipioerp.com/community/developer/installation-configuration/
# scipio erp Prerequisites
wget -nc https://raw.githubusercontent.com/b1glord/Configs/master/scipio-erp/Prerequisites.sh -P /tmp
chmod a+x /tmp/Prerequisites.sh
/tmp/Prerequisites.sh

# scipio erp
git clone https://github.com/ilscipio/scipio-erp.git /usr/local/scipio-erp

cd /usr/local/scipio-erp
#git checkout scipioce-1.14
git checkout 2.x

# solr 8080 default port degistirme cakısmaları onlemek için
# sed -i "s/solr.webapp.portOverride=/solr.webapp.portOverride=2480/" /usr/local/scipio-erp/applications/solr/config/solrconfig.properties

# ispconfig ile scipio erp port çakışmaları için duzeltme 
sed -i "s/8080/2083/" /etc/nginx/sites-available/ispconfig.vhost
systemctl restart nginx

./install.sh
