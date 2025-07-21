local mod = get_mod("uptime")
buffs = {}  -- Table to store all buff data
mod.buffs= buffs

mod:io_dofile("uptime/scripts/mods/uptime/uptime_calculation")
mod:io_dofile("uptime/scripts/mods/uptime/uptime_ui")

-- Track all buffs instead of a single hardcoded one


mod:command("u", "", function(self)
    if (not mod:try_start_tracking()) then
        mod:try_end_tracking()
    end
end)

--HUD rendering
mod:hook_require("scripts/ui/hud/elements/hud_element_player_panel/hud_element_player_panel", function(instance)

    local draw_func = function()
        if not mod:start_time() then
            return
        end

        local now = Managers.time:time("gameplay")
        local mission_duration = now - mod:start_time()

        local color = Color.terminal_text_body(255, true)
        local font_size = 20
        local x = 60
        local y = 200
        local line_height = 25  -- Space between lines

        local font = UIFonts.standard_font
        local font_material = UIFonts.fonts[font].material
        local font_face = UIFonts.fonts[font].font

        local text_options = {
            horizontal_alignment = "left",
            vertical_alignment = "top",
            font_size = font_size,
            font_type = font_face,
            text_color = color,
            offset = { 0, 0, 30 }
        }

        local ui_renderer = instance._ui_renderer

        -- Draw header
        --local header_text = string.format("Buff Tracker - Mission Time: %.1fs", mission_duration)
        local header_text = "Buff Tracker - Mission Time: " .. mission_duration
        local header_position = Vector3(x, y, 100)
        UIRenderer.draw_text(ui_renderer, header_text, font_material, 500, text_options, header_position)

        -- Sort buffs by name for consistent display
        local sorted_buffs = {}
        for buff_name, _ in pairs(mod.buffs) do
            table.insert(sorted_buffs, buff_name)
        end
        table.sort(sorted_buffs)

        -- Draw each buff's uptime
        for i, buff_name in ipairs(sorted_buffs) do
            local buff_data = mod.buffs[buff_name]
            local current_uptime = buff_data.total_uptime or 0

            -- Add current active time if buff is active
            if buff_data.start_time then
                current_uptime = current_uptime + (now - buff_data.start_time)
            end

            local percent = mission_duration > 0 and (current_uptime / mission_duration * 100) or 0
            --local buff_text = string.format("%s: %.1fs / %.1fs (%.1f%%)", buff_name, current_uptime, mission_duration, percent)
            local buff_text = buff_name

            -- Start buff entries below the header (i+1 because header is at position 0)
            local buff_position = Vector3(x, y + ((i + 1) * line_height), 100)
            UIRenderer.draw_text(ui_renderer, buff_text, font_material, 500, text_options, buff_position)
        end
    end

    mod.on_render = draw_func

    mod:hook_safe(instance, "update", function()
        mod:echo("gehd")

        if mod.on_render then
            mod.on_render()
        end
    end)
end)
