#!/bin/bash

# Install Java SDK
yum -y install java-11-openjdk.x86_64 

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
export JRE_HOME=/usr/java/default/jre
export PATH=$PATH:/usr/java/default/bin:/usr/java/default/jre/bin
EOF
