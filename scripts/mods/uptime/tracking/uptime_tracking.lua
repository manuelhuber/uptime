local mod = get_mod("uptime")
mod:io_dofile("uptime/scripts/mods/uptime/tracking/uptime_buff_tracking")
mod:io_dofile("uptime/scripts/mods/uptime/tracking/uptime_mission_tracking")

local mission_name = ""

function mod:try_start_tracking(name)
    if mod:tracking_in_progress() then
        return false
    end
    mod:start_mission_tracking()
    mod:start_buff_tracking()
    mission_name = name
    mod:echo("[Uptime] Tracking started mission " .. name)
    return true
end

function mod:try_end_tracking()
    if not mod:tracking_in_progress() then
        return false
    end

    local mission = mod:end_mission_tracking()
    local buffs = mod:end_buff_tracking()

    local player = Managers.player:local_player(1):name()
    local entry = {
        buffs = buffs,
        mission = mission,
        mission_name = mission_name,
        player = player
    }
    mod:save_entry(entry)
    mod:echo("[Uptime] Tracking ended.")
    return true
end