local mod = get_mod("uptime")
local buffs = {}
local mission_start_time = nil
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

mod.start_time = function(self)
    return mission_start_time
end

-- Helper function to calculate current uptime and stack average for active buffs
local function calculate_current_values(buff_data)
    local now = Managers.time:time("gameplay")
    local current_uptime = buff_data.total_uptime or 0
    local current_stack_time_product = buff_data.stack_time_product or 0

    -- If buff is active, add current session to uptime
    if buff_data.start_time then
        current_uptime = current_uptime + (now - buff_data.start_time)

        -- Update stack_time_product for current session
        if buff_data.last_stack_change_time then
            local duration = now - buff_data.last_stack_change_time
            current_stack_time_product = current_stack_time_product +
                    (buff_data.current_stack_count * duration)
        end
    end

    -- Calculate average stack count
    local avg_stacks = 0
    if current_uptime > 0 then
        avg_stacks = current_stack_time_product / current_uptime
    end

    return current_uptime, avg_stacks
end

-- Returns the buffs table with real-time values
mod.active_buffs = function()
    local now = Managers.time:time("gameplay")
    local result = {}

    -- Create a copy with real-time values
    for buff_name, buff_data in pairs(buffs) do
        result[buff_name] = table.clone(buff_data)

        -- Calculate real-time values for active buffs
        if buff_data.start_time then
            local current_uptime, avg_stacks = calculate_current_values(buff_data)
            result[buff_name].current_uptime = current_uptime
            result[buff_name].current_avg_stacks = avg_stacks
        else
            result[buff_name].current_uptime = buff_data.total_uptime or 0
            result[buff_name].current_avg_stacks = (buff_data.total_uptime and buff_data.total_uptime > 0)
                    and (buff_data.stack_time_product / buff_data.total_uptime) or 0
        end
    end

    return result
end

mod.try_start_tracking = function()
    if not mission_start_time then
        mission_start_time = Managers.time:time("gameplay")
        buffs = {}  -- Reset buffs table
        mod:echo("[Uptime] Tracking started.")
        return true
    else
        return false
    end
end

mod.try_end_tracking = function()
    local mission_end_time = Managers.time:time("gameplay")
    local mission_duration = mission_end_time - (mission_start_time or mission_end_time)

    mod:echo("[Uptime] Tracking ended.")
    -- Calculate final uptime for all active buffs
    for buff_name, buff_data in pairs(buffs) do
        if buff_data.start_time then
            -- Finalize stack tracking calculations for active buffs
            if buff_data.last_stack_change_time then
                local duration = mission_end_time - buff_data.last_stack_change_time
                buffs[buff_name].stack_time_product = (buff_data.stack_time_product or 0) +
                        (buff_data.current_stack_count * duration)
            end

            -- Calculate total uptime
            buffs[buff_name].total_uptime = (buff_data.total_uptime or 0) + (mission_end_time - buff_data.start_time)
            buffs[buff_name].start_time = nil
        end

        local buff_uptime = buff_data.total_uptime or 0
        local uptime_percent = (buff_uptime / mission_duration) * 100

        -- Calculate average stack count
        local avg_stacks = 0
        if buff_uptime > 0 then
            avg_stacks = buff_data.stack_time_product / buff_uptime
        end

        -- Display uptime percentage and average stack count
        mod:echo(string.format("%s: %.1f uptime, %.2f avg stacks", buff_name, uptime_percent, avg_stacks))
    end
    mission_start_time = nil
end

function track_buff(buff)
    buffs[buff:title()] = {
        icon = buff:_hud_icon(),
        gradient_map = buff:hud_icon_gradient_map(),
        total_uptime = 0,
        start_time = nil,
        -- Stack tracking data
        current_stack_count = 0,
        stack_time_product = 0, -- Sum of (stack_count * time_with_that_stack)
        last_stack_change_time = nil
    }
end

mod:hook_safe("PlayerUnitBuffExtension", "_on_add_buff", function(self, buff)
    local buff_title = buff:title()
    mod:echo(buff_title)

    -- Initialize buff data if it doesn't exist
    if not buffs[buff_title] then
        track_buff(buff)
    end

    -- Set start time if not already set
    if not buffs[buff_title].start_time then
        local now = Managers.time:time("gameplay")
        buffs[buff_title].start_time = now

        -- Initialize stack tracking
        local stackCount = buff:stat_buff_stacking_count()
        buffs[buff_title].current_stack_count = stackCount
        buffs[buff_title].last_stack_change_time = now

        --mod:echo("[Buff Tracker] Buff added: " .. buff_title)
    end
end)

mod:hook_safe("PlayerUnitBuffExtension", "_on_add_buff_stack", function(self, buff, previous_stack_count)
    local buff_title = buff:title()
    local newStackCount = buff:stat_buff_stacking_count()
    local now = Managers.time:time("gameplay")

    if not buffs[buff_title] then
        track_buff(buff)
        buffs[buff_title].start_time = now
    end
    -- Update stack tracking data if we're tracking this buff
    local now = Managers.time:time("gameplay")

    -- If we have a previous stack change time, calculate contribution to the average
    if buffs[buff_title].last_stack_change_time then
        local duration = now - buffs[buff_title].last_stack_change_time
        buffs[buff_title].stack_time_product = buffs[buff_title].stack_time_product +
                (buffs[buff_title].current_stack_count * duration)
    end

    -- Update current stack count and timestamp
    buffs[buff_title].current_stack_count = newStackCount
    buffs[buff_title].last_stack_change_time = now
end)

mod:hook_safe("PlayerUnitBuffExtension", "_on_remove_buff_stack", function(self, buff, previous_stack_count)
    local buff_title = buff:title()
    local newStackCount = buff:stat_buff_stacking_count()

    -- Update stack tracking data if we're tracking this buff
    if buffs[buff_title] and buffs[buff_title].start_time then
        local now = Managers.time:time("gameplay")

        -- If we have a previous stack change time, calculate contribution to the average
        if buffs[buff_title].last_stack_change_time then
            local duration = now - buffs[buff_title].last_stack_change_time
            buffs[buff_title].stack_time_product = buffs[buff_title].stack_time_product +
                    (buffs[buff_title].current_stack_count * duration)
        end

        -- Update current stack count and timestamp
        buffs[buff_title].current_stack_count = newStackCount
        buffs[buff_title].last_stack_change_time = now
    end
end)

mod:hook_safe("PlayerUnitBuffExtension", "_on_remove_buff", function(self, buff)
    local buff_title = buff:title()

    -- Check if we're tracking this buff and it has a start time
    if buffs[buff_title] and buffs[buff_title].start_time then
        local now = Managers.time:time("gameplay")

        -- Finalize stack tracking calculations
        if buffs[buff_title].last_stack_change_time then
            local duration = now - buffs[buff_title].last_stack_change_time
            buffs[buff_title].stack_time_product = buffs[buff_title].stack_time_product +
                    (buffs[buff_title].current_stack_count * duration)
        end

        -- Calculate total uptime
        buffs[buff_title].total_uptime = (buffs[buff_title].total_uptime or 0) + (now - buffs[buff_title].start_time)
        buffs[buff_title].start_time = nil
    end
end)