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


#  canavarların hp bar ve benzeri bilgilerini görünür yapmak için
# // Display some mob info next to their name? (add as needed)
# // (does not works on guardian or Emperium)
# // 1: Display mob HP (Hp/MaxHp format)
# // 2: Display mob HP (Percent of full life format)
# // 4: Display mob's level
#show_mob_info: 5    //default 0
sed -i "s%show_mob_info: 0%show_mob_info: 5%" /root/rAthena/conf/battle/monster.conf
