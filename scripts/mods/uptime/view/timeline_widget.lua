local mod = get_mod("uptime")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

local pass_template = {
    {
        pass_type = "rect",
        style = {
            color = Color.ui_grey_medium(153, true),
        },
    },
}

function get_widget(_create_widget, scene_graph_id, width, height, percentage_per_stack)

    local template = {
        {
            pass_type = "rect",
            style = {
                color = Color.ui_grey_medium(120, true),
                size = { width, height }
            },
        } }

    local offset = 0
    local max_stacks = #percentage_per_stack
    local show_text = max_stacks > 1
    for stack, percentage in pairs(percentage_per_stack) do
        local section_width = (percentage / 100) * width
        template[#template + 1] = {
            pass_type = "rect",
            style = {
                size = { section_width, height },
                offset = { offset, 0 },
                color = Color.steel_blue(stack % 2 == 1 and 255 or 180, true),
            },
        }

        if show_text then
            template[#template + 1] = {
                pass_type = "text",
                value = stack,
                style = {
                    text_horizontal_alignment = "center",
                    size = { section_width, height },
                    offset = { offset, 0 },
                    text_color = Color.black(255, true),
                },
            }
        end

        offset = offset + section_width
    end

    local widget_def = UIWidget.create_definition(template, scene_graph_id)
    local widget = _create_widget("baaaar", widget_def)
    return widget
end

return get_widget