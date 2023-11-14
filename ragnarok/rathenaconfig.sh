# ===================  Src COnf  ========================= #
# ======================================================== #

#  Max leveli artırmak icin 
# /root/rAthena/src/map/map.hpp
# //bul
# #define MAX_LEVEL 175
# //bununla degistir
# #define MAX_LEVEL 255
sed -i "s/#define MAX_LEVEL 250/#define MAX_LEVEL 512/" /root/rAthena/src/map/map.hpp



#  serverin vip ayarlarını acmak icin
# /root/rAthena/src/config/core.hpp
# //bul
# //#define VIP_ENABLE
# //bununla degistir
# #define VIP_ENABLE
sed -i "s%//#define VIP_ENABLE%#define VIP_ENABLE%" /root/rAthena/src/config/core.hpp




# ============  Copy Config Files in import folder  ============ #
mkdir ~/rAthena/conf/import
cp ~/rAthena/conf/atcommands.yml        ~/rAthena/conf/import/atcommands.yml
cp ~/rAthena/conf/battle_athena.conf    ~/rAthena/conf/import/battle_conf.txt
cp ~/rAthena/conf/char_athena.conf      ~/rAthena/conf/import/char_conf.txt
cp ~/rAthena/conf/groups.yml            ~/rAthena/conf/import/groups.yml
cp ~/rAthena/conf/inter_athena.conf     ~/rAthena/conf/import/inter_conf.txt
cp ~/rAthena/conf/inter_server.yml      ~/rAthena/conf/import/inter_server.yml
cp ~/rAthena/conf/log_athena.conf       ~/rAthena/conf/import/log_conf.txt
cp ~/rAthena/conf/login_athena.conf     ~/rAthena/conf/import/login_conf.txt
cp ~/rAthena/conf/map_athena.conf       ~/rAthena/conf/import/map_conf.txt
cp ~/rAthena/conf/packet_athena.conf    ~/rAthena/conf/import/packet_conf.txt
cp ~/rAthena/conf/script_athena.conf    ~/rAthena/conf/import/script_conf.txt
cp ~/rAthena/conf/web_athena.conf       ~/rAthena/conf/import/web_conf.txt

# =========================  Char Conf  ======================== #
sed -i "s%userid: s1%userid: chaos%" ~/rAthena/conf/import/char_conf.txt
sed -i "s%passwd: p1%passwd: chaos%" ~/rAthena/conf/import/char_conf.txt

sed -i "s%server_name: rAthena%server_name: Athena%" ~/rAthena/conf/import/char_conf.txt

sed -i "s%//login_ip: 127.0.0.1%login_ip: 127.0.0.1%" ~/rAthena/conf/import/char_conf.txt
sed -i "s%//char_ip: 127.0.0.1%char_ip: pvpgn.freeddns.org%" ~/rAthena/conf/import/char_conf.txt

sed -i "s%start_zeny: 0%start_zeny: 1000000%" ~/rAthena/conf/import/char_conf.txt

sed -i "s%char_del_option: 2%char_del_option: 1%" ~/rAthena/conf/import/char_conf.txt

sed -i "s%pincode_enabled: yes%pincode_enabled: no%" ~/rAthena/conf/import/char_conf.txt

sed -i "s%import: conf/import/char_conf.txt%//import: conf/import/char_conf.txt%" ~/rAthena/conf/import/char_conf.txt

# =========================  inter Conf  ======================== #
# // MySQL Login server
sed -i "s%login_server_id: ragnarok%login_server_id: c1ragnarok%" ~/rAthena/conf/import/inter_conf.txt
sed -i "s%login_server_pw: ragnarok%login_server_pw: gaZWLeQ9yp#%" ~/rAthena/conf/import/inter_conf.txt
sed -i "s%login_server_db: ragnarok%login_server_db: c1ragnarok%" ~/rAthena/conf/import/inter_conf.txt

sed -i "s%ipban_db_id: ragnarok%ipban_db_id: c1ragnarok%" ~/rAthena/conf/import/inter_conf.txt
sed -i "s%ipban_db_pw: ragnarok%ipban_db_pw: gaZWLeQ9yp#%" ~/rAthena/conf/import/inter_conf.txt
sed -i "s%ipban_db_db: ragnarok%ipban_db_db: c1ragnarok%" ~/rAthena/conf/import/inter_conf.txt

