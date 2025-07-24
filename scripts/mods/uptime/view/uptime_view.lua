local mod = get_mod("uptime")
local create_row_widget_v1 = mod:io_dofile("uptime/scripts/mods/uptime/view/uptime_row_v1")
local Definitions = mod:io_dofile("uptime/scripts/mods/uptime/view/uptime_view_definitions")
mod:io_dofile("uptime/scripts/mods/uptime/view/uptime_view_data_handler")

local UptimeView = class("UptimeView", "BaseView")

local ROW_HEIGHT = 35

function UptimeView:init(settings, context)
    self._definitions = Definitions
    self.display_values = mod:generate_display_values(context.entry)
    self._widgets, self._widgets_by_name = {}, {}
    UptimeView.super.init(self, self._definitions, settings)
    self._pass_input = true
end

function UptimeView:on_enter()
    self:create_rows(self.display_values.buffs)
    UptimeView.super.on_enter(self)
end

function UptimeView:create_rows(buffs)
    local create_widget = function(...)
        return self:_create_widget(...)
    end
    local index = 0

    local sorted_buffs = {}
    for _, buff in pairs(buffs) do
        table.insert(sorted_buffs, buff)
    end
    table.sort(sorted_buffs, function(a, b)
        return a.uptime_percent > b.uptime_percent
    end)

    for _, buff in ipairs(sorted_buffs) do
        local row_widget = create_row_widget_v1(buff, index, create_widget)
        row_widget.offset[2] = (index * ROW_HEIGHT)
        self._widgets[#self._widgets + 1] = row_widget
        index = index + 1
    end
end

return UptimeView