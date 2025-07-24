local mod = get_mod("uptime")
local psyker_talents = mod:original_require("scripts/settings/ability/archetype_talents/talents/psyker_talents")
local ogryn_talents = mod:original_require("scripts/settings/ability/archetype_talents/talents/ogryn_talents")
local zealot_talents = mod:original_require("scripts/settings/ability/archetype_talents/talents/zealot_talents")
local veteran_talents = mod:original_require("scripts/settings/ability/archetype_talents/talents/veteran_talents")
local arbites_talents = mod:original_require("scripts/settings/ability/archetype_talents/talents/adamant_talents")

local all_trees = {
    psyker_talents, ogryn_talents, zealot_talents, veteran_talents, arbites_talents
}

function get_talent(talent_id)
    for _, tree in pairs(all_trees) do
        if tree.talents[talent_id] then
            return tree.talents[talent_id]
        end
    end
    return nil
end

return get_talent