local mod = get_mod("uptime")

mod:io_dofile("uptime/scripts/mods/uptime/uptime_calculation")
mod:io_dofile("uptime/scripts/mods/uptime/uptime_ui")

mod:command("u", "", function(self)
    if (not mod:try_start_tracking()) then
        mod:try_end_tracking()
    end
end)

mod:hook_safe(CLASS.TalentBuilderView, "on_exit", function(func, self, widget)
    -- When changing talents we suddenly get all buffs at once, so instead we just stop tracking.
    mod:try_end_tracking()
end)