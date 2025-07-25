local mod = get_mod("uptime")
local UIFonts = mod:original_require("scripts/managers/ui/ui_fonts")
local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")

function get_text_height(ui_renderer, text, text_style, optional_text_size)
    local text_options = UIFonts.get_font_options_by_style(text_style)
    local text_height = UIRenderer.text_height(ui_renderer, text, text_style.font_type, text_style.font_size, optional_text_size or text_style.size, text_options)
    return text_height
end

function get_text_width(ui_renderer, text, text_style, optional_text_size)
    local text_options = UIFonts.get_font_options_by_style(text_style)
    local text_width = UIRenderer.text_width(ui_renderer, text, text_style.font_type, text_style.font_size, optional_text_size or text_style.size, text_options)
    return text_width
end

function seconds_to_display_format(seconds)
    local minutes = math.floor(seconds / 60)
    local remaining_seconds = math.floor(seconds % 60)
    return string.format("%02d", minutes) .. ":" .. string.format("%02d", remaining_seconds)
end

return {
    get_text_height = get_text_height,
    get_text_width = get_text_width,
    format_seconds = seconds_to_display_format,
}