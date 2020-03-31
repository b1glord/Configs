yum -y install autoconf automake gcc gcc-c++ git libtool make yasm pkgconfig zlib-devel

# Download lib av from https://www.libav.org/download/
cd /tmp
wget -nc https://www.libav.org/releases/libav-12.3.tar.gz
tar  -xvf libav-12.3.tar.gz

cd /tmp/libav-12.3
./configure
make
make install
