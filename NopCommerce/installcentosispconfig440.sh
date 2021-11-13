#---------------------------------------------------------------------
# installcentos.sh
#
# NopCommerce system installer
#
# Script: installcentos.sh
# Version: 1.0.6
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
fi

# If sitename field is blank, it will error out.(test)
read -p "Please enter your website name (ornek xxx.com): " website
if [[ -z "$website" ]]; then
        echo "ERROR: The website name is invalid or blank."
        exit
fi

# If you have a problem with loading images in the RichText Box (The type initializer for 'Gdip' threw an exception) just install the libgdiplus library:
sudo yum -y install libgdiplus

# Register Microsoft key and feed
sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm

# Install the .NET Core Runtime 1
## Update the products available for installation, then install the .NET runtime:
#wget https://dot.net/v1/dotnet-install.sh
#chmod +x dotnet-install.sh
#sudo ./dotnet-install.sh

# Install the .NET Core Runtime 2
## Update the products available for installation, then install the .NET runtime:
sudo yum -y update 
sudo yum -y install dotnet-sdk-5.0
#sudo yum -y install aspnetcore-runtime-5.0
#sudo yum -y install dotnet-runtime-5.0

## You may see all installed .Net Core runtimes by the following command:
dotnet --list-runtimes


### Add Database
mysql -u root -p$password -e 'CREATE DATABASE '$database';'
mysql -u root -p$password -e "CREATE USER '$username'@'$hostname' IDENTIFIED BY '$password'"
mysql -u root -p$password -e 'GRANT ALL PRIVILEGES on '$database'.* to '$username'@'$hostname';'
mysql -u root -p$password -e 'FLUSH PRIVILEGES;'



# Create ISPConfig Client nopCommerce Directory
#sudo mkdir /var/www/clients/client1/$website/web/nopCommerce440


## Download and unpack the nopCommerce:
cd /var/www/clients/client1/$website/web
sudo wget https://github.com/nopSolutions/nopCommerce/releases/download/release-4.40.4/nopCommerce_4.40.4_NoSource_linux_x64.zip
sudo yum -y install unzip
sudo unzip nopCommerce_4.40.4_NoSource_linux_x64.zip

## Create couple directories to run nopCommerce:
sudo mkdir bin
sudo mkdir logs


## (İsteğe bağlı): .NET Core web uygulamanızı çevrimiçi durumda tutmak için Süpervizör Kurulumu
sudo yum install supervisor -y
sudo systemctl start supervisord.service
sudo systemctl enable supervisord.service

### Load the new Supervisor settings:
# sudo supervisorctl reread
# sudo supervisorctl update

### Now, you can use the following command to show the app's status:
systemctl status supervisord


## Create the nopCommerce service
## Create the /etc/systemd/system/nopCommerce440.service file with the following contents:
sudo  cat > /etc/systemd/system/nopCommerce440.service << EOF
[Unit]
Description=$hostname nopCommerce app running on CentOS 7

[Service]
WorkingDirectory=/var/www/clients/client1/$website/web
ExecStart=/usr/bin/dotnet /var/www/clients/client1/$website/web/Nop.Web.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=nopCommerce440-example
User=root
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
EOF

## Start the service
sudo systemctl enable nopCommerce440.service
sudo systemctl start nopCommerce440.service

## Restart the nginx server
sudo systemctl restart nginx

## Check the nopCommerce service status
sudo systemctl status nopCommerce440.service
