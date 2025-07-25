local mod = get_mod("uptime")

local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local background_definition = mod:io_dofile("uptime/scripts/mods/uptime/view/background_definition")
local tooltip_definition = mod:io_dofile("uptime/scripts/mods/uptime/view/tooltip_definition")

local base_z = 100
local size = { 1000, 900 }
local row_scene_graph_id = "uptime_rows"

local scenegraph_definition = {
    screen = UIWorkspaceSettings.screen,
    container = {
        vertical_alignment = "center",
        parent = "screen",
        horizontal_alignment = "right",
        size = { size[1], size[2] },
        position = { 0, 0, base_z }
    },
    [row_scene_graph_id] = {
        vertical_alignment = "top",
        parent = "container",
        horizontal_alignment = "center",
        size = { size[1], size[2] - 100 },
        position = { 30, 90, base_z + 1 }
    },
    tooltip = tooltip_definition.scene
}

local widget_definitions = {
    background = background_definition(size[1], size[2], base_z),
    tooltip = tooltip_definition.widget_definition
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
    scenegraph_definition = scenegraph_definition,
    row_scene_graph_id = row_scene_graph_id,
}

return settings("UptimeViewDefinitions", UptimeViewDefinitions)