# // MySQL Character server
sed -i "s%char_server_id: ragnarok%char_server_id: c1ragnarok%" ~/rAthena/conf/import/inter_conf.txt
sed -i "s%char_server_pw: ragnarok%char_server_pw: gaZWLeQ9yp#%" ~/rAthena/conf/import/inter_conf.txt
sed -i "s%char_server_db: ragnarok%char_server_db: c1ragnarok%" ~/rAthena/conf/import/inter_conf.txt

# // MySQL Map Server
sed -i "s%map_server_id: ragnarok%map_server_id: c1ragnarok%" ~/rAthena/conf/import/inter_conf.txt
sed -i "s%map_server_pw: ragnarok%map_server_pw: gaZWLeQ9yp#%" ~/rAthena/conf/import/inter_conf.txt
sed -i "s%map_server_db: ragnarok%map_server_db: c1ragnarok%" ~/rAthena/conf/import/inter_conf.txt

# // MySQL Web Server
sed -i "s%web_server_id: ragnarok%web_server_id: c1ragnarok%" ~/rAthena/conf/import/inter_conf.txt
sed -i "s%web_server_pw: ragnarok%web_server_pw: gaZWLeQ9yp#%" ~/rAthena/conf/import/inter_conf.txt
sed -i "s%web_server_db: ragnarok%web_server_db: c1ragnarok%" ~/rAthena/conf/import/inter_conf.txt

# // MySQL Log Database
sed -i "s%log_db_id: ragnarok%log_db_id: c1ragnarok%" ~/rAthena/conf/import/inter_conf.txt
sed -i "s%log_db_pw: ragnarok%log_db_pw: gaZWLeQ9yp#%" ~/rAthena/conf/import/inter_conf.txt
sed -i "s%log_db_db: ragnarok%log_db_db: c1logs%" ~/rAthena/conf/import/inter_conf.txt

sed -i "s%use_sql_db: no%use_sql_db: yes%" ~/rAthena/conf/import/inter_conf.txt

sed -i "s%import: conf/import/inter_conf.txt%//import: conf/import/inter_conf.txt%" ~/rAthena/conf/import/inter_conf.txt


# =========================  Map Conf  ======================== #
sed -i "s%userid: s1%userid: chaos%" ~/rAthena/conf/import/map_conf.txt
sed -i "s%passwd: p1%passwd: chaos%" ~/rAthena/conf/import/map_conf.txt

sed -i "s%//login_ip: 127.0.0.1%login_ip: 127.0.0.1%" ~/rAthena/conf/import/map_conf.txt
sed -i "s%//char_ip: 127.0.0.1%char_ip: pvpgn.freeddns.org%" ~/rAthena/conf/import/map_conf.txt

sed -i "s%import: conf/import/map_conf.txt%//import: conf/import/map_conf.txt%" ~/rAthena/conf/import/map_conf.txt


# ===================  Conf/Battle Settings  =================== #
# ============================================================== #

# ===================  battle.conf  ============================ #


# ===================  battleground.conf  ====================== #


# ===================  client.conf  ============================ #


# ===================  drops.conf  ============================= #

# https://forum.ratemyserver.net/general-discussion/what-are-your-favorite-rates-max-level/
# // Use logarithmic drops? (Note 1)
# // Logarithmic drops scale drop rates in a non-linear fashion using the equation 
# // Droprate(x,y) = x * (5 - log(x)) ^ (ln(y) / ln(5))
# // Where x is the original drop rate and y is the drop_rate modifier (the previously mentioned item_rate* variables)
# // Use the following table for an idea of how the rate will affect drop rates when logarithmic drops are used:
# // Y: Original Drop Rate
# // X: Rate drop modifier (eg: item_rate_equip)
sed -i "s%// Droprate(x,y) = x * (5 - log(x)) ^ (ln(y) / ln(5))%Droprate(x,y) = 1 - ((1 - x) ^ y)%" /root/rAthena/conf/battle/drops.conf
sed -i "s%item_logarithmic_drops: no%item_logarithmic_drops: yes%" /root/rAthena/conf/battle/drops.conf

# // Increase item drop rate +0.01%? (Note 1)
# // On official servers it is possible to get 0.00% drop chance so all items are increased by 0.01%.
# // NOTE: This is viewed as a bug to rAthena.
# // Default: no
# drop_rateincrease: no
sed -i "s%drop_rateincrease: no%drop_rateincrease: yes%" /root/rAthena/conf/battle/drops.conf


