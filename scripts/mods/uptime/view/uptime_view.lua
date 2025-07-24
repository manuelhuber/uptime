local mod = get_mod("uptime")
local renderer = mod:io_dofile("uptime/scripts/mods/uptime/view/uptime_row_v1")
local Definitions = mod:io_dofile("uptime/scripts/mods/uptime/view/uptime_view_definitions")
mod:io_dofile("uptime/scripts/mods/uptime/view/uptime_view_data_handler")
local get_talent = mod:io_dofile("uptime/scripts/mods/uptime/libs/talents")
local tooltip_definition = mod:io_dofile("uptime/scripts/mods/uptime/view/tooltip_definition")
local TalentLayoutParser = mod:original_require("scripts/ui/views/talent_builder_view/utilities/talent_layout_parser")
local UptimeView = class("UptimeView", "BaseView")

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

    local sorted_buffs = {}
    for _, buff in pairs(buffs) do
        table.insert(sorted_buffs, buff)
    end
    table.sort(sorted_buffs, function(a, b)
        return a.uptime > b.uptime
    end)

    local header_row = renderer.create_header_row(create_widget)
    self._widgets[#self._widgets + 1] = header_row
    local index = 2 -- header row is double height
    local padding = 8
    for _, buff in ipairs(sorted_buffs) do
        local row_widget = renderer.create_row(buff, index, create_widget)
        row_widget.offset[2] = (index * (renderer.row_height + padding))
        self._widgets[#self._widgets + 1] = row_widget
        index = index + 1
    end
end

function UptimeView:update(...)
    for _, widget in pairs(self._widgets) do
        if (widget.content.hotspot or {}).is_hover and widget.buff then
            self:setup_tooltip(widget.buff)
        end
    end
    return UptimeView.super.update(self, ...)
end

function UptimeView:setup_tooltip(buff)
    local widgets_by_name = self._widgets_by_name
    local widget = widgets_by_name.tooltip
    local content = widget.content
    local style = widget.style
    if buff.talents then
        local talent = get_talent(buff.talents[1])
        content.title = Managers.localization:localize(talent.display_name)
        content.description = TalentLayoutParser.talent_description(talent, 1, Color.ui_terminal(255, true))
    end
    tooltip_definition.resize_tooltip(self, widget, self._ui_renderer)
end

return UptimeView