# Centos 7 libav Kurulum
## https://wiki.libav.org/Platform/Linux#Pre_Built_Static_Binaries
yum -y install autoconf automake gcc gcc-c++ git libtool make yasm pkgconfig zlib-devel

# Download lib av from https://www.libav.org/download/
cd /tmp
wget -nc https://www.libav.org/releases/libav-11.12.tar.gz
tar  -xvf libav-11.12.tar.gz

cd /tmp/libav-11.12
./configure
make
make install
