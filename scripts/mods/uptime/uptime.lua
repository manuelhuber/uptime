local mod = get_mod("uptime")

mod:io_dofile("uptime/scripts/mods/uptime/uptime_calculation")
mod:io_dofile("uptime/scripts/mods/uptime/uptime_io")
mod:io_dofile("uptime/scripts/mods/uptime/uptime_ui")
mod:io_dofile("uptime/scripts/mods/uptime/history/uptime_history")

mod:command("u", "", function(self)
    if (not mod:try_start_tracking()) then
        mod:try_end_tracking()
    end
end)

-- Command to open uptime history
mod:command("uh", "", function(self)
    mod:show_uptime_history_view()
end)

mod:hook_safe(CLASS.TalentBuilderView, "on_exit", function(func, self, widget)
    -- When changing talents we suddenly get all buffs at once, so instead we just stop tracking.
    mod:try_end_tracking()
end)

-- Load uptime history view
mod:register_uptime_history_view()