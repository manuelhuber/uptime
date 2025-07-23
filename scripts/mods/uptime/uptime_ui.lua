local mod = get_mod("uptime")

local hud_elements = {
    {
        filename = "uptime/scripts/mods/uptime/uptime_widget",
        class_name = "UptimeWidget",
        visibility_groups = {
            "tactical_overlay",
            "alive",
            "communication_wheel",
        },
    },
}

for _, hud_element in ipairs(hud_elements) do
    mod:add_require_path(hud_element.filename)
end

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
    for _, hud_element in ipairs(hud_elements) do
        if not table.find_by_key(elements, "class_name", hud_element.class_name) then
            table.insert(elements, {
                class_name = hud_element.class_name,
                filename = hud_element.filename,
                use_hud_scale = true,
                visibility_groups = hud_element.visibility_groups or {
                    "alive",
                },
            })
        end
    end

    return func(self, elements, visibility_groups, params)
end)

mod.register_uptime_view = function(self)
    self:add_require_path("uptime/scripts/mods/uptime/view/uptime_view")
    self:register_view({
        view_name = "uptime_view",
        view_settings = {
            init_view_function = function(ingame_ui_context)
                return true
            end,
            class = "UptimeWidget",
            disable_game_world = false,
            display_name = "display name",
            game_world_blur = 0,
            load_always = true,
            load_in_hub = true,
            package = "packages/ui/views/options_view/options_view",
            path = "uptime/scripts/mods/uptime/view/uptime_view",
            state_bound = false,
            enter_sound_events = {
                "wwise/events/ui/play_ui_enter_short"
            },
            exit_sound_events = {
                "wwise/events/ui/play_ui_back_short"
            },
            wwise_states = {
                options = "ingame_menu"
            },
        },
        view_transitions = {},
        view_options = {
            close_all = false,
            close_previous = false,
            close_transition_time = nil,
            transition_time = nil
        }
    })
    self:io_dofile("uptime/scripts/mods/uptime/view/uptime_view")
end
