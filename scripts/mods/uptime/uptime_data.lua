local mod = get_mod("uptime")

return {
    name = "uptime",
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            { ["setting_id"] = "open_uptime_history",
              ["type"] = "keybind",
              ["default_value"] = { "f8" },
              ["keybind_trigger"] = "pressed",
              ["keybind_type"] = "view_toggle",
              ["view_name"] = "uptime_history_view"
            },
        }
    }
}
