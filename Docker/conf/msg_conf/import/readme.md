
cp /opt/rathena/conf/msg_conf/map_msg.conf \
   /opt/rathena/conf/msg_conf/map_msg_tur.conf

sed -i 's|import: conf/msg_conf/import/map_msg_eng_conf.txt|import: conf/msg_conf/import/map_msg_tur_conf.txt|' /opt/rathena/conf/msg_conf/map_msg_tur.conf


grep -q "LANG_TUR" /opt/rathena/src/common/msg_conf.hpp || \
sed -i '/LANG_THA = 0x100,/a\ \tLANG_TUR = 0x200,   // Turkish' /opt/rathena/src/common/msg_conf.hpp



wget https://raw.githubusercontent.com/b1glord/Configs/refs/heads/master/Docker/conf/msg_conf/import/map_msg_tur_conf.txt 
