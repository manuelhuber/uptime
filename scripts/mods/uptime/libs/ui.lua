local mod = get_mod("uptime")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local UIRenderer = require("scripts/managers/ui/ui_renderer")

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

return {
    get_text_height = get_text_height,
    get_text_width = get_text_width
}