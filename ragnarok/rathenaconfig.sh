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




# ===================  Conf/Battle Settings  =================== #
# ============================================================== #

# ===================  battle.conf  ============================ #


# ===================  battleground.conf  ====================== #


# ===================  client.conf  ============================ #


# ===================  drops.conf  ============================= #
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

// Does the delay time depend on the caster's DEX and/or AGI? (Note 1)
// Note: On Official servers, neither Dex nor Agi affect delay time
delay_dependon_dex: no
delay_dependon_agi: no
sed -i "s%delay_dependon_dex: no%delay_dependon_dex: yes%" /root/rAthena/conf/battle/skill.conf
sed -i "s%delay_dependon_agi: no%delay_dependon_agi: no%" /root/rAthena/conf/battle/skill.conf
# ===================  status.conf  ========================= #


