-- Player Logging Soft Module
-- Logs who joined/left the server
-- Logs Player count when playes join/leave server
-- @usage require('modules/dddgamer/player-logging')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local Time = require('util/Time')

-- Constants --
-- ======================================================= --

Player_Logging = {}

-- On player join log player name
-- @param event on_player_joined_game
function Player_Logging.on_player_join(event)
    local player = game.players[event.player_index]
    -- local time_str = os.date("%I:M:%S %p", os.time())
    log("\n === [INFO] <Player Joined> name="..player.name)
    log("\n === [INFO] <Players Online> count=" .. #game.connected_players)
end

-- On player left log player name
-- @param event on_player_joined_game
function Player_Logging.on_player_leave(event)
    local player = game.players[event.player_index]
    -- local time_str = os.date("%Y-%m-%d %I:M:%S %p", os.time())
    log("\n === [INFO] <Player Left> name="..player.name)
    log("\n === [INFO] <Players Online> count=" .. #game.connected_players)
end

-- When new player uses decon planner log it
-- @param event on_player_deconstructed_area
function Player_Logging.on_player_deconstructed_area(event)
    local player = game.players[event.player_index]
    if (Time.griefer_threshold(player)) then
        log("\n === [WARN] <Player Used Decon> name="..player.name)
    end
end

-- When new player mines something log it
-- @param event on_player_mined_item
function Player_Logging.on_player_mined_item(event)
    local player = game.players[event.player_index]
    if (Time.griefer_threshold(player)) then
        log("\n === [WARN] <Player Mined> name="..player.name)
    end
end

Event.register(defines.events.on_player_joined_game, Player_Logging.on_player_join)
Event.register(defines.events.on_player_left_game, Player_Logging.on_player_leave)
Event.register(defines.events.on_player_deconstructed_area, Player_Logging.on_player_deconstructed_area)
Event.register(defines.events.on_player_mined_item, Player_Logging.on_player_mined_item)
