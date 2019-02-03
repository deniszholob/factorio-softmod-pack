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

-- Event Functions --
-- ======================================================= --

-- When a player dies, place a marker on the map of death location
-- @param event - on_pre_player_died
function on_player_death(event)
    local player = game.players[event.player_index]
    local death_hms = Time.tick_to_time_hms(game.tick)
    local map_tag = {
        position = player.position,
        text = player.name .. '-Death@' .. death_hms.h .. ':' .. death_hms.m .. ':' .. death_hms.s,
        last_user = player
    }
    player.force.add_chart_tag(player.surface, map_tag)
end

-- Event Registration --
-- ======================================================= --
if(Event) then
    Event.register(defines.events.on_pre_player_died, on_player_death)
else
    script.on_event(defines.events.on_pre_player_died, on_player_death)
end
