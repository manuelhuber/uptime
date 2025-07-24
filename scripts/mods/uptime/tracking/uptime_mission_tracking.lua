local mod = get_mod("uptime")

mod.mission_tracking = {
    start_time = nil,
    end_time = nil,
    combats = {}
}

function mod:tracking_in_progress()
    local has_started = mod.mission_tracking.start_time ~= nil
    local has_ended = mod.mission_tracking.end_time ~= nil
    return has_started and (not has_ended)
end

function mod:start_mission_tracking()
    mod.mission_tracking.start_time = mod:now()
    mod.mission_tracking.end_time = nil
    mod.combats = {}
end

function mod:end_mission_tracking()
    mod.mission_tracking.end_time = mod:now()
end

function mod:now()
    if not Managers.time:has_timer("gameplay") then
        mod:echo("need time, but gameplay time doesn't exist")
        return 0
    end
    return Managers.time:time("gameplay")
end

mod:hook_safe(CLASS.AttackReportManager, "add_attack_result", function(func, self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage,
                                                                       attack_result, attack_type, damage_efficiency, ...)
    if player_from_unit(attacking_unit) or player_from_unit(attacked_unit) then
        mod:echo("in combat")
    end
end)

function player_from_unit(self, unit)
    if unit then
        local player = self.player_manager:local_player(1)
        if player.player_unit == unit then
            return player
        end
    end
    return nil
end