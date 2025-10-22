# 1) Derleme araclari (root isen sudo gerekmez)
# apt update && apt install -y cmake build-essential zlib1g-dev

# 2) Temiz build klasoru
cd /opt/rathena/src/tool
rm -rf build && mkdir build && cd build

# 3) Cikis dizinlerini tools/ olarak ayarla ve projeyi hazirla
cmake \
  -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=/opt/rathena/tools \
  -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=/opt/rathena/tools \
  -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=/opt/rathena/tools \
  ..

# 4) Sadece mapcache hedefini derle
cmake --build . --target mapcache --config Release -j

# 5) Kontrol
ls -l /opt/rathena/tools/mapcache
