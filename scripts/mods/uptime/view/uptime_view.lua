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
    local sorted_buffs = {}
    for _, buff in pairs(buffs) do
        table.insert(sorted_buffs, buff)
    end
    table.sort(sorted_buffs, function(a, b)
        return a.uptime > b.uptime
    end)

    local header_row = renderer.create_header_row(self)
    self._widgets[#self._widgets + 1] = header_row
    local index = 2 -- header row is double height
    for _, buff in ipairs(sorted_buffs) do
        local widgets = renderer.create_row(self, buff, index)
        for _, widget in pairs(widgets) do
            self._widgets[#self._widgets + 1] = widget
        end
        index = index + 1
    end

    local horizontal_margins_for_border = 75
    local final_width = renderer.width + horizontal_margins_for_border

    local vertical_margins_for_border = 225
    local final_height = index * renderer.row_height + vertical_margins_for_border

    self:_set_scenegraph_size("container", final_width, final_height)
end

function UptimeView:update(...)
    local show_tooltip = false
    for _, widget in pairs(self._widgets) do
        if (widget.content.hotspot or {}).is_hover and widget.buff and widget.buff.talents then
            show_tooltip = true
            self:setup_tooltip(widget.buff, widget)
        end
    end
    if not show_tooltip then
        local tooltip = self._widgets_by_name.tooltip
        tooltip.visible = false
    end
    return UptimeView.super.update(self, ...)
end

function UptimeView:setup_tooltip(buff, hovered_widget)
    local widget = self._widgets_by_name.tooltip
    widget.visible = true
    local content = widget.content
    local style = widget.style
    if buff.talents then
        local talent = get_talent(buff.talents[1])
        content.title = Managers.localization:localize(talent.display_name)
        content.description = TalentLayoutParser.talent_description(talent, 1, Color.ui_terminal(255, true))
    end
    tooltip_definition.resize_tooltip(self, widget, self._ui_renderer)

    local tooltip_offset = widget.offset
    tooltip_offset[1] = hovered_widget.offset[1]
    tooltip_offset[2] = hovered_widget.offset[2]
end

return UptimeView