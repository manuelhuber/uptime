local mod = get_mod("uptime")
local ItemUtils = mod:original_require("scripts/utilities/items")

function get_item_name(item)
    return ItemUtils.display_name(item)
end

return {
    get_name = get_item_name
}