-- Player Logging Soft Module
-- Logs who joined/left the server
-- Logs Player count when playes join/leave server
-- Uses locale player-logging.cfg
-- @usage require('modules/dddgamer/player-logging')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local Time = require('util/Time')
require('stdlib/string')

-- Constants --
-- ======================================================= --

local Player_Logging = {
    LOG_FILE_NAME="player-log.log"
}

-- On player join log player name
-- @param event on_player_joined_game
function Player_Logging.on_player_join(event)
    local player = game.players[event.player_index]
    -- local time_str = os.date("%I:M:%S %p", os.time())
    Player_Logging.logInfo('<Player Joined>: (' .. #game.connected_players .. ') "'.. player.name .. '"')
    -- Player_Logging.logInfo('Player Count: ' .. #game.connected_players)
end

-- On player left log player name
-- @param event on_player_joined_game
function Player_Logging.on_player_leave(event)
    local player = game.players[event.player_index]
    -- local time_str = os.date("%Y-%m-%d %I:M:%S %p", os.time())
    Player_Logging.logInfo('<Player Left>: (' .. #game.connected_players .. ') "' .. player.name .. '"')
    -- Player_Logging.logInfo('Player Count: ' .. #game.connected_players)
end

-- When new player uses decon planner log it
-- @param event on_player_deconstructed_area
function Player_Logging.on_player_deconstructed_area(event)
    local player = game.players[event.player_index]
    if (Time.new_player_threshold(player)) then
        Player_Logging.logWarn('<Player Deconed>: "' .. player.name .. '"')
    end
end

-- When new player mines something log it
-- @param event on_player_mined_entity
function Player_Logging.on_player_mined_entity(event)
    local player = game.players[event.player_index]
    local entity = event.entity
    if (
        Time.new_player_threshold(player) and
        not Player_Logging.entityFilter(entity)
    ) then
        Player_Logging.logWarn('<Player Mined>: "' .. player.name .. '" ("' .. entity.name .. '")')
    end
end

-- When research finishes log it and print it
-- @param event on_research_finished
function Player_Logging.on_research_finished(event)
    local research_name = event.research.name
    local notification = {'Player_Logging.research', research_name}
    game.print(notification)
    Player_Logging.logInfo('<Research Complete>: "'.. research_name .. '"')
end

-- Log chat
-- @param event on_console_chat
function Player_Logging.on_console_chat(event)
    local player = game.players[event.player_index]
    local message = event.message
    local text = player.name .. ": " .. message
    Player_Logging.logChat(text)
end

-- Returns true if not a basic item(trees, ores, drills, etc.)
function Player_Logging.entityFilter(entity)
    -- game.print('filter' .. entity.name)
    return (
        string.contains(entity.name, 'tree') or
        string.contains(entity.name, 'rock') or
        string.contains(entity.name, 'drill') or
        string.contains(entity.name, 'ore') or
        string.contains(entity.name, 'stone') or
        string.contains(entity.name, 'coal')
    )
end

-- Log functions --
-- ======================================================= --

function Player_Logging.logInfo(text)
    local log_txt = "\n=== [INFO] " .. text
    Player_Logging.log(log_txt)
end
function Player_Logging.logWarn(text)
    local log_txt = "\n=== [WARN] " .. text
    Player_Logging.log(log_txt)
end
function Player_Logging.logError(text)
    local log_txt = "\n=== [Error] " .. text
    Player_Logging.log(log_txt)
end
function Player_Logging.logChat(text)
    local log_txt = "\n=== [CHAT] " .. text
    Player_Logging.log(log_txt, true)
end
function Player_Logging.log(log_txt, skip_factorio_log)
    if(not skip_factorio_log) then log(log_txt) end
    -- https://lua-api.factorio.com/0.15.23/LuaGameScript.html#LuaGameScript.write_file
    game.write_file(Player_Logging.LOG_FILE_NAME, log_txt, true, 0) -- change to 1 for SP/local testing
end

Event.register(defines.events.on_player_joined_game, Player_Logging.on_player_join)
Event.register(defines.events.on_player_left_game, Player_Logging.on_player_leave)
Event.register(defines.events.on_player_deconstructed_area, Player_Logging.on_player_deconstructed_area)
Event.register(defines.events.on_player_mined_entity, Player_Logging.on_player_mined_entity)
Event.register(defines.events.on_research_finished, Player_Logging.on_research_finished)
Event.register(defines.events.on_console_chat, Player_Logging.on_console_chat)
