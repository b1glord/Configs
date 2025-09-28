
cp /opt/rathena/conf/msg_conf/map_msg.conf \
   /opt/rathena/conf/msg_conf/map_msg_tur.conf

sed -i 's|import: conf/msg_conf/import/map_msg_eng_conf.txt|import: conf/msg_conf/import/map_msg_tur_conf.txt|' /opt/rathena/conf/msg_conf/map_msg_tur.conf




wget https://raw.githubusercontent.com/b1glord/Configs/refs/heads/master/Docker/conf/msg_conf/import/map_msg_tur_conf.txt 
