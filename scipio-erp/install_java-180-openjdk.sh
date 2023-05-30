yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel

# update-alternatives --config java
#export JAVA_HOME=readlink -f $(which java)

# Add Profile Java Home
cat <<'EOF' >> /etc/profile.d/javahome18.sh
#!/bin/sh
# Set JDK installation directory according to selected Java compiler
# Copy /etc/profile.d location
# Test Command 
# echo $JAVA_HOME
# echo $PATH
# echo $CLASSPATH
export JAVA_HOME=readlink -f $(which java)
export JRE_HOME=$JAVA_HOME/jre
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=$JAVA_HOME/jre/lib/ext:$JAVA_HOME/lib/tools.jar
EOF

source /etc/profile.d/javahome18.sh
