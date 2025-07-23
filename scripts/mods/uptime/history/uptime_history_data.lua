local mod = get_mod("uptime")

-- UptimeHistoryData handles all data-related operations for uptime history entries
local UptimeHistoryData = class("UptimeHistoryData")

UptimeHistoryData.init = function(self)
end

-- Get all uptime history entries, optionally forcing a directory scan
UptimeHistoryData.get_entries = function(self, scan_dir)
    -- Get all uptime history entries
    local history_entries = mod:get_history_entries(scan_dir)
    local entries = {}
    local entries_by_title = {}

    -- Process each history entry
    for i = 1, #history_entries do
        local history_entry = history_entries[i]
        local entry = self:create_entry(history_entry)
        entries[#entries + 1] = entry
        entries_by_title[entry.title] = entry
    end

    -- Return the processed entries and the default entry if available
    local default_entry = history_entries[1] and history_entries[1].date or nil
    return entries, entries_by_title, default_entry
end

-- Create an entry from history data
UptimeHistoryData.create_entry = function(self, history_entry)
    local mission_name = ""
    local mission_subname = ""

    -- Add mission info if available
    if history_entry.mission and history_entry.mission.name then
        mission_name = " | " .. history_entry.mission.name
        mission_subname = "\n" .. history_entry.mission.formatted_time
    end

    -- Create localized string for the entry title
    local date_string = tostring(history_entry.date)

    local title = date_string .. mission_name .. mission_subname
    local subtitle = history_entry.mission.player or ""

    -- Create and return the entry
    return {
        widget_type = "settings_button",
        title = title,
        subtitle = subtitle,
        file = history_entry.file,
        file_path = history_entry.file_path
    }
end

UptimeHistoryData.load_entry = function(self, file_path)
    return mod:load_entry(file_path)
end

UptimeHistoryData.delete_entry = function(self, entry)
    return mod:delete_entry(entry)
end

return UptimeHistoryData