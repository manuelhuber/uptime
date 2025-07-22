local mod = get_mod("uptime")

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local base_z = 100

local size = { 300, 300 }

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    uptime = {
        vertical_alignment = "center",
        parent = "screen",
        horizontal_alignment = "center",
        size = { size[1], size[2] },
        position = { 0, 0, base_z }
    },
    uptime_rows = {
        vertical_alignment = "top",
        parent = "uptime",
        horizontal_alignment = "center",
        size = { size[1], size[2] - 100 },
        position = { 0, 40, base_z + 1 }
    },
}

local widget_definitions = {
    uptime = UIWidget.create_definition({
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/dropshadow_heavy",
            style = {
                vertical_alignment = "center",
                scale_to_material = true,
                horizontal_alignment = "center",
                offset = { 0, 0, base_z + 2 },
                size = { size[1] - 4, size[2] - 3 },
                color = Color.black(255, true),
                disabled_color = Color.black(255, true),
                default_color = Color.black(255, true),
                hover_color = Color.black(255, true),
            }
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/inner_shadow_medium",
            style = {
                vertical_alignment = "center",
                scale_to_material = true,
                horizontal_alignment = "center",
                offset = { 0, 0, base_z + 1 },
                size = { size[1] - 24, size[2] - 28 },
                color = Color.terminal_grid_background(255, true),
                disabled_color = Color.terminal_grid_background(255, true),
                default_color = Color.terminal_grid_background(255, true),
                hover_color = Color.terminal_grid_background(255, true),
            }
        },
        {
            value = "content/ui/materials/backgrounds/terminal_basic",
            pass_type = "texture",
            style = {
                vertical_alignment = "center",
                scale_to_material = true,
                horizontal_alignment = "center",
                offset = { 0, 0, base_z },
                size = { size[1] - 4, size[2] },
                color = Color.terminal_grid_background(255, true),
                disabled_color = Color.terminal_grid_background(255, true),
                default_color = Color.terminal_grid_background(255, true),
                hover_color = Color.terminal_grid_background(255, true),
            }
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/premium_store/details_upper",
            style = {
                vertical_alignment = "center",
                scale_to_material = true,
                horizontal_alignment = "center",
                offset = { 0, -size[2] / 2, base_z + 200 },
                size = { size[1], 80 },
                color = Color.gray(255, true),
                disabled_color = Color.gray(255, true),
                default_color = Color.gray(255, true),
                hover_color = Color.gray(255, true),
            }
        },
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/premium_store/details_lower_basic",
            style = {
                vertical_alignment = "center",
                scale_to_material = true,
                horizontal_alignment = "center",
                offset = { 0, size[2] / 2 - 50, base_z + 200 },
                size = { size[1] + 50, 120 },
                color = Color.gray(255, true),
                disabled_color = Color.gray(255, true),
                default_color = Color.gray(255, true),
                hover_color = Color.gray(255, true),
            }
        },
    }, "uptime"),
}

local legend_inputs = {
    {
        input_action = "hotkey_menu_special_1",
        on_pressed_callback = "cb_on_save_pressed",
        display_name = "loc_uptime_save",
        alignment = "left_alignment"
    },
}

local UptimeViewDefinitions = {
    legend_inputs = legend_inputs,
    widget_definitions = widget_definitions,
    scenegraph_definition = scenegraph_definition
}

return settings("UptimeViewDefinitions", UptimeViewDefinitions)