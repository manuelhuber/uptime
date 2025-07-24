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

    mod:end_mission_tracking()
    mod:end_buff_tracking()

    local mission_duration = mod.mission_tracking.end_time - mod.mission_tracking.start_time
    local player = Managers.player:local_player(1):name()
    mod:save_entry(mod.tracked_buffs, mission_name, mission_duration, player)
    mod:echo("[Uptime] Tracking ended.")
    return true
end