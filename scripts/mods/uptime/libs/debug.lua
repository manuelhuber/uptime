local mod = get_mod("uptime")

local DEBUG = Managers.player:local_player_safe(1):account_id() == "485cb060-d152-4a53-a029-8e1e0584e160"

function mod:debug(msg)
    if DEBUG then
        mod:echo(msg)
    end
end

function mod.print_keys(table)
    for key, _ in pairs(table) do
        mod:echo(key)
    end
end

return {
    print_keys = mod.print_keys
}