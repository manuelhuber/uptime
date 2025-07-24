local mod = get_mod("uptime")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

local columns = {
    {
        id = "uptime",
        display_name = "loc_uptime_header",
        width = 75,
        accessor = function(buff)
            return string.format("%.f%%", buff.uptime)
        end
    }
}

local pass_template = {
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
}

local offset = 45
for _, column in pairs(columns) do
    local template = {
        pass_type = "text",
        value_id = column.id,
        style_id = "text",
        style = {
            line_spacing = 1.2,
            font_size = 22,
            drop_shadow = true,
            font_type = "machine_medium",
            size = { 900, 30 },
            offset = { offset, 0, 0 }
        },
    }
    pass_template[#pass_template + 1] = template
    offset = offset + column.width
end

local row_widget_def = UIWidget.create_definition(pass_template, "uptime_rows")

function create_header_row_widget_v1(_create_widget)
    local widget = _create_widget("header_row", row_widget_def)

    for _, column in pairs(columns) do
        widget.content[column.id] = mod:localize(column.display_name)
    end
    widget.style.buff_icon.visible = false

    return widget
end

function create_row_widget_v1(buff, index, _create_widget)
    local widget = _create_widget("row" .. index, row_widget_def)

    local material = widget.style.buff_icon.material_values or {}
    material.talent_icon = buff.icon
    material.gradient_map = buff.gradient_map
    widget.style.buff_icon.material_values = material

    for _, column in pairs(columns) do
        widget.content[column.id] = column.accessor(buff)
    end

    return widget
end

return {
    create_header_row = create_header_row_widget_v1,
    create_row = create_row_widget_v1
}