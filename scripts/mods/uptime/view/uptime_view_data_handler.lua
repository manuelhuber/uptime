local mod = get_mod("uptime")

function mod:generate_display_values(entry)
    local mission = entry.mission
    local mission_display_values = generate_display_values_for_mission(mission)
    local buff_display_values = generate_display_values_for_buffs(mission, entry.buffs)
    return {
        mission = mission_display_values,
        buffs = buff_display_values
    }
end

function generate_display_values_for_mission(mission)
    -- Calculate total mission time (end_time - start_time)
    local total_time = mission.end_time - mission.start_time

    -- Calculate total combat time by summing up all combat sections
    local combat_time = calculate_total_combat_time(mission)
    local combats = mission.combats or {}

    -- Calculate combat percentage (avoid division by zero)
    local combat_percentage = 0
    if total_time > 0 then
        combat_percentage = (combat_time / total_time) * 100
    end

    return {
        time = total_time,
        combat_time = combat_time,
        combat_percentage = combat_percentage
    }
end

function generate_display_values_for_buffs(mission, buffs)
    local buff_display_values = {}

    if buffs then
        for buff_name, buff_data in pairs(buffs) do
            buff_display_values[buff_name] = generate_display_values_for_buff(mission, buff_data)
        end
    end
    return buff_display_values
end
function generate_display_values_for_buff(mission, buff)
    local max_stacks = buff.max_stacks or 1

    local active_periods = extract_active_periods(buff.events)
    local total_uptime = calculate_uptime(active_periods)

    local mission_time = mission.end_time - mission.start_time
    local combat_time = calculate_total_combat_time(mission)
    local uptime_percentage = (total_uptime / mission_time) * 100

    -- Initialize combat uptime variables
    local uptime_combat = 0
    local uptime_combat_percentage = 0
    local total_combat_time = 0

    -- Process buff events to calculate combat uptime
    if buff.events and mission.combats then
        uptime_combat, uptime_combat_percentage, total_combat_time = calculate_combat_uptime(active_periods, mission)
    end

    -- Calculate time per stack
    local time_per_stack = calculate_time_per_stack(buff.events, max_stacks)

    -- Calculate combat time per stack
    local combat_time_per_stack = calculate_combat_time_per_stack(buff.events, mission, max_stacks)
    local combat_percentage_per_stack = calculate_combat_percentage_per_stack(combat_time_per_stack, combat_time)

    -- Calculate time at max stack
    local time_at_max_stack = time_per_stack[max_stacks] or 0
    local combat_time_at_max_stack = combat_time_per_stack[max_stacks] or 0
    local combat_percentage_at_max_stack = combat_time_at_max_stack / uptime_combat * 100

    -- Calculate average stacks
    local average_stacks = calculate_average_stacks(time_per_stack, total_uptime, max_stacks)
    local average_stacks_combat = calculate_average_stacks(combat_time_per_stack, uptime_combat, max_stacks)

    return {
        uptime = total_uptime,
        uptime_percentage = uptime_percentage,
        uptime_combat = uptime_combat,
        uptime_combat_percentage = uptime_combat_percentage,

        max_stacks = max_stacks,
        stackable = buff.stackable,

        time_per_stack = time_per_stack,
        combat_time_per_stack = combat_time_per_stack,
        combat_percentage_per_stack = combat_percentage_per_stack,

        time_at_max_stack = time_at_max_stack,
        combat_time_at_max_stack = combat_time_at_max_stack,
        combat_percentage_at_max_stack = combat_percentage_at_max_stack,

        average_stacks = average_stacks,
        average_stacks_combat = average_stacks_combat,

        icon = buff.icon,
        gradient_map = buff.gradient_map,

        talents = buff.related_talents
    }
end

-- Extract active periods from buff events
function extract_active_periods(buff_events)
    local active_periods = {}
    local current_period = nil

    for _, event in ipairs(buff_events) do
        if event.type == "add" then
            current_period = {
                start_time = event.time,
                end_time = nil
            }
        elseif event.type == "remove" and current_period then
            current_period.end_time = event.time
            table.insert(active_periods, current_period)
            current_period = nil
        end
    end

    return active_periods
end

-- Calculate uptime percentage based on mission time
function calculate_uptime(active_periods)
    local total_time = 0
    for _, period in ipairs(active_periods) do
        total_time = total_time + period.end_time - period.start_time
    end
    return total_time
end

-- Calculate uptime percentage based on mission time
function calculate_uptime_percentage(total_uptime, mission_time)
    local uptime_percentage = 0
    if mission_time > 0 then
        uptime_percentage = (total_uptime / mission_time) * 100
    end
    return uptime_percentage
end


-- Calculate total combat time in mission
function calculate_total_combat_time(mission)
    local total_combat_time = 0
    local combats = mission.combats or {}

    for _, combat in ipairs(combats) do
        local combat_start = math.max(combat.start_time, mission.start_time)
        local combat_end = math.min(combat.end_time, mission.end_time)

        if combat_end > combat_start then
            total_combat_time = total_combat_time + (combat_end - combat_start)
        end
    end

    return total_combat_time
end

-- Calculate combat uptime and percentage
function calculate_combat_uptime(active_periods, mission)
    local uptime_combat = 0
    local uptime_combat_percentage = 0

    -- Calculate overlap between active periods and combat periods
    for _, active_period in ipairs(active_periods) do
        for _, combat in ipairs(mission.combats) do
            local overlap_start = math.max(active_period.start_time, combat.start_time)
            local overlap_end = math.min(active_period.end_time, combat.end_time)

            if overlap_end > overlap_start then
                uptime_combat = uptime_combat + (overlap_end - overlap_start)
            end
        end
    end

    -- Calculate combat uptime percentage
    local total_combat_time = calculate_total_combat_time(mission)

    if total_combat_time > 0 then
        uptime_combat_percentage = (uptime_combat / total_combat_time) * 100
    end

    return uptime_combat, uptime_combat_percentage, total_combat_time
end

-- Calculate time spent at each stack level
function calculate_time_per_stack(buff_events, max_stacks)
    local time_per_stack = {}
    for i = 1, max_stacks do
        time_per_stack[i] = 0
    end

    if buff_events then
        local current_stack = 0
        local last_time = nil

        for _, event in ipairs(buff_events) do
            -- If we have a previous event, calculate time at that stack level
            if last_time and current_stack > 0 and current_stack <= max_stacks then
                local duration = event.time - last_time
                time_per_stack[current_stack] = time_per_stack[current_stack] + duration
            end

            -- Update stack count and time for next calculation
            if event.type == "add" or event.type == "stack_change" then
                current_stack = event.stack_count or 1
            elseif event.type == "remove" then
                current_stack = 0
            end

            last_time = event.time
        end
    end

    return time_per_stack
end

function calculate_combat_time_per_stack(buff_events, mission, max_stacks)
    local combat_time_per_stack = {}
    for i = 1, max_stacks do
        combat_time_per_stack[i] = 0
    end

    if buff_events and mission.combats then
        local current_stack = 0
        local last_time = nil

        for _, event in ipairs(buff_events) do
            -- If we have a previous event and valid stack, calculate combat time for that stack
            if last_time and current_stack > 0 and current_stack <= max_stacks then
                -- For each period between events, check overlap with combat
                for _, combat in ipairs(mission.combats) do
                    local period_start = last_time
                    local period_end = event.time

                    local overlap_start = math.max(period_start, combat.start_time)
                    local overlap_end = math.min(period_end, combat.end_time)

                    if overlap_end > overlap_start then
                        combat_time_per_stack[current_stack] = combat_time_per_stack[current_stack] + (overlap_end - overlap_start)
                    end
                end
            end

            -- Update stack count and time for next calculation
            if event.type == "add" or event.type == "stack_change" then
                current_stack = event.stack_count or 0
            elseif event.type == "remove" then
                current_stack = 0
            end

            last_time = event.time
        end
    end

    return combat_time_per_stack
end

function calculate_combat_percentage_per_stack(combat_time_per_stack, combat_time)
    local percentages = {}
    for i, value in pairs(combat_time_per_stack) do
        percentages[i] = (value / combat_time) * 100
    end
    return percentages
end

function calculate_average_stacks(time_per_stack, total_uptime, max_stacks)
    local average_stacks = 0

    if total_uptime > 0 then
        local weighted_sum = 0
        for stack = 1, max_stacks do
            weighted_sum = weighted_sum + (stack * time_per_stack[stack])
        end
        average_stacks = weighted_sum / total_uptime
    end

    return average_stacks
end