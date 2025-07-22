local mod = get_mod("uptime")
local UIWorkspaceSettings = mod:original_require("scripts/settings/ui/ui_workspace_settings")
local UptimeUILibrary = mod:io_dofile("uptime/scripts/mods/uptime/uptime_ui_library")

local UptimeWidget = class("UptimeWidget", "HudElementBase")

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

function UptimeWidget:init(parent, draw_layer, start_scale)
    UptimeWidget.super.init(self, parent, draw_layer, start_scale, Definitions)
    self.ui_library = UptimeUILibrary:new()
    self.active_buffs = self.ui_library.active_buffs
end

UptimeWidget.update = function(self, dt, t, ui_renderer, render_settings, input_service)
    UptimeWidget.super.update(self, dt, t, ui_renderer, render_settings, input_service)
    self:update_content()
end

UptimeWidget.update_content = function(self)
    local start_time = mod:start_time()
    if (start_time == nil) then
        self:cleanup()
        return
    end
    local buffs = mod:active_buffs()

    local now = Managers.time:time("gameplay")
    local tracking_duration = now - start_time

    for buff_name, buff_data in pairs(buffs) do
        if (not self.active_buffs[buff_name]) then
            self.active_buffs[buff_name] = true
            self.ui_library:add_row(buff_name)
        end

        -- Update icon using library method
        self.ui_library:update_buff_icon(buff_name, buff_data.icon, buff_data.gradient_map)

        -- Update uptime percentage using real-time values
        local current_uptime = buff_data.current_uptime or 0
        local uptime_percent = (current_uptime / tracking_duration) * 100
        local current_avg_stacks = buff_data.current_avg_stacks or 0
        local text = string.format("%.1f%%", uptime_percent)
        if (buff_data.stackable) then
            text = text .. string.format(" (%.2f stacks)", current_avg_stacks)
        end

        -- Update text using library method
        self.ui_library:update_buff_text(buff_name, text)
    end
end

UptimeWidget._draw_widgets = function(self, dt, t, input_service, ui_renderer)
    self.ui_library:draw(dt, t, input_service, ui_renderer)
    UptimeWidget.super._draw_widgets(self, dt, t, input_service, ui_renderer)
end

UptimeWidget.cleanup = function(self)
    self.ui_library:cleanup()
end

return UptimeWidget