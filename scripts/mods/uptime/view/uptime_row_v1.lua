local mod = get_mod("uptime")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

--[[
entry = {
    name : string
    total_uptime : number
    uptime_percent : number
    avg_stacks : number
    icon : string
    gradient_map : string
    }
]]
function create_row_widget_v1(entry, index, _create_widget)
    local widget_def = UIWidget.create_definition({
        {
            pass_type = "texture",
            style_id = "icon",
            value = "content/ui/materials/icons/buffs/hud/buff_container_with_background",

            style = {
                size = {
                    30,
                    30,
                },
                material_values = {
                    talent_icon = entry.icon,
                    gradient_map = entry.gradient_map
                },
            }
        },
        {
            value_id = "text",
            style_id = "text",
            pass_type = "text",
            style = {
                line_spacing = 1.2,
                font_size = 30,
                drop_shadow = true,
                font_type = "machine_medium",
                size = { 300, 30 },
                offset = { 45, 0, 0 }
            },
        },
    }, "uptime_rows")
    local widget = _create_widget("row" .. index, widget_def)

    local text = string.format("%.1f%%", entry.uptime_percent)
    if (entry.avg_stacks > 1) then
        local avg_stacks = entry.avg_stacks or 0
        text = text .. string.format(" (%.2f stacks)", avg_stacks)
    end
    widget.content.text = text

    return widget
end

return create_row_widget_v1