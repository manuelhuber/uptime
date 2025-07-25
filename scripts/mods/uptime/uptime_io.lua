local mod = get_mod("uptime")
local DMF = get_mod("DMF")
local json = mod:io_dofile("uptime/scripts/mods/uptime/libs/json")

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

-- Save the uptime data to a file
mod.save_entry = function(self, entry)

    -- Create appdata folder
    self:create_uptime_history_directory()

    -- Generate file path
    local path, file_name = self:create_uptime_history_entry_path()

    -- Open file
    local file = assert(_io.open(path, "w+"))

    local entry_json = json.encode(entry)
    file:write(entry_json)

    -- Close file
    file:close()

    local cache = self:get_history_entries_cache()
    cache[#cache + 1] = file_name
    self:set_history_entries_cache(cache)
end

-- Load uptime data from a file
mod.load_entry = function(self, path)
    if not file_exists(path) then
        mod:echo("Error: File not found: " .. path)
        return nil
    end

    local entry = nil
    for entry_json in _io.lines(path) do
        if entry then
            mod:echo("Received more than 1 line when loading file!")
        else
            entry = json.decode(entry_json)
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
    mod:echo("History entries loaded from directory")
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