-- Death Map Marker Module
-- Adds a marker on the map when a player dies at that location
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Dependencies
require "locale/softmod-modules-util/Time"

-- When a player dies, place a marker on the map of death location
-- @param event - on_pre_player_died
local function on_player_death(event)
  local player = game.players[event.player_index]
  local death_hms = Time.tick_to_time_hms(game.tick)
  local map_tag = {
    position = player.position,
    text = player.name .. "-Death@" .. death_hms.h .. ":" .. death_hms.m .. ":" .. death_hms.s,
    last_user = player
  }
  player.force.add_chart_tag(player.surface, map_tag)
end


-- Event handlers
Event.register(defines.events.on_pre_player_died, on_player_death)
