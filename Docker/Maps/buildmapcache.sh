# 1) Derleme araclari (root isen sudo gerekmez)
# apt update && apt install -y cmake build-essential zlib1g-dev

# 2) Temiz build klasoru
cd /opt/rathena/src
rm -rf build && mkdir build && cd build


# 3) Sadece mapcache hedefini derle
cmake --build . --target mapcache --config Release -j

# 4) Move
mv /opt/rathena/mapcache /opt/rathena/tools/mapcache

# 5) Kontrol
ls -l /opt/rathena/tools/mapcache
