local mod = get_mod("uptime")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

function background_definition(width, height, base_z)
    return UIWidget.create_definition({
        {
            pass_type = "texture",
            value = "content/ui/materials/frames/dropshadow_heavy",
            style = {
                vertical_alignment = "center",
                scale_to_material = true,
                horizontal_alignment = "center",
                offset = { 0, 0, base_z + 2 },
                size = { width - 4, height - 3 },
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
                size = { width - 24, height - 28 },
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
                size = { width - 4, height },
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
                offset = { 0, -height / 2, base_z + 200 },
                size = { width, 80 },
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
                offset = { 0, height / 2 - 50, base_z + 200 },
                size = { width + 50, 120 },
                color = Color.gray(255, true),
                disabled_color = Color.gray(255, true),
                default_color = Color.gray(255, true),
                hover_color = Color.gray(255, true),
            }
        },
    }, "container")
end

return background_definition