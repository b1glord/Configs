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
