local mod = get_mod("uptime")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")

local UptimeView = class("UptimeView", "BaseView")

UptimeView.init = function(self, settings, context)
    self._definitions = mod:io_dofile("uptime/scripts/mods/uptime/view/uptime_view_definitions")
    if context.test then
        mod:echo(context.test)
    end
    UptimeView.super.init(self, self._definitions, settings)
end

--UptimeView.draw = function(self, dt, t, input_service, ui_renderer)
--    -- Loop through named widgets and draw them
--    for name, widget in pairs(self._widgets_by_name or {}) do
--        if widget then
--            UIWidget.draw(widget, ui_renderer)
--        end
--    end
--end

return UptimeView