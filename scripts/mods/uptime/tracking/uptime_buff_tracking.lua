local mod = get_mod("uptime")
local item_lib = mod:io_dofile("uptime/scripts/mods/uptime/libs/items")

--[[
    Buff Event Tracking Data Model
    
    This module implements an event-based tracking system for buffs during missions.
    
    Data Model:
    1. Mission Data:
       - start_time: When the mission started
       - end_time: When the mission ended
       - combat_sections: Array of {start_time, end_time} for combat sections
    
    2. Buff Data:
       - icon: Buff icon for UI display
       - gradient_map: Gradient map for UI display
       - stackable: Whether the buff can stack
       - max_stacks: Maximum number of stacks for this buff
       - events: Array of buff events, each containing:
         * type: "add", "remove", or "stack_change"
         * time: When the event occurred
         * stack_count: Current stack count (for "add" and "stack_change" events)
    
    3. Event Types:
       - "add": Buff was added (became active)
       - "remove": Buff was removed (became inactive)
       - "stack_change": Stack count changed while buff was active
    
    This event-based approach allows for:
    - Precise tracking of when buffs are active
    - Tracking individual stack changes
    - Calculating uptime and average stacks from event data
    - Supporting future analytics on buff timing and patterns
]]

mod.tracked_buffs = {}

local displayed_buff_categories = {
    talents = true,
    weapon_traits = true,
    talents_secondary = true,
}

function mod:start_buff_tracking()
    mod.tracked_buffs = {}
end

function mod:end_buff_tracking()
    mod:finalize_tracking(mod.mission_tracking.end_time)
    return mod.tracked_buffs
end

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
        -- Check if the buff was active but is no longer in the currently active buffs
        if buff_data.is_active and not currently_active_buffs[buff_title] then
            -- Record a remove event
            table.insert(buff_data.events, {
                type = "remove",
                time = now
            })

            -- Mark the buff as inactive
            tracked_buffs[buff_title].is_active = false
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

    local item_name = nil
    if (buff_instance._template_context or {}).source_item then
        local item = buff_instance._template_context.source_item
        item_name = item_lib.get_name(item)
    end

    -- Initialize buff data if it doesn't exist
    if not buffs[buff_title] then
        local template = buff_instance:template()
        buffs[buff_title] = {
            icon = buff_instance:_hud_icon(),
            gradient_map = buff_instance:hud_icon_gradient_map(),
            stackable = (buff_instance:max_stacks() or 0) > 1,
            max_stacks = buff_instance:max_stacks() or 1,
            events = {},
            is_active = true,
            current_stack_count = stack_count,
            category = template.buff_category,
            related_talents = template.related_talents,
            source_item_name = item_name,
            --source_item_id = ((buff_instance._template_context or {}).source_item or {}).__gear_id,
            --source_item = ((buff_instance._template_context or {}).source_item or nil),
            --instance = buff_instance,
        }

        -- Record an add event
        table.insert(buffs[buff_title].events, {
            type = "add",
            time = now,
            stack_count = stack_count
        })
        -- If buff exists but was inactive, mark it as active again
    elseif not buffs[buff_title].is_active then
        buffs[buff_title].is_active = true
        buffs[buff_title].current_stack_count = stack_count

        -- Record an add event
        table.insert(buffs[buff_title].events, {
            type = "add",
            time = now,
            stack_count = stack_count
        })
        -- If stack count changed, record a stack change event
    elseif buffs[buff_title].current_stack_count ~= stack_count then
        -- Record a stack change event
        table.insert(buffs[buff_title].events, {
            type = "stack_change",
            time = now,
            stack_count = stack_count
        })

        -- Update current stack count
        buffs[buff_title].current_stack_count = stack_count
    end

    return true
end

function mod:finalize_tracking(tracking_end_time)
    for buff_name, buff_data in pairs(mod.tracked_buffs) do
        -- If the buff is still active at the end of tracking, add a remove event
        if buff_data.is_active then
            table.insert(buff_data.events, {
                type = "remove",
                time = tracking_end_time
            })

            buff_data.is_active = false
        end
    end
end