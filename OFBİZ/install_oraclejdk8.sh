#!/bin/bash
# Get the latest Oracle Java SDK http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
# https://github.com/frekele/oracle-java
wget -nc https://github.com/frekele/oracle-java/releases/download/8u92-b14/jdk-8u92-linux-x64.rpm
# Install Java SDK
sudo rpm -i jdk-8u92-linux-x64.rpm

# Add Profile Java Home
cat <<'EOF' >> /etc/profile.d/javahome.sh
#!/bin/sh
# Set JDK installation directory according to selected Java compiler
# Copy /etc/profile.d location
# Test Command 
# echo $JAVA_HOME
# echo $PATH
# echo $CLASSPATH
export JAVA_HOME=/usr/java/default
export JRE_HOME=$JAVA_HOME/jre
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=$JAVA_HOME/jre/lib/ext:$JAVA_HOME/lib/tools.jar
EOF
