local mod = get_mod("uptime")
local DMF = get_mod("DMF")

-- ##### IO and OS functions #####
local _io = DMF:persistent_table("_io")
_io.initialized = _io.initialized or false
if not _io.initialized then
    _io = DMF.deepcopy(Mods.lua.io)
end

local _os = DMF:persistent_table("_os")
_os.initialized = _os.initialized or false
if not _os.initialized then
    _os = DMF.deepcopy(Mods.lua.os)
end

-- ##### Helper functions #####

-- Check if a file or directory exists in this path
local function exists(file)
    local ok, err, code = _os.rename(file, file)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok, err
end

-- Check if a directory exists in this path
local function isdir(path)
    -- "/" works on both Unix and Windows
    return exists(path .. "/")
end

-- Check if file exists
local function file_exists(name)
    local f = _io.open(name, "r")
    if f ~= nil then
        _io.close(f)
        return true
    else
        return false
    end
end

-- Split a string by a separator
local function split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, #result + 1, each)
    end
    return result
end

-- Get the path to the uptime history directory
mod.appdata_path = function(self)
    local appdata = _os.getenv('APPDATA')
    return appdata .. "/Fatshark/Darktide/uptime_history/"
end

-- Create the uptime history directory if it doesn't exist
mod.create_uptime_history_directory = function(self)
    local path = self:appdata_path()
    if not isdir(path) then
        _os.execute('mkdir ' .. path) -- ?
        _os.execute("mkdir '" .. path .. "'") -- ?
        _os.execute('mkdir "' .. path .. '"') -- Windows
    end
end

-- Generate a file path for the current uptime history entry
mod.create_uptime_history_entry_path = function(self)
    local file_name = tostring(self:current_date()) .. ".lua"
    return self:appdata_path() .. file_name, file_name
end

-- Get the current date/time as a timestamp
mod.current_date = function(self)
    return _os.time(_os.date("*t"))
end

-- ##### Serialization and Deserialization Functions #####

-- Serialize mission data to a string
local function serialize_mission(mission_name, mission_duration, player)
    return "#mission;" .. tostring(mission_name) .. ";" .. tostring(mission_duration) .. ";" .. player .. "\n"
end

-- Serialize buff data to a string
local function serialize_buff(buff_name, buff_data, mission_duration)
    -- Calculate uptime percentage
    local uptime_percent = 0
    if mission_duration > 0 and buff_data.total_uptime then
        uptime_percent = (buff_data.total_uptime / mission_duration) * 100
    end

    -- Calculate average stack count
    local avg_stacks = 0
    if buff_data.total_uptime and buff_data.total_uptime > 0 then
        avg_stacks = buff_data.stack_time_product / buff_data.total_uptime
    end

    -- Return serialized buff info
    return "#buff;" .. buff_name .. ";" .. tostring(buff_data.total_uptime or 0) .. ";" ..
            tostring(uptime_percent) .. ";" .. tostring(avg_stacks) .. ";" ..
            tostring(buff_data.icon or "") .. ";" .. tostring(buff_data.gradient_map or "") .. "\n"
end

-- Deserialize a mission line into data
local function deserialize_mission(line)
    local info = split(line, ";")
    local mission_data = {
        name = info[2] or "Unknown",
        duration = tonumber(info[3]) or 0,
        player = info[4]
    }

    -- Format duration as a readable time string
    local seconds = mission_data.duration
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds / 60) % 60)
    seconds = math.floor(seconds % 60)

    if hours < 10 then
        hours = "0" .. tostring(hours)
    else
        hours = tostring(hours)
    end
    if minutes < 10 then
        minutes = "0" .. tostring(minutes)
    else
        minutes = tostring(minutes)
    end
    if seconds < 10 then
        seconds = "0" .. tostring(seconds)
    else
        seconds = tostring(seconds)
    end

    mission_data.formatted_time = hours .. ":" .. minutes .. ":" .. seconds

    return mission_data
end

-- Deserialize a buff line into data
local function deserialize_buff(line)
    local info = split(line, ";")
    local buff_data = {
        name = info[2],
        total_uptime = tonumber(info[3]) or 0,
        uptime_percent = tonumber(info[4]) or 0,
        avg_stacks = tonumber(info[5]) or 0,
        icon = info[6] ~= "nil" and info[6] or nil,
        gradient_map = info[7] ~= "nil" and info[7] or nil
    }

    return buff_data
end

