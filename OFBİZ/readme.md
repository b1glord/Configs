# Apache Ofbiz Auto Install

### Prebuilt Packages on Centos 
```
yum -y install wget unzip
cd /tmp
rm -f ./ofbiz_linux.sh
wget -nc https://raw.githubusercontent.com/b1glord/Configs/master/OFBİZ/ofbiz_linux.sh
chmod +x ofbiz_linux.sh
./ofbiz_linux.sh
```


# === Start OFBiz:
```
cd /home/ofbiz
./gradlew "ofbizBackground --start"
```

# === Stop OFBiz:
```
cd /home/ofbiz
./gradlew "ofbiz --shutdown"
```

# === Visit OFBiz through your browser:

https://localhost:8443/ordermgr     [Order Back Office]

https://localhost:8443/accounting   [Accounting Back Office]

https://localhost:8443/webtools     [Administrator interface]

## You can log in with the user *admin* and password *ofbiz*.
