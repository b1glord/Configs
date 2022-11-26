#!/bin/bash
#https://staging.adoptopenjdk.net/18/installation.html?variant=openjdk8&jvmVariant=hotspot#linux-pkg

cat <<'EOF' > /etc/yum.repos.d/adoptopenjdk.repo
[AdoptOpenJDK]
name=AdoptOpenJDK
baseurl=http://adoptopenjdk.jfrog.io/adoptopenjdk/rpm/centos/$releasever/$basearch
enabled=1
gpgcheck=1
gpgkey=https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public
EOF

#yum -y install adoptopenjdk-8-openj9
yum -y install adoptopenjdk-8-hotspot

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
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=$JAVA_HOME/jre/lib/ext:$JAVA_HOME/lib/tools.jar
# export JRE_HOME=$JAVA_HOME/jre
EOF

