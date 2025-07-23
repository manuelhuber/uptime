local mod = get_mod("uptime")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local create_row_widget_v1 = mod:io_dofile("uptime/scripts/mods/uptime/view/uptime_row_v1")

local UptimeView = class("UptimeView", "BaseView")

local ROW_HEIGHT = 35
--[[
v1:
context: {
    mission: {
        name : string
        duration : number
        player : string
        formatted_time : string
    }
    buffs: ... (see row v1)
}
]]
function UptimeView:init(settings, context)
    self._definitions = mod:io_dofile("uptime/scripts/mods/uptime/view/uptime_view_definitions")
    self.buffs = context.buffs
    self._widgets, self._widgets_by_name = {}, {}
    UptimeView.super.init(self, self._definitions, settings)
end

function UptimeView:on_enter()
    self:create_rows(self.buffs)
    UptimeView.super.on_enter(self)
end

function UptimeView:create_rows(buffs)
    local create_widget = function(...)
        return self:_create_widget(...)
    end
    local index = 0
    for _, buff in pairs(buffs) do
        local row_widget = create_row_widget_v1(buff, index, create_widget)
        row_widget.offset[2] = (index * ROW_HEIGHT)
        self._widgets[#self._widgets + 1] = row_widget
        index = index + 1
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