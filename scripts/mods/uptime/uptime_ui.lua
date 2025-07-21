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