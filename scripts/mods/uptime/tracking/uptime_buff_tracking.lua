local mod = get_mod("uptime")

local displayed_buff_categories = {
    talents = true,
    weapon_traits = true,
    talents_secondary = true,
}

mod:hook_safe("HudElementPlayerBuffs", "_update_buffs", function(self)
    if not mod:tracking_in_progress() then
        return
    end

    local active_buffs_data = self._active_buffs_data
    local now = mod:now()

    local currently_active_buffs = update_active_buffs(mod.tracked_buffs, active_buffs_data, now)
    update_removed_buffs(mod.tracked_buffs, currently_active_buffs, now)
end)

function update_active_buffs(tracked_buffs, active_buffs_data, now)
    local currently_active_buffs = {}

    -- Process all active buffs
    for i = 1, #active_buffs_data do
        local buff_data = active_buffs_data[i]
        local buff_instance = buff_data.buff_instance
        if not buff_data.remove and buff_instance then
            local ignore = ignore_buff(buff_data)
            local buff_title = buff_instance:title()
            if (not ignore) then
                update_buff(tracked_buffs, buff_instance, now)
                currently_active_buffs[buff_title] = true
            end
        end
    end
    return currently_active_buffs
end

function update_removed_buffs(tracked_buffs, currently_active_buffs, now)
    -- Handle buffs that are no longer active
    for buff_title, buff_data in pairs(tracked_buffs) do
        if buff_data.start_time and not currently_active_buffs[buff_title] then
            -- Finalize stack tracking calculations
            if buff_data.last_stack_change_time then
                local duration = now - buff_data.last_stack_change_time
                tracked_buffs[buff_title].stack_time_product = buff_data.stack_time_product +
                        (buff_data.current_stack_count * duration)
            end

            -- Calculate total uptime
            tracked_buffs[buff_title].total_uptime = (buff_data.total_uptime or 0) + (now - buff_data.start_time)
            tracked_buffs[buff_title].start_time = nil
        end
    end
end

function ignore_buff(buff_data)
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

function update_buff(buffs, buff_instance, now)
    local buff_title = buff_instance:title()
    local stack_count = buff_instance:stat_buff_stacking_count()
    -- Initialize buff data if it doesn't exist
    if not buffs[buff_title] then
        buffs[buff_title] = {
            icon = buff_instance:_hud_icon(),
            gradient_map = buff_instance:hud_icon_gradient_map(),
            stackable = (buff_instance:max_stacks() or 0) > 1,
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

function mod:finalize_tracking(tracking_end_time)
    for buff_name, buff_data in pairs(mod.tracked_buffs) do
        if buff_data.start_time then
            -- Finalize stack tracking calculations for active buffs
            if buff_data.last_stack_change_time then
                local duration = tracking_end_time - buff_data.last_stack_change_time
                mod.tracked_buffs[buff_name].stack_time_product = (buff_data.stack_time_product or 0) +
                        (buff_data.current_stack_count * duration)
            end

            -- Calculate total uptime
            mod.tracked_buffs[buff_name].total_uptime = (buff_data.total_uptime or 0) + (mission_end_time - buff_data.start_time)
            mod.tracked_buffs[buff_name].start_time = nil
        end
    end
end