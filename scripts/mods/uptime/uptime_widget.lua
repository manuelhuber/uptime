local mod = get_mod("uptime")

local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local style = {
    line_spacing = 1.2,
    font_size = 30,
    drop_shadow = true,
    font_type = "machine_medium",
    offset = { 40, 0, 0 },
}
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
    widget_definitions = {
        --myText = UIWidget.create_definition({
        --    {
        --        value_id = "text",
        --        style_id = "text",
        --        pass_type = "text",
        --        style = style,
        --    }
        --}, "container"),
        --icon = UIWidget.create_definition({
        --    {
        --        pass_type = "texture",
        --        style_id = "icon",
        --        value = "content/ui/materials/icons/buffs/hud/buff_container_with_background",
        --        style = {
        --            size = {
        --                38,
        --                38,
        --            },
        --        }
        --    }
        --}, "container")
    }
}

function icon_key(name)
    return name .. "_icon"
end
function text_key(name)
    return name .. "_text"
end

--function UptimeWidget.add_row(self, key, widget_definitions)
--    local text = UIWidget.create_definition({
--        {
--            value = key,
--            value_id = "text",
--            style_id = "text",
--            pass_type = "text",
--            style = style,
--        }
--    }, "container")
--    local icon = UIWidget.create_definition({
--        {
--            pass_type = "texture",
--            style_id = "icon",
--            value = "content/ui/materials/icons/buffs/hud/buff_container_with_background",
--            style = {
--                size = {
--                    38,
--                    38,
--                },
--            }
--        }
--    }, "container")
--    widget_definitions[icon_key(key)] = self:_create_widget(icon_key(key), icon)
--    widget_definitions[text_key(key)] = self:_create_widget(text_key(key), text)
--    mod:echo("added widget in scope. Now at " .. #widget_definitions)
--end

UptimeWidget = class("UptimeWidget", "HudElementBase")

function UptimeWidget:init(parent, draw_layer, start_scale)
    UptimeWidget.super.init(self, parent, draw_layer, start_scale, Definitions)
    self.active_buffs = {}
    self.widgets = {}
end

UptimeWidget.update = function(self, dt, t, ui_renderer, render_settings, input_service)
    UptimeWidget.super.update(self, dt, t, ui_renderer, render_settings, input_service)
    --local start_time = mod:start_time()
    --if (start_time ~= nil) then
    --    local buffs = mod:active_buffs()
    --
    --    for buff_name, buff_data in pairs(buffs) do
    --        if (not self.active_buffs[buff_name]) then
    --            self.active_buffs[buff_name] = true
    --            self:add_row(buff_name, self.widgets)
    --            mod:echo("added widget. Now at " .. #self.widgets)
    --        end
    --        local icon = self.widgets[icon_key(buff_name)]
    --        if icon and icon.style and icon.style.icon then
    --            icon.style.icon.material_values = icon.style.icon.material_values or {}
    --            icon.style.icon.material_values.talent_icon = buff_data.icon
    --            icon.style.icon.material_values.gradient_map = buff_data.gradient_map
    --            self.widgets[text_key(buff_name)].content.text = buff_name
    --        else
    --            mod.echo("widget style is null")
    --        end
    --    end
    --end
end

--UptimeWidget._draw_widgets = function(self, dt, t, input_service, ui_renderer, render_settings)
--    UIRenderer.begin_pass(ui_renderer, self._ui_scenegraph, input_service, dt, render_settings)
--
--    local widgets = self.widgets
--    for _, widget in pairs(widgets) do
--        --if widget.dirty then
--        mod:echo("drawing")
--
--        UIWidget.draw(widget, ui_renderer)
--        --end
--    end
--    UIRenderer.end_pass(ui_renderer)
--end

--function UptimeWidget:update(dt, t, ui_renderer, render_settings, input_service)
--    UptimeWidget.super.update(self, dt, t, ui_renderer, render_settings, input_service)
--
--    -- Gather your buff data as an array
--    local buffs = {}
--    for name, data in pairs(mod:active_buffs()) do
--        table.insert(buffs, {
--            icon = data.icon, -- texture path, e.g. "content/ui/textures/icons/hud/hud_icon_container"
--            text = name, -- Or whatever display text you want
--        })
--    end
--
--    -- Dynamically update the widget for current number of buffs
--    self._widgets_by_name.dynamic = self._widgets_by_name.dynamic or self:_create_widget("dynamic")
--    self._widgets_by_name.dynamic.definition = create_icon_text_widget(buffs)
--end
return UptimeWidget