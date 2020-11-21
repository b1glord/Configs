#---------------------------------------------------------------------
# installcentos.sh
#
# NopCommerce system installer
#
# Script: installcentos.sh
# Version: 1.0.5
# Author: B1gLorD <furytr@yandex.com>
# Description: This script will install all the packages needed to install
# NopCommerce on your server.
# https://docs.nopcommerce.com/en/installation-and-upgrading/installing-nopcommerce/installing-on-linux.html
#
#---------------------------------------------------------------------
#!/bin/sh
# Ask user fror the MySQL username
# Then check if the username field is blank
# if blank it will error out
read -p "Please enter your MySQL username: " username
if [[ -z "$username" ]]; then
        echo "ERROR: That username is invalid or you didn't enter a value."
        exit
        # If username is valid or field is not blank continue and ask for the password
elif [[ -n "$username" ]]; then
        read -sp "Please enter your MySQL Password: " password
fi

# This checks if the password is valid and the field is not blank.
# Also checks if the confirmation password is valid and not blank.
# Then checks and compares the two passwords.
# If one password is typed incorrectly it will error out.
if [[ -z "$password" ]]; then
        echo ""
        echo "ERROR: That password is invalid or you didn't enter a value."
        exit
        # Password is valid.
elif [[ -n "$password" ]]; then
        echo ""
        read -sp "Please re-enter your MySQL Password: " password2
        # Confirmation Password is invalid.
        if [[ -z "$password2" ]]; then
                echo ""
                echo "ERROR: The second password entered was invalid or you didn't enter a value."
                exit
        fi
fi

# Password comparing
if [[ -n "$password2" ]] && [[ "$password" == "$password2" ]]; then
        echo ""
        echo ""
        echo "Passwords match continuing..."
        echo ""
        read -p "Please provide us your hostname for MySQL (default is localhost): " hostname

        # Checks if Passwords do not match
elif [[ -n "$password2" ]] && [[ "$password" != "$password2" ]]; then
        echo ""
        echo ""
        echo "ERROR: Passwords do not match."
        exit
       fi
fi

# Ask what hostname this can be executed locally, but localhost is default.
if [[ -z "$hostname" ]]; then
        echo ""
        echo "ERROR: Please set a proper hostname such as localhost."
        exit

        # If hostname is not blank, we will continue.
elif [[ -n "$hostname" ]]; then
        read -p "Please enter your MySQL database: " database
fi

# If database field is blank, it will error out.
if [[ -z "$database" ]]; then
        echo ""
        echo "ERROR: The database name is invalid or blank."
        exit
        # This portion checks if user is going to use a seperate database for logs if not it will continue with the installation of the database.
fi

# Register Microsoft key and feed
sudo rpm -ivh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm

# Install the .NET Core Runtime
# Update the products available for installation, then install the .NET runtime:

sudo yum -y update

sudo yum -y install apt-transport-https aspnetcore-runtime-3.1

# You may see all installed .Net Core runtimes by the following command:

dotnet --list-runtimes


# Install MySql Server
# Install the Mariadb server 10.5 version
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-10.5"
sudo yum -y install expect mariadb-client libmariadb-dev mariadb-server
sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service

# By default, the root password is empty, let's set it
#sudo /usr/bin/mysql_secure_installation
SECURE_MYSQL=$(expect -c "
set timeout 3
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"root password?\"
send \"y\r\"
expect \"New password:\"
send \"$password\r\"
expect \"Re-enter new password:\"
send \"$password\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"n\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

# Install nginx
# Install the nginx package:

sudo yum -y install nginx

# Run the nginx service:
sudo systemctl enable nginx
sudo systemctl start nginx

# and check its status:
sudo systemctl status nginx

# To configure nginx as a reverse proxy to forward requests to your ASP.NET Core app, modify /etc/nginx/sites-available/default. 
# Open it in a text editor and replace the contents with the following:

sudo cat > /etc/nginx/sites-available/default << EOF
# Default server configuration
#
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name   nopCommerce-430.com;
    location / {
    proxy_pass         http://localhost:5000;
    proxy_http_version 1.1;
    proxy_set_header   Upgrade $http_upgrade;
    proxy_set_header   Connection keep-alive;
    proxy_set_header   Host $host;
    proxy_cache_bypass $http_upgrade;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto $scheme;
    }
    # SSL configuration
    #
    # listen 443 ssl default_server;
    # listen [::]:443 ssl default_server;
    #
    # Note: You should disable gzip for SSL traffic.
    # See: https://bugs.debian.org/773332
    #
    # Read up on ssl_ciphers to ensure a secure configuration.
    # See: https://bugs.debian.org/765782
    #
    # Self signed certs generated by the ssl-cert package
    # Don't use them in a production server!
    #
    # include snippets/snakeoil.conf;
}
EOF

# Get nopCommerce
# Create a directory
sudo mkdir /var/www/nopCommerce430

# Download and unpack the nopCommerce:
cd /var/www/nopCommerce430
sudo wget https://github.com/nopSolutions/nopCommerce/releases/download/release-4.30/nopCommerce_4.30_NoSource_linux_x64.zip
sudo yum -y install unzip
sudo unzip nopCommerce_4.30_NoSource_linux_x64.zip

# Create couple directories to run nopCommerce:
sudo mkdir bin
sudo mkdir logs

# Change the file permissions
cd ..
sudo chgrp -R nginx nopCommerce430/
sudo chown -R nginx nopCommerce430/

# Create the nopCommerce service
# Create the /etc/systemd/system/nopCommerce430.service file with the following contents:
sudo  cat > /etc/systemd/system/nopCommerce430.service << EOF
[Unit]
Description=Example nopCommerce app running on Pardus
[Service]
WorkingDirectory=/var/www/nopCommerce430
ExecStart=/usr/bin/dotnet /var/www/nopCommerce430/Nop.Web.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=nopCommerce430-example
User=nginx
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false
[Install]
WantedBy=multi-user.target
EOF

# Start the service
sudo systemctl start nopCommerce430.service

# Restart the nginx server
sudo systemctl restart nginx

# Check the nopCommerce service status
sudo systemctl status nopCommerce430.service
