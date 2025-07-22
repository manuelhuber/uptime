local mod = get_mod("uptime")
local buffs = {}
local mission_start_time = nil

local displayed_buff_categories = {
    talents = true,
    weapon_traits = true,
    talents_secondary = true,
}
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

mod.ignore_buff = function(self, buff_data)
    local buff_instance = buff_data.buff_instance
    local hud_data = buff_instance:get_hud_data()
    local buff_template = buff_instance:template()
    local buff_category = buff_template.buff_category
    local wrong_category = not displayed_buff_categories[buff_category]
    local no_stacks = buff_instance:stat_buff_stacking_count() == 0
    local is_debuff = buff_instance:is_negative()
    local not_shown = not buff_data.show
    local not_active = not hud_data.is_active
    if (wrong_category or no_stacks or is_debuff or not_shown or not_active) then
        return true
    end
    return false
end

mod.update_buff = function(self, buff_instance, now)
    if (not buff_instance or not buff_instance:title()) then
        mod:echo("what is going on?")
    end
    local buff_title = buff_instance:title()
    local stack_count = buff_instance:stat_buff_stacking_count()
    -- Mark this buff as currently active
    -- Initialize buff data if it doesn't exist
    if not buffs[buff_title] then
        buffs[buff_title] = {
            icon = buff_instance:_hud_icon(),
            gradient_map = buff_instance:hud_icon_gradient_map(),
            total_uptime = 0,
            start_time = now,
            current_stack_count = stack_count,
            stack_time_product = 0,
            last_stack_change_time = now
        }
        -- If buff exists but was inactive, mark it as active again
    elseif not buffs[buff_title].start_time then
        buffs[buff_title].start_time = now
        buffs[buff_title].current_stack_count = stack_count
        buffs[buff_title].last_stack_change_time = now
        -- If stack count changed, update the stack tracking data
    elseif buffs[buff_title].current_stack_count ~= stack_count then
        -- Calculate contribution to the average from previous stack count
        if buffs[buff_title].last_stack_change_time then
            local duration = now - buffs[buff_title].last_stack_change_time
            buffs[buff_title].stack_time_product = buffs[buff_title].stack_time_product +
                    (buffs[buff_title].current_stack_count * duration)
        end

        -- Update current stack count and timestamp
        buffs[buff_title].current_stack_count = stack_count
        buffs[buff_title].last_stack_change_time = now
    end
    return true
end

-- Replace the current _update_buffs hook with this enhanced version
mod:hook_safe("HudElementPlayerBuffs", "_update_buffs", function(self)
    local active_buffs_data = self._active_buffs_data
    local now = Managers.time:time("gameplay")

    -- Track which buffs are currently active to detect removed buffs later
    local currently_active_buffs = {}

    -- Process all active buffs
    for i = 1, #active_buffs_data do
        local buff_data = active_buffs_data[i]
        local buff_instance = buff_data.buff_instance
        if not buff_data.remove and buff_instance then
            local ignore = mod:ignore_buff(buff_data)
            local buff_title = buff_instance:title()
            if (not ignore) then
                mod:update_buff(buff_instance, now)
                currently_active_buffs[buff_title] = true
            end
        end
    end

    -- Handle buffs that are no longer active
    for buff_title, buff_data in pairs(buffs) do
        if buff_data.start_time and not currently_active_buffs[buff_title] then
            -- Finalize stack tracking calculations
            if buff_data.last_stack_change_time then
                local duration = now - buff_data.last_stack_change_time
                buffs[buff_title].stack_time_product = buff_data.stack_time_product +
                        (buff_data.current_stack_count * duration)
            end

            -- Calculate total uptime
            buffs[buff_title].total_uptime = (buff_data.total_uptime or 0) + (now - buff_data.start_time)
            buffs[buff_title].start_time = nil
        end
    end
end)