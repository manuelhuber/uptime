local mod = get_mod("uptime")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local get_talent = mod:io_dofile("uptime/scripts/mods/uptime/libs/talents")
local psyker_talents = mod:original_require("scripts/settings/ability/archetype_talents/talents/psyker_talents")
local ROW_HEIGHT = 30

local is_stackable = function(buff)
    return buff.stackable
end

local columns = {
    {
        id = "uptime_combat_percentage",
        display_name = "loc_uptime_header",
        width = 75,
        accessor = function(buff)
            return string.format("%.1f%%", buff.uptime_combat_percentage)
        end
    }, {
        id = "average_stacks_combat",
        display_name = "loc_avg_stacks_header",
        width = 75,
        condition = is_stackable,
        accessor = function(buff)
            return string.format("%.2f", buff.average_stacks_combat)
        end
    }, {
        id = "combat_percentage_at_max_stack",
        display_name = "loc_percentage_at_max_stacks_header",
        width = 75,
        condition = is_stackable,
        accessor = function(buff)
            return string.format("%.1f%%", buff.combat_percentage_at_max_stack)
        end
    }, {
        id = "talent_name",
        display_name = "loc_talent_header",
        width = 200,
        accessor = function(buff)
            if buff.talents then
                local talent_id = buff.talents[1]
                local talent = get_talent(talent_id)
                if talent then
                    return Managers.localization:localize(talent.display_name)
                end
            end
            return ""
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
            --vertical_alignment = "center",
            material_values = {}
        }
    },
}

local offset = 35
for _, column in pairs(columns) do
    local template = {
        pass_type = "text",
        value_id = column.id,
        style_id = column.id,
        style = {
            line_spacing = 1.2,
            font_size = 22,
            drop_shadow = true,
            font_type = "machine_medium",
            text_vertical_alignment = "center",
            text_horizontal_alignment = "right",
            size = { column.width, ROW_HEIGHT },
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
        local value = ""
        if not column.condition or column.condition(buff) then
            value = column.accessor(buff)
        end
        widget.content[column.id] = value
    end

    return widget
end

return {
    row_height = ROW_HEIGHT,
    create_header_row = create_header_row_widget_v1,
    create_row = create_row_widget_v1
}