-- Save the uptime data to a file
mod.save_entry = function(self, active_buffs, mission_name, mission_duration, player_name)
    -- Create appdata folder
    self:create_uptime_history_directory()

    -- Generate file path
    local path, file_name = self:create_uptime_history_entry_path()

    -- Open file
    local file = assert(_io.open(path, "w+"))

    file:write(serialize_mission(mission_name, mission_duration, player_name))

    -- Write buff data
    for buff_name, buff_data in pairs(active_buffs) do
        file:write(serialize_buff(buff_name, buff_data, mission_duration))
    end

    -- Close file
    file:close()

    local cache = self:get_history_entries_cache()
    cache[#cache + 1] = file_name
    self:set_history_entries_cache(cache)

    mod:echo("[Uptime] History saved to: " .. file_name)
end

-- Load uptime data from a file
mod.load_entry = function(self, path)
    if not file_exists(path) then
        mod:echo("[Uptime] Error: File not found: " .. path)
        return nil
    end

    local entry = {
        mission = {},
        buffs = {}
    }

    -- Read file line by line
    for line in _io.lines(path) do
        -- Check line type
        local mission_match = line:match("#mission")
        local buff_match = line:match("#buff")

        if mission_match then
            -- Parse mission info
            entry.mission = deserialize_mission(line)
        elseif buff_match then
            -- Parse buff info
            local buff_data = deserialize_buff(line)
            entry.buffs[buff_data.name] = buff_data
        end
    end
    entry.file_path = path

    return entry
end

local function scandir(directory)
    local i, file_names, popen = 0, {}, _io.popen
    local pfile = popen('dir "' .. directory .. '" /b')
    for filename in pfile:lines() do
        i = i + 1
        file_names[i] = filename
    end
    pfile:close()
    mod:echo("[Uptime] History entries loaded from directory")
    mod:echo(file_names[1])
    return file_names
end

-- Get all uptime history entries
mod.get_history_entries = function(self, scan_dir)
    local entries = {}
    local appdata = self:appdata_path()
    local cache = self:get_history_entries_cache()
    local file_names = cache

    if scan_dir or not cache then
        file_names = scandir(appdata)
        self:set_history_entries_cache(file_names)
    end

    local missing_file = false
    for _, file in pairs(file_names) do
        local file_path = appdata .. file
        if file_exists(file_path) then
            local date_str = string.sub(file, 1, string.len(file) - 4)
            local entry = self:load_entry(file_path)

            if entry then
                entry.file = file
                entry.file_path = file_path
                entry.date = _os.date("%Y-%m-%d %H:%M:%S", tonumber(date_str))
                entries[#entries + 1] = entry
            end
        else
            missing_file = true
        end
    end

    if missing_file then
        entries = self:get_history_entries(true)
    end

    return entries
end

-- Get cache of history entries
mod.get_history_entries_cache = function(self)
    return self:get("uptime_history_entries") or {}
end

-- Set cache of history entries
mod.set_history_entries_cache = function(self, entries)
    self:set("uptime_history_entries", entries)
end
-- Delete an entry and update the cache
function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

mod.delete_entry = function(self, entry)
    -- Only proceed if an entry is provided
    if not entry or not entry.file_path then
        return false
    end

    -- Try to remove the file
    if _os.remove(entry.file_path) then
        -- Update the cache to remove the deleted entry
        local cache = mod:get_history_entries_cache()
        local new_cache = {}

        for _, cache_entry in pairs(cache) do
            local is_deleted_entry = ends_with(entry.file_path, cache_entry)
            if not is_deleted_entry then
                new_cache[#new_cache + 1] = cache_entry
            end
        end

        -- Save the updated cache
        mod:set_history_entries_cache(new_cache)
        return true
    end

    return false
end

mod:command("load", "", function()
    mod:test_load_functionality()
end)

-- Test function to verify loading functionality
mod.test_load_functionality = function(self)
    -- Get all history entries
    local entries = self:get_history_entries()

    if #entries == 0 then
        mod:echo("[Uptime] No history entries found to test loading functionality")
        return
    end

    -- Display information about the most recent entry
    local most_recent = entries[#entries]
    mod:echo("[Uptime] Testing load functionality with: " .. most_recent.file)
    mod:echo("[Uptime] Mission: " .. most_recent.mission.name .. " (" .. most_recent.mission.formatted_time .. ")")

    -- Display information about the buffs
    local buff_count = 0
    for buff_name, buff_data in pairs(most_recent.buffs) do
        buff_count = buff_count + 1
        local text = string.format("%.1f%s", buff_data.uptime_percent, "%%")
        mod:echo(text)

        mod:echo(string.format("[Uptime] Buff: %s - %.1f%s uptime, %.2f avg stacks",
                buff_name,
                buff_data.uptime_percent,
                "%%",
                buff_data.avg_stacks))

        -- Only show the first 5 buffs to avoid spam
        if buff_count >= 5 then
            local remaining = table.size(most_recent.buffs) - 5
            if remaining > 0 then
                mod:echo(string.format("[Uptime] ... and %d more buffs", remaining))
            end
            break
        end
    end

    mod:echo("[Uptime] Load functionality test completed")
end