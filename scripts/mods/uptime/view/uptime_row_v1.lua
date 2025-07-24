local mod = get_mod("uptime")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

local row_widget_def = UIWidget.create_definition({
    {
        pass_type = "texture",
        style_id = "buff_icon",
        value = "content/ui/materials/icons/buffs/hud/buff_container_with_background",
        style = {
            size = {
                30,
                30,
            },
            material_values = {}
        }
    },
    {
        value_id = "row_text",
        style_id = "text",
        pass_type = "text",
        style = {
            line_spacing = 1.2,
            font_size = 22,
            drop_shadow = true,
            font_type = "machine_medium",
            size = { 900, 30 },
            offset = { 45, 0, 0 }
        },
    },
}, "uptime_rows")

function create_row_widget_v1(buff, index, _create_widget)
    local widget = _create_widget("row" .. index, row_widget_def)

    local material = widget.style.buff_icon.material_values or {}
    material.talent_icon = buff.icon
    material.gradient_map = buff.gradient_map
    widget.style.buff_icon.material_values = material

    -- Format the main uptime percentage
    local text = string.format("%.1f%%", buff.uptime_percentage)

    -- Add combat uptime percentage if available
    if buff.uptime_combat_percentage then
        text = text .. string.format(" (%.1f%%)", buff.uptime_combat_percentage)
    end

    -- Add stack information
    if buff.average_stacks and buff.average_stacks > 1 then
        text = text .. string.format(" | Avg: %.2f stacks", buff.average_stacks)

        -- Add combat stack information if available
        if buff.average_stacks_combat then
            text = text .. string.format(" (%.2f)", buff.average_stacks_combat)
        end
    end

    -- Add max stack information if available
    if buff.max_stacks and buff.max_stacks > 1 and buff.time_at_max_stack then
        local max_stack_percent = (buff.time_at_max_stack / buff.uptime) * 100
        text = text .. string.format(" | Max stack: %.1f%%", max_stack_percent)

        -- Add combat max stack information if available
        if buff.combat_time_at_max_stack and buff.uptime_combat then
            local combat_max_stack_percent = (buff.combat_time_at_max_stack / buff.uptime_combat) * 100
            text = text .. string.format(" (%.1f%%)", combat_max_stack_percent)
        end
    end

    widget.content.row_text = text

    return widget
end

return create_row_widget_v1