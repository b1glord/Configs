#!/bin/bash

# First verify the version of Java being used is not Oracle JDK.
java -version

# Get the latest Oracle Java SDK http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
wget -c --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "https://download.oracle.com/otn/java/jdk/8u311-b11/4d5417147a92418ea8b615e228bb6935/jdk-8u311-linux-x64.rpm" --output-document="jdk-8u31-linux-x64.rpm"

# Install Java SDK
sudo rpm -i jdk-8u31-linux-x64.rpm

# Check if the default java version is set to sun jdk
java -version

# If not then lets create one more alternative for Java for Sun JDK
sudo /usr/sbin/alternatives --install /usr/bin/java java /usr/java/default/bin/java 20000

# Export JAVA_HOME enviroment variable
export JAVA_HOME=/usr/java/default

# Set the SUN JDK as the default java
sudo /usr/sbin/alternatives --config java

# Verify if change in SDK was done.
java -version
