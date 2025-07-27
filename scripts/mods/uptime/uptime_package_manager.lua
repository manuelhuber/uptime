local mod = get_mod("uptime")

local required_packages = {}

function init()

    mod:hook_safe("PackageManager", "load", function(self, package_name, ...)
        -- mod:debug("loading " .. package_name)
    end)

    mod:hook("PackageManager", "_start_unloading_package", function(func, self, package_name)
        -- not sure if this package_name is the same as the icons we load.
        mod:debug("unloading " .. package_name)
        if not required_packages[package_name] then
            func(self, package_name)
        else
            mod:debug("prevented unloading " .. package_name)
        end
    end)
end

function load_resource(name)
    if not string.find(name, "content/ui/textures/icons/traits/weapon") then
        return
    end
    required_packages[name] = true
    Managers.package:load(name, "uptime", function()
        mod:debug("manually loaded " .. name)
    end)
    -- this causes crashes *sometimes*. TBD what to do.
    --pcall(function()
    --    end)
    --end)
end

function unload_resource(name)
    required_packages[name] = nil
end

return {
    init = init,
    load_resource = load_resource,
    unload_resource = unload_resource
}