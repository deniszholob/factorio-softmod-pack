-- Simple Death Marker Soft Module
-- Places a marker on the map when player dies
-- @usage require('modules/dddgamer/death-marker-simple')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --
-- Dependencies --
-- ======================================================= --
local Time = require('util/Time')

-- Constants --
-- ======================================================= --
DeathMarker = {}

-- Event Functions --
-- ======================================================= --

--- When a player dies, place a marker on the map of death location
--- @param event defines.events.on_pre_player_died
function DeathMarker.on_player_death(event)
    local player = game.players[event.player_index]
    local death_hms = Time.tick_to_time_hms(game.tick)
    local time = death_hms.h .. ':' .. death_hms.m .. ':' .. death_hms.s
    local deathText = player.name .. '-Death@' .. time
    local map_tag = {
        position = player.position,
        text = deathText,
        last_user = player
    }
    player.force.add_chart_tag(player.surface, map_tag)
end


-- Event Registration --
-- ======================================================= --
if (Event) then
    Event.register(
        defines.events.on_pre_player_died, DeathMarker.on_player_death
    )
else
    script.on_event(
        defines.events.on_pre_player_died, DeathMarker.on_player_death
    )
end
