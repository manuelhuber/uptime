local mod = get_mod("uptime")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

local UptimeView = class("UptimeView", "BaseView")

local ROW_HEIGHT = 30

function UptimeView:init(settings, context)
    self._definitions = mod:io_dofile("uptime/scripts/mods/uptime/view/uptime_view_definitions")
    self._entries = context.entries
    self._widgets, self._widgets_by_name = {}, {}
    UptimeView.super.init(self, self._definitions, settings)
end

function UptimeView:on_enter()
    self:create_rows(self._entries)
    UptimeView.super.on_enter(self)
end

function UptimeView:create_rows(entries)
    for index, entry in pairs(entries) do
        local row_widget = self:create_row_widget(entry, index)
        row_widget.offset[2] = -((index - 1) * ROW_HEIGHT)
        self._widgets[#self._widgets + 1] = row_widget
    end
end

function UptimeView:create_row_widget(entry, index)
    local widget_def = UIWidget.create_definition({
        {
            value_id = "text",
            style_id = "text",
            pass_type = "text",
            style = {
                line_spacing = 1.2,
                font_size = 30,
                drop_shadow = true,
                font_type = "machine_medium",
                size = { 300, ROW_HEIGHT }
            },
        }
    }, "uptime_rows")
    local widget = self:_create_widget("row" .. index, widget_def)
    widget.content.text = "row " .. tostring(index) .. ": " .. entry
    return widget
end

return UptimeView