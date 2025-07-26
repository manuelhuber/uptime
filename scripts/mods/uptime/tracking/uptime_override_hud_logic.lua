local mod = get_mod("uptime")
--[[
This function is a copy of the original _add_buff function
https://github.com/Aussiemon/Darktide-Source-Code/blob/72cde1c088677d22b3830d9681d015167782b10a/scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_polling.lua#L120-L156
Except I removed the parts where if we have "too many" buffs we simply ignore new buffs._add_buff
]]
mod:hook("HudElementPlayerBuffs", "_add_buff", function(func, self, buff_instance)
    local active_buffs_data = self._active_buffs_data

    local is_negative = buff_instance:is_negative()

    if is_negative then
        self._active_negative_buffs = self._active_negative_buffs + 1
    else
        self._active_positive_buffs = self._active_positive_buffs + 1
    end

    local buff_template = buff_instance and buff_instance:template()
    local buff_category = buff_template and buff_template.buff_category or buff_categories.generic
    local index = #active_buffs_data + 1

    self._active_buffs_data[index] = {
        is_active = false,
        buff_instance = buff_instance,
        is_negative = is_negative,
        activated_time = math.huge,
        start_index = index,
        buff_category = buff_category,
        buff_name = buff_template.name,
    }
end)

--[[
Copy of existing HUD function, except we create more widgets
https://github.com/Aussiemon/Darktide-Source-Code/blob/72cde1c088677d22b3830d9681d015167782b10a/scripts/ui/hud/elements/player_buffs/hud_element_player_buffs_polling.lua#L172C1-L192C4

]]
mod:hook("HudElementPlayerBuffs", "_setup_buff_widget_array", function(func, self, ui_renderer)
    local buff_widgets_array = {}
    local widgets_by_name = self._widgets_by_name

    -- generating 30 widgets, more buffs probably won't be displayed ever
    for i = 1, 30 do
        local buff_widget_name = "buff_" .. i
        local widget = widgets_by_name[buff_widget_name]

        buff_widgets_array[i] = widget

        for f = 1, #widget.passes do
            local pass_info = widget.passes[f]

            pass_info.retained_mode = self._use_retained_mode
        end

        self:_return_widget(widget, ui_renderer)
    end

    return buff_widgets_array
end)