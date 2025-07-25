local mod = get_mod("uptime")

local required_packages = {}

function init()
    mod:hook("PackageManager", "_start_unloading_package", function(func, self, package_name)
        mod:echo("Unloading " .. tostring(package_name))
        if not required_packages[name] then
            func(self, package_name)
        end
    end)
end

function load_resource(name)
    required_packages[name] = true
    pcall(function()
        Managers.package:load(name, "uptime", function()
            mod:echo("Loaded " .. name)
        end)
    end)
end

function unload_resource(name)
    required_packages[name] = nil
end

return {
    init = init,
    load_resource = load_resource,
    unload_resource = unload_resource
}