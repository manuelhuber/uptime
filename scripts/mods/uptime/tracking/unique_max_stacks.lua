local mod = get_mod("uptime")
local TalentSettings = mod:original_require("scripts/settings/talent/talent_settings")

local max_stacks = {
    -- https://github.com/Aussiemon/Darktide-Source-Code/blob/72cde1c088677d22b3830d9681d015167782b10a/scripts/settings/buff/archetype_buff_templates/ogryn_buff_templates.lua
    ogryn_reduce_damage_taken_per_bleed = TalentSettings.ogryn_2.defensive_1.max_stacks,
    ogryn_hitting_multiple_with_melee_grants_melee_damage_bonus = TalentSettings.ogryn_2.offensive_2_3.max_targets,

    -- https://github.com/Aussiemon/Darktide-Source-Code/blob/72cde1c088677d22b3830d9681d015167782b10a/scripts/settings/buff/archetype_buff_templates/psyker_buff_templates.lua
    psyker_overcharge_stance = TalentSettings.overcharge_stance.max_stacks,
    psyker_nearby_soulblaze_reduced_damage = TalentSettings.psyker.nearby_soublaze_defense.max_stacks,
}

return max_stacks