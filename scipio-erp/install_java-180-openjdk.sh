yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel

# update-alternatives --config java
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.372.b07-1.el7_9.x86_64/jre/bin/java

# Add Profile Java Home
cat <<'EOF' >> /etc/profile.d/javahome18.sh
#!/bin/sh
# Set JDK installation directory according to selected Java compiler
# Copy /etc/profile.d location
# Test Command 
# echo $JAVA_HOME
# echo $PATH
# echo $CLASSPATH
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.372.b07-1.el7_9.x86_64
export JRE_HOME=$JAVA_HOME/jre
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=$JAVA_HOME/jre/lib/ext:$JAVA_HOME/lib/tools.jar
EOF

source /etc/profile.d/javahome18.sh
