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

mod.active_buffs = function()
    return buffs
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
mod:hook_safe("PlayerUnitBuffExtension", "_on_add_buff", function(self, buff)
    local buff_title = buff:title()

    -- Initialize buff data if it doesn't exist
    if not buffs[buff_title] then
        buffs[buff_title] = {
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