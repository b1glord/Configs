```
cp /opt/rathena/conf/msg_conf/map_msg.conf \
   /opt/rathena/conf/msg_conf/map_msg_tur.conf

sed -i 's|import: conf/msg_conf/import/map_msg_eng_conf.txt|import: conf/msg_conf/import/map_msg_tur_conf.txt|' /opt/rathena/conf/msg_conf/map_msg_tur.conf


grep -q "LANG_TUR" /opt/rathena/src/common/msg_conf.hpp || \
sed -i '/LANG_THA = 0x100,/a\ \tLANG_TUR = 0x200,   // Turkish' /opt/rathena/src/common/msg_conf.hpp

sed -i 's/#define LANG_ENABLE .*/#define LANG_ENABLE 0xFFF/' /opt/rathena/src/common/msg_conf.hpp


FILE="/opt/rathena/src/map/map.cpp"

# Zaten atama varsa dokunma
if ! grep -q 'MSG_CONF_NAME_TUR[[:space:]]*=' "$FILE"; then
  sed -i '/MSG_CONF_NAME_THA[[:space:]]*=[[:space:]]*"conf\/msg_conf\/map_msg_tha\.conf";[[:space:]]*\/\/[[:space:]]*Thai/a\
   MSG_CONF_NAME_TUR = "conf/msg_conf/map_msg_tur.conf";   // Turkish' "$FILE" || \
  sed -i '/MSG_CONF_NAME_THA[[:space:]]*=[[:space:]]*"conf\/msg_conf\/map_msg_tha\.conf";/a\
   MSG_CONF_NAME_TUR = "conf/msg_conf/map_msg_tur.conf";   // Turkish' "$FILE"
fi

FILE_H=/opt/rathena/src/map/map.hpp

# CRLF temizle (Windows satir sonu ise)
sed -i 's/\r$//' "$FILE_H"

# extern yoksa THA altina ekle
grep -q 'extern[[:space:]]\+const[[:space:]]\+char\*[[:space:]]*MSG_CONF_NAME_TUR' "$FILE_H" || \
sed -i '/extern[[:space:]]\+const[[:space:]]\+char\*[[:space:]]*MSG_CONF_NAME_THA[[:space:]]*;/a\extern const char* MSG_CONF_NAME_TUR;' "$FILE_H"



wget https://raw.githubusercontent.com/b1glord/Configs/refs/heads/master/Docker/conf/msg_conf/import/map_msg_tur_conf.txt /opt/rathena/conf/msg_conf/import/map_msg_tur_conf.txt
```
