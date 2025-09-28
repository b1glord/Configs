#!/bin/bash
# ======================================================
# Fast PvP Config Patcher for rAthena
# Versiyon: 1.0
# Açıklama: skill.conf üzerinde PvP hızlandırma preset uygular
# ======================================================

CONF="conf/battle/skill.conf"

# CAST & DELAY
sed -i 's/^casting_rate:.*/casting_rate: 0/' $CONF
sed -i 's/^delay_rate:.*/delay_rate: 40/' $CONF
sed -i 's/^delay_dependon_dex:.*/delay_dependon_dex: no/' $CONF
sed -i 's/^delay_dependon_agi:.*/delay_dependon_agi: no/' $CONF
sed -i 's/^min_skill_delay_limit:.*/min_skill_delay_limit: 80/' $CONF
sed -i 's/^amotion_min_skill_delay:.*/amotion_min_skill_delay: yes/' $CONF
sed -i 's/^default_walk_delay:.*/default_walk_delay: 220/' $CONF

# INSTA & VARIABLE CAST
sed -i 's/^castrate_dex_scale:.*/castrate_dex_scale: 140/' $CONF
sed -i 's/^vcast_stat_scale:.*/vcast_stat_scale: 420/' $CONF
sed -i 's/^skill_amotion_leniency:.*/skill_amotion_leniency: 0/' $CONF

# COMBAT
sed -i 's/^combo_delay_rate:.*/combo_delay_rate: 80/' $CONF
sed -i 's/^skill_delay_attack_enable:.*/skill_delay_attack_enable: yes/' $CONF

# MENZIL & DUVAR
sed -i 's/^skillrange_by_distance:.*/skillrange_by_distance: 14/' $CONF
sed -i 's/^skillrange_from_weapon:.*/skillrange_from_weapon: 0/' $CONF
sed -i 's/^skill_wall_check:.*/skill_wall_check: yes/' $CONF

# GROUND SKILLS
sed -i 's/^land_skill_limit:.*/land_skill_limit: 12/' $CONF
sed -i 's/^clear_skills_on_death:.*/clear_skills_on_death: 0/' $CONF
sed -i 's/^clear_skills_on_warp:.*/clear_skills_on_warp: 15/' $CONF

# TRAPS
sed -i 's/^gvg_traps_target_all:.*/gvg_traps_target_all: 1/' $CONF
sed -i 's/^traps_setting:.*/traps_setting: 1/' $CONF

# DAMAGE & OZEL
sed -i 's/^skill_min_damage:.*/skill_min_damage: 0/' $CONF
sed -i 's/^auto_counter_type:.*/auto_counter_type: 15/' $CONF
sed -i 's/^backstab_bow_penalty:.*/backstab_bow_penalty: yes/' $CONF

# GUILD
sed -i 's/^emergency_call:.*/emergency_call: 11/' $CONF
sed -i 's/^guild_aura:.*/guild_aura: 31/' $CONF

# EQ & REFLECT
sed -i 's/^eq_single_target_reflectable:.*/eq_single_target_reflectable: yes/' $CONF
sed -i 's/^devotion_level_difference:.*/devotion_level_difference: 15/' $CONF

# SG & GUNLER
sed -i 's/^allow_skill_without_day:.*/allow_skill_without_day: yes/' $CONF

# EIGHT PATH
sed -i 's/^skill_eightpath_algorithm:.*/skill_eightpath_algorithm: no/' $CONF
sed -i 's/^skill_eightpath_same_cell:.*/skill_eightpath_same_cell: yes/' $CONF

# SONG BUFF
sed -i 's/^refresh_song:.*/refresh_song: yes/' $CONF
sed -i 's/^refresh_song_icon:.*/refresh_song_icon: yes/' $CONF

# RENEWAL SABIT CAST
sed -i 's/^default_fixed_castrate:.*/default_fixed_castrate: 10/' $CONF

echo "✅ Fast PvP preset başarıyla uygulandı: $CONF"
