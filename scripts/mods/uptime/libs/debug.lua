local mod = get_mod("uptime")

function print_keys(table)
    for key, _ in pairs(table) do
        mod:echo(key)
    end
end

return {
    print_keys = print_keys
}