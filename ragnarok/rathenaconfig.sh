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
