local mod = get_mod("uptime")
local DMF = get_mod("dmf")

local os = DMF:persistent_table("_os")
os.initialized = os.initialized or false
if not os.initialized then
    os = DMF.deepcopy(Mods.lua.os)
end

mod.os = os