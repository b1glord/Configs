#!/bin/bash
# https://certbot.eff.org/instructions?ws=nginx&os=pip
# https://www.nginx.com/blog/using-free-ssltls-certificates-from-lets-encrypt-with-nginx/

# Install system dependencies
sudo yum -y install python3 augeas-libs

# Remove certbot-auto and any Certbot OS packages
sudo yum -y remove certbot

# Set up a Python virtual environment
sudo python3 -m venv /opt/certbot/
sudo /opt/certbot/bin/pip install --upgrade pip

# Install Certbot
sudo /opt/certbot/bin/pip install certbot certbot-nginx

# Prepare the Certbot command
sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot
