#!/bin/sh
clear
echo ""
echo "Welcome to the DYNU installer"
echo "This script will install DYNU."
#echo ""
#echo "This script was created by BigLorD "
echo ""
echo ""

# Ask user fror the DYNU username
# Then check if the username field is blank
# if blank it will error out
read -p "Please enter your DYNU username: " username
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
        read -sp "Please re-enter your DYNU Password: " password2
        # Confirmation Password is invalid.
        if [[ -z "$password2" ]]; then
                echo ""
                echo "ERROR: The second password entered was invalid or you didn't enter a value."
                exit
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
#https://www.dynu.com/en-US/Resources/Downloads
#Download Dynu Client for Red Hat Enterprise Linux 7
rpm -ivh https://github.com/b1glord/Configs/raw/master/centos/dynu/dynuiuc-2.6.2-2.el7.x86_64.rpm
rpm -Uvh https://www.dynu.com/support/downloadfile/30
#
#Configure Dynu Client for Red Hat Enterprise Linux 7 (pvpgn.freeddns.org)
sed -i "s/username/username $username/" /etc/dynuiuc/dynuiuc.conf
sed -i "s/location/location work/" /etc/dynuiuc/dynuiuc.conf
sed -i "s/password/password $password/" /etc/dynuiuc/dynuiuc.conf
#
#Add Password Manuel
#yum -y install nano
#nano /etc/dynuiuc/dynuiuc.conf