# // Makes your LUK value affect drop rates on an absolute basis.
# // Setting to 100 means each luk adds 0.01% chance to find items
# // (regardless of item's base drop rate).
# drops_by_luk: 0
sed -i "s%drops_by_luk: 0%drops_by_luk: 1%" /root/rAthena/conf/battle/drops.conf
sed -i "s%drops_by_luk2: 0%drops_by_luk2: 1%" /root/rAthena/conf/battle/drops.conf

# // Make broadcast ** Player1 won Pupa's Pupa Card (chance 0.01%) ***
# // This can be set to any value between 0~10000.
# // Note: It also announces STEAL skill usage with rare items
# // 0 = don't show announces at all
# // 1 = show announces for 0.01% drop chance items
# // 333 = show announces for 3.33% or lower drop chance items
# // 10000 = show announces for all items
# rare_drop_announce: 0
sed -i "s%rare_drop_announce: 0%rare_drop_announce: 1%" /root/rAthena/conf/battle/drops.conf




# ===================  exp.conf  =============================== #
# // Rate at which exp. is given. (Note 2)
# base_exp_rate: 100
sed -i "s%base_exp_rate: 100%base_exp_rate: 10000%" /root/rAthena/conf/battle/exp.conf

# // Rate at which job exp. is given. (Note 2)
# job_exp_rate: 100
sed -i "s%job_exp_rate: 100%job_exp_rate: 10000%" /root/rAthena/conf/battle/exp.conf
# ===================  feature.conf  =========================== #


# ===================  client.conf  ============================ #
# // Valid range of dyes and styles on the client.
# min_hair_style: 0
# max_hair_style: 42
# min_hair_color: 0
# max_hair_color: 8
# min_cloth_color: 0 
# max_cloth_color: 7
# min_body_style: 0
# max_body_style: 1

sed -i "s%max_hair_style: 42%max_hair_style: 82%" /root/rAthena/conf/battle/client.conf
sed -i "s%max_hair_color: 8%max_hair_color: 33%" /root/rAthena/conf/battle/client.conf
sed -i "s%max_cloth_color: 7%max_cloth_color: 34%" /root/rAthena/conf/battle/client.conf
sed -i "s%max_body_style: 1%max_body_style: 1%" /root/rAthena/conf/battle/client.conf


# ===================  gm.conf  ============================== #


# ===================  guild.conf  =========================== #
# // Maximum castles one guild can own (0 = unlimited)
# guild_max_castles: 0
sed -i "s%guild_max_castles: 0%guild_max_castles: 4%" /root/rAthena/conf/battle/guild.conf
# ===================  homunc.conf  ========================== #


# ===================  items.conf  =========================== #


# ===================  misc.conf  ============================ #


# ===================  monster.conf  ========================= #

#  canavarların hp bar ve benzeri bilgilerini görünür yapmak için
#  Not: sadece /showname (ince yazı karakteri ile çalışıyor)
# // Display some mob info next to their name? (add as needed)
# // (does not works on guardian or Emperium)
# // 1: Display mob HP (Hp/MaxHp format)
# // 2: Display mob HP (Percent of full life format)
# // 4: Display mob's level
#show_mob_info: 5    //default 0
sed -i "s%show_mob_info: 0%show_mob_info: 5%" /root/rAthena/conf/battle/monster.conf

# ===================  party.conf  =========================== #






# ===================  pet.conf  ============================ #


# ===================  player.conf  ========================= #

# ===================  skill.conf  ========================== #
# // The rate of time it takes to cast a spell (Note 2, 0 = No casting time)
# casting_rate: 100
sed -i "s%casting_rate: 100%casting_rate: 0%" /root/rAthena/conf/battle/skill.conf

# // Does the delay time depend on the caster's DEX and/or AGI? (Note 1)
# // Note: On Official servers, neither Dex nor Agi affect delay time
# delay_dependon_dex: no
# delay_dependon_agi: no
sed -i "s%delay_dependon_dex: no%delay_dependon_dex: yes%" /root/rAthena/conf/battle/skill.conf
sed -i "s%delay_dependon_agi: no%delay_dependon_agi: no%" /root/rAthena/conf/battle/skill.conf
# ===================  status.conf  ========================= #


