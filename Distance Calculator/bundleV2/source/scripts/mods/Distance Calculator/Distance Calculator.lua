local mod = get_mod("Distance Calculator")

mod.locations = {}
mod.locationcounter = 1


mod.location_save = function()
    local player_unit = Managers.player:local_player().player_unit
    local position = Unit.local_position(player_unit, 0)
    local rotation = Unit.local_rotation(player_unit, 0)
    mod.locations[mod.locationcounter] = {position.x, position.y, position.z}
    mod:echo("Location " .. mod.locationcounter .. " saved.")
    mod.locationcounter = mod.locationcounter + 1
    --mod:echo("[\"%s\"] = { {%f, %f, %f} }", Managers.state.game_mode._level_key, position.x, position.y, position.z)
end
mod:command("location_save", "save a location for calculation", function()
    location_save()
end)


mod.location_calculate = function()
    if mod.locationcounter > 0 then
        local L = mod.locations
        distance( L[1][1], L[1][2], L[1][3], L[2][1], L[2][2], L[2][3] )
        mod:echo("Distance:" .. " " .. mod.distance)
        mod.locations = {}
        mod.locationcounter = 1
    else
        mod:echo("Not enough locations saved to calcate.")
    end
end
mod:command("location_calculate", "get distance between locations", function()
    location_calculate()
end)

function distance( x1, y1, z1, x2, y2, z2 )
	mod.distance = math.sqrt( (x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2 )
end
