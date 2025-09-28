local mod = get_mod("uptime")
local weapon_tracking = {}

function mod:start_weapon_tracking()
    weapon_tracking = {}
end

function mod:end_weapon_tracking()
    return weapon_tracking
end

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_wielded", function(self, slot_name)
    if not mod:tracking_in_progress() then
        return
    end
    add_wielded(self, slot_name, true)
end)

mod:hook_safe(CLASS.PlayerUnitWeaponExtension, "on_slot_unwielded", function(self, slot_name)
    if not mod:tracking_in_progress() then
        return
    end
    add_wielded(self, slot_name, false)
end)

function add_wielded(self, slot_name, equipped, t)
    local name = get_name(self, slot_name)
    if not name then
        return
    end
    if not weapon_tracking[name] then
        weapon_tracking[name] = init_slot(name)
    end
    table.insert(weapon_tracking[name].events, {
        equipped = equipped,
        time = mod:now()
    })
end

function get_name(self, slot_name)
    local weapon = self._weapons[slot_name]
    local item = weapon.item
    if not mod.items.is_weapon(item.item_type) then
        return nil
    end
    return mod.items.get_name(item)
end

function init_slot(slot)
    return {
        name = slot,
        events = {}
    }
end