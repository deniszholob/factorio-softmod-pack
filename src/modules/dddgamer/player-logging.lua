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
PlayerLogging = {
    LOG_FILE_NAME = 'player-log.log',
    LOG_FILE_INDEX = 0 -- change to 1 for SP/local testing, 0 for servers
}

--- On player join log player name
--- @param event defines.events.on_player_joined_game
function PlayerLogging.on_player_join(event)
    local player = game.players[event.player_index]
    -- local time_str = os.date('%I:M:%S %p', os.time())
    -- local text = '(' .. #game.connected_players .. ') "'.. player.name .. '"'
    -- local text = '"'.. player.name .. '"' .. ' (' .. #game.connected_players .. ')'
    -- PlayerLogging.logInfo('Player Join', text)
    PlayerLogging.logInfo('Player Join', '"' .. player.name .. '"')
    PlayerLogging.logInfo('Player Count', #game.connected_players)
end

--- On player left log player name
--- @param event defines.events.on_player_joined_game
function PlayerLogging.on_player_leave(event)
    local player = game.players[event.player_index]
    -- local time_str = os.date('%Y-%m-%d %I:M:%S %p', os.time())
    -- PlayerLogging.logInfo('Player Left', '(' .. #game.connected_players .. ') "' .. player.name .. '"')
    PlayerLogging.logInfo('Player Left', '"' .. player.name .. '"')
    PlayerLogging.logInfo('Player Count', #game.connected_players)
end

--- When new player uses decon planner log it
--- @param event defines.events.on_player_deconstructed_area
function PlayerLogging.on_player_deconstructed_area(event)
    local player = game.players[event.player_index]

    -- Player is cancelling the decon planner
    if (event.alt) then
        return
    end

    local decon_points = {
        left_top_x = math.floor(event.area.left_top.x),
        left_top_y = math.floor(event.area.left_top.y),
        right_bottom_x = math.ceil(event.area.right_bottom.x),
        right_bottom_y = math.ceil(event.area.right_bottom.y),
    }

    local tiles_dx = decon_points.right_bottom_x - decon_points.left_top_x
    local tiles_dy = decon_points.right_bottom_y - decon_points.left_top_y
    local tiles_total = tiles_dx * tiles_dy
    local chunks = tiles_total / 1024

    local text_player = string.format('"%s"', player.name)
    local text_tiles = string.format(' | tiles: %d', tiles_total)
    local text_chunks = string.format(' | chunks: %d', chunks)
    local text_selection = string.format(' | selection: (%d,%d) => (%d,%d)', decon_points.left_top_x, decon_points.left_top_y, decon_points.right_bottom_x, decon_points.right_bottom_y)
    local text = text_player .. text_tiles .. text_chunks .. text_selection

    if (Time.new_player_threshold(player)) then
        if(chunks > 100) then 
            game.print('WARNING! ' .. text_player .. ' deconed ' .. chunks .. ' chunks')
        end
        PlayerLogging.logWarn('Player Decon', text)
    else
        PlayerLogging.logWarn('Player Decon', text, true)
    end
end

--- When new player mines something log it
--- @param event defines.events.on_player_mined_entity
function PlayerLogging.on_player_mined_entity(event)
    local player = game.players[event.player_index]
    local entity = event.entity

    -- Simple entities we dont care about
    if(PlayerLogging.entityFilter(entity)) then
        return
    end

    local text = '"' .. player.name .. '" ("' .. entity.name .. '")'

    if (Time.new_player_threshold(player)) then
        PlayerLogging.logWarn('Player Decon', text, false)
    else
        PlayerLogging.logWarn('Player Decon', text, true)
    end
end

--- When research finishes log it and print it
--- @param event defines.events.on_research_finished
function PlayerLogging.on_research_finished(event)
    local research_name = event.research.name
    local notification = {'Player_Logging.research', research_name}
    game.print(notification)
    PlayerLogging.logInfo('Research Complete', '"'.. research_name .. '"')
end

--- Log chat
--- @param event defines.events.on_console_chat
function PlayerLogging.on_console_chat(event)
    local player = game.players[event.player_index]
    PlayerLogging.logChat(player.name, event.message)
end

--- @return boolean True if not a basic item(trees, ores, drills, etc.)
function PlayerLogging.entityFilter(entity)
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

function PlayerLogging.logInfo(name, text)
    PlayerLogging.logEvent('INFO', name, text)
end
function PlayerLogging.logWarn(name, text, skip_factorio_log)
    PlayerLogging.logEvent('WARN', name, text, skip_factorio_log)
end
function PlayerLogging.logError(name, text)
    PlayerLogging.logEvent('ERROR', name, text)
end
function PlayerLogging.logChat(name, text)
    PlayerLogging.logEvent('CHAT', name, text, true)
end
function PlayerLogging.logEvent(log_type, event_name, event_text, skip_factorio_log)
    local time = Time.game_time_pased_string();
    local log_txt = '\n=== ' .. time .. ' [' ..log_type.. '] ' .. '<' .. event_name .. '>: ' .. event_text
    PlayerLogging.log(log_txt, skip_factorio_log)
end
function PlayerLogging.log(log_txt, skip_factorio_log)
    if(not skip_factorio_log) then log(log_txt) end
    -- https://lua-api.factorio.com/latest/LuaGameScript.html#LuaGameScript.write_file
    game.write_file(PlayerLogging.LOG_FILE_NAME, log_txt, true, PlayerLogging.LOG_FILE_INDEX)
end

Event.register(defines.events.on_player_joined_game, PlayerLogging.on_player_join)
Event.register(defines.events.on_player_left_game, PlayerLogging.on_player_leave)
Event.register(defines.events.on_player_deconstructed_area, PlayerLogging.on_player_deconstructed_area)
Event.register(defines.events.on_player_mined_entity, PlayerLogging.on_player_mined_entity)
Event.register(defines.events.on_research_finished, PlayerLogging.on_research_finished)
Event.register(defines.events.on_console_chat, PlayerLogging.on_console_chat)
