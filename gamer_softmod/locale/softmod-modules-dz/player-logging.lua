-- Player Logging Soft Mod
-- Logs who joined/left the server
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --


-- On player join log player name
-- @param event on_player_joined_game
function on_player_join(event)
  local player = game.players[event.player_index]
  -- local time_str = os.date("%I:M:%S %p", os.time())
  log("[Info] <Player Joined> name="..player.name)
  log("[Info] <Player Online> count=".. #game.connected_players)
end

-- On player left log player name
-- @param event on_player_joined_game
function on_player_leave(event)
  local player = game.players[event.player_index]
  -- local time_str = os.date("%Y-%m-%d %I:M:%S %p", os.time())
  log("[Info] <Player Left> name="..player.name)
  log("[Info] <Player Online> count=".. #game.connected_players)
end

Event.register(defines.events.on_player_joined_game, on_player_join)
Event.register(defines.events.on_player_left_game, on_player_leave)
