local mod = get_mod("uptime")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local Definitions = {
    scenegraph_definition = {
        screen = UIWorkspaceSettings.screen,
        container = {
            parent = "screen",
            scale = "fit",
            vertical_alignment = "top",
            horizontal_alignment = "left",
            position = { 20, 20, 1 }
        }
    },
    widget_definitions = { }
}

function icon_key(name)
    return name .. "_icon"
end
function text_key(name)
    return name .. "_text"
end
local UptimeWidget = class("UptimeWidget", "HudElementBase")

function UptimeWidget:init(parent, draw_layer, start_scale)
    UptimeWidget.super.init(self, parent, draw_layer, start_scale, Definitions)
    self.active_buffs = {}
    self.widgets = {}
    self.row_count = 0
end

function UptimeWidget.add_row(self, key)
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
    self.widgets[icon_key(key)] = self:_create_widget(icon_key(key), icon)
    self.widgets[text_key(key)] = self:_create_widget(text_key(key), text)

    self.row_count = (self.row_count or 0) + 1
end

UptimeWidget.update = function(self, dt, t, ui_renderer, render_settings, input_service)
    UptimeWidget.super.update(self, dt, t, ui_renderer, render_settings, input_service)
    local start_time = mod:start_time()
    if (start_time ~= nil) then
        local buffs = mod:active_buffs()

        local now = Managers.time:time("gameplay")
        local tracking_duration = now - start_time

        for buff_name, buff_data in pairs(buffs) do
            if (not self.active_buffs[buff_name]) then
                self.active_buffs[buff_name] = true
                self:add_row(buff_name)
            end

            -- Update icon
            local icon = self.widgets[icon_key(buff_name)]
            icon.style.icon.material_values = icon.style.icon.material_values or {}
            icon.style.icon.material_values.talent_icon = buff_data.icon
            icon.style.icon.material_values.gradient_map = buff_data.gradient_map

            -- Update uptime percentage using real-time values
            local current_uptime = buff_data.current_uptime or 0
            local uptime_percent = (current_uptime / tracking_duration) * 100
            local current_avg_stacks = buff_data.current_avg_stacks or 0
            self.widgets[text_key(buff_name)].content.text = string.format("%.1f%% (%.2f stacks)", uptime_percent, current_avg_stacks)
        end
    end
end

UptimeWidget._draw_widgets = function(self, dt, t, input_service, ui_renderer)
    for name, widget in pairs(self._widgets_by_name) do
        UIWidget.draw(widget, ui_renderer)
    end
    UptimeWidget.super._draw_widgets(self, dt, t, input_service, ui_renderer)
end

return UptimeWidget