local mod = get_mod("uptime")
mod:io_dofile("uptime/scripts/mods/uptime/tracking/uptime_buff_tracking")
mod:io_dofile("uptime/scripts/mods/uptime/tracking/uptime_mission_tracking")

mod.mission_params = nil

function mod:try_start_tracking(params)
    if mod:tracking_in_progress() then
        return false
    end
    mod:start_mission_tracking()
    mod:start_buff_tracking()
    mod.mission_params = params
    return true
end

function mod:try_end_tracking()
    if not mod:tracking_in_progress() then
        return false
    end

    local mission = mod:end_mission_tracking()
    local buffs = mod:end_buff_tracking()

    local player = Managers.player:local_player(1):name()
    local params = mod.mission_params
    local entry = {
        buffs = buffs,
        mission = mission,
        mission_name = params.mission_name,
        player = player,
        meta_data = {
            mission_name = params.mission_name,
            player = player,
            mission_difficulty = params.mechanism_data.challenge,
            mission_modifier = params.mechanism_data.circumstance_name
        },
    }
    mod:save_entry(entry)
    mod:echo("Tracking ended.")
    return true
end