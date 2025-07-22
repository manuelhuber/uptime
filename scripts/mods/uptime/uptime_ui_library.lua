local UIWidget = require("scripts/managers/ui/ui_widget")

-- Helper functions for widget keys
function icon_key(name)
    return name .. "_icon"
end

function text_key(name)
    return name .. "_text"
end

-- Base class for uptime UI rendering
local UptimeUILibrary = class("UptimeUILibrary")

-- Constructor method
function UptimeUILibrary:init()
    self.active_buffs = {}
    self.widgets = {}
    self._widgets_by_name = {}
    self.row_count = 0
end

-- Factory method to create new instances
function UptimeUILibrary.new(self)
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    instance:init()
    return instance
end

-- Add a new row to display a buff
function UptimeUILibrary.add_row(self, key)
    -- Create text widget for uptime percentage
    local text = UIWidget.create_definition({
        {
            value = key,
            value_id = "text",
            style_id = "text",
            pass_type = "text",
            style = {
                line_spacing = 1.2,
                font_size = 30,
                drop_shadow = true,
                font_type = "machine_medium",
                offset = { 40, self.row_count * 40, 0 },
            },
        }
    }, "container")
    -- Create icon widget
    local icon = UIWidget.create_definition({
        {
            pass_type = "texture",
            style_id = "icon",
            value = "content/ui/materials/icons/buffs/hud/buff_container_with_background",
            style = {
                size = {
                    38,
                    38,
                },
                offset = {
                    0,
                    self.row_count * 40
                }
            }
        }
    }, "container")
    -- Create widgets directly without using HudElementBase methods
    self.widgets[icon_key(key)] = UIWidget.init(icon)
    self._widgets_by_name[icon_key(key)] = self.widgets[icon_key(key)]
    
    self.widgets[text_key(key)] = UIWidget.init(text)
    self._widgets_by_name[text_key(key)] = self.widgets[text_key(key)]

    self.row_count = (self.row_count or 0) + 1
end

-- Update the icon for a buff
function UptimeUILibrary.update_buff_icon(self, buff_name, icon_path, gradient_map)
    local icon = self.widgets[icon_key(buff_name)]
    if icon then
        icon.style.icon.material_values = icon.style.icon.material_values or {}
        icon.style.icon.material_values.talent_icon = icon_path
        icon.style.icon.material_values.gradient_map = gradient_map
    end
end

-- Update the text for a buff
function UptimeUILibrary.update_buff_text(self, buff_name, text)
    local text_widget = self.widgets[text_key(buff_name)]
    if text_widget then
        text_widget.content.text = text
    end
end

-- Draw all widgets
function UptimeUILibrary.draw(self, dt, t, input_service, ui_renderer)
    for name, widget in pairs(self._widgets_by_name) do
        UIWidget.draw(widget, ui_renderer)
    end
end

-- Clean up all widgets
function UptimeUILibrary.cleanup(self)
    self._widgets_by_name = {}
    self.widgets = {}
    self.active_buffs = {}
    self.row_count = 0
end

return UptimeUILibrary