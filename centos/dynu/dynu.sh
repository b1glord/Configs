#https://www.dynu.com/en-US/Resources/Downloads
#Download Dynu Client for Red Hat Enterprise Linux 7
rpm -ivh https://github.com/b1glord/Configs/raw/master/centos/dynu/dynuiuc-2.6.2-2.el7.x86_64.rpm
rpm -Uvh https://www.dynu.com/support/downloadfile/30
#
#Configure Dynu Client for Red Hat Enterprise Linux 7 (pvpgn.freeddns.org)
sed -i "s/username/username aktifhost/" /etc/dynuiuc/dynuiuc.conf
sed -i "s/location/location work/" /etc/dynuiuc/dynuiuc.conf
#
#Add Password Manuel
yum -y install nano
nano /etc/dynuiuc/dynuiuc.conf
