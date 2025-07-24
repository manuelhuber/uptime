local mod = get_mod("uptime")
mod:io_dofile("uptime/scripts/mods/uptime/tracking/uptime_buff_tracking")
local DMF = get_mod("DMF")
local _os = DMF:persistent_table("_os")
_os.initialized = _os.initialized or false
if not _os.initialized then
    _os = DMF.deepcopy(Mods.lua.os)
end

--[[
    Buff Tracker with Stack Averaging

    This mod tracks buff uptime and calculates the average number of stacks for each buff.

    Stack Tracking Approach:
    1. For each buff, we track:
       - total_uptime: Total time the buff was active
       - current_stack_count: Current number of stacks
       - stack_time_product: Sum of (stack_count * time_with_that_stack)
       - last_stack_change_time: When the stack count last changed

    2. Time-weighted average calculation:
       - When stack count changes, we calculate: duration * current_stack_count
       - We add this to stack_time_product
       - Final average = stack_time_product / total_uptime

    This gives us a time-weighted average that accurately represents how many stacks
    the buff had on average during its active duration.
]]

mod.tracked_buffs = {}
mod.tracking_start_time = nil
local mission_name = ""

function mod:tracking_in_progress()
    return mod.tracking_start_time ~= nil
end

function mod:now()
    if not Managers.time:has_timer("gameplay") then
        mod:echo("need time, but gameplay time doesn't exist")
        return 0
    end
    return Managers.time:time("gameplay")
end

function mod:try_start_tracking(name)
    if mod:tracking_in_progress() then
        return false
    end
    mod.tracking_start_time = 0
    mod.tracked_buffs = {}
    mission_name = name
    mod:echo("[Uptime] Tracking started mission " .. name)
    return true
end

function mod:try_end_tracking()
    if not mod:tracking_in_progress() then
        return false
    end
    local mission_end_time = mod:now()

    mod:finalize_tracking(mission_end_time)

    local mission_duration = mission_end_time - (mod.tracking_start_time or mission_end_time)
    local player = Managers.player:local_player(1):name()
    mod:save_entry(mod.tracked_buffs, mission_name, mission_duration, player)
    mod.tracked_buffs = {}
    mod.tracking_start_time = nil
    mod:echo("[Uptime] Tracking ended.")
    return true
end