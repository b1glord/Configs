# https://www.dynu.com/DynamicDNS/IPUpdateClient/Linux
#
# Download Dynu Client for Red Hat Enterprise Linux 7
rpm -ivh https://www.dynu.com/support/downloadfile/30 
#
# Configure Dynu Client for Red Hat Enterprise Linux 7 (pvpgn.freeddns.org)
sed -i "s/username/username aktifhost/" /etc/dynuiuc/dynuiuc.conf
sed -i "s/location/location work/" /etc/dynuiuc/dynuiuc.conf
#
# Add Password Manuel
yum install -y nano
nano /etc/dynuiuc/dynuiuc.conf

