local mod = get_mod("uptime")
mod:add_global_localize_strings({
    loc_delete_entry = {
        en = "Delete entry"
    },
    loc_scan_folder = {
        en = "Scan directory for files"
    },
})

return {
    mod_description = {
        en = "Tracks uptime of buffs.",
    },
    loc_uptime_header = {
        en = "uptime"
    },
    loc_avg_stacks_header = {
        en = "Avg Stacks"
    },
    loc_percentage_at_max_stacks_header = {
        en = "Max stacks"
    }, loc_talent_header = {
        en = "From talent"
    },
    loc_percentage_per_stack = {
        en = "Uptime (by Stack)"
    },

    -- general settings
    open_uptime_history = {
        en = "Open Uptime History",
    },
    data_display_settings = {
        en = "Data columns"
    },
    -- table columns & their settings

    show_uptime = {
        en = "Total uptime"
    },
    loc_uptime_header = {
        en = "uptime"
    },

    show_uptime_percentage = {
        en = "uptime percentage"
    },
    loc_uptime_percentage_header = {
        en = "uptime"
    },

    show_uptime_combat = {
        en = "Total uptime during combat"
    },
    loc_uptime_combat_header = {
        en = "uptime (combat)"
    },

    show_uptime_combat_percentage = {
        en = "Uptime percentage during combat"
    },
    loc_uptime_combat_percentage_header = {
        en = "uptime (combat)"
    },

    show_combat_percentage_per_stack = {
        en = "Stack distribution during combat"
    },
    loc_combat_percentage_per_stack_header = {
        en = "Uptime (combat) by stack"
    },

    show_combat_time_at_max_stack = {
        en = "Total time at max stacks during combat"
    },
    loc_combat_time_at_max_stack_header = {
        en = "Time at max (combat)"
    },

    show_combat_percentage_at_max_stack = {
        en = "Percentage of uptime during combat at max stack"
    },
    loc_combat_percentage_at_max_stack_header = {
        en = "Percentage at max (combat)"
    },

    show_average_stacks_combat = {
        en = "Average stack count during combat"
    },
    loc_average_stacks_combat_header = {
        en = "Average stack (combat)"
    },

    loc_unknown_blessing = {
        en = "Unkown blessing"
    }
}
