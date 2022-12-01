#!/bin/bash
# https://phoenixnap.com/kb/install-squid-proxy-server-centos

# Configuring the Squid Proxy Server
# To install Squid, type:
yum -y install squid

# Now start Squid by entering the following command:
systemctl start squid

# To set up an automatic start at boot:
systemctl enable squid

# Review the status of the service, use:
systemctl status squid

