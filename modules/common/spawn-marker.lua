-- Spawn Marker Module
-- Sets a marker on the map to show the spawn area
-- @usage require('modules/common/spawn-marker')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Constants --
-- ======================================================= --

-- Event Functions --
-- ======================================================= --

-- Various action when new player joins in game
-- @param event on_player_created event
function on_player_created(event)
    local player = game.players[event.player_index]
    if (not global.spawn_marked_on_map) then
        set_map_spawn_marker(player)
        global.spawn_marked_on_map = true
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_created, on_player_created)

-- Helper Functions --
-- ======================================================= --

-- Set spawn mark on map
-- @param player LuaPlayer
function set_map_spawn_marker(player)
    local spawn_position = player.force.get_spawn_position(player.surface)
    local map_tag = {
        position = spawn_position,
        text = 'Spawn',
        icon = {type = 'item', name = 'heavy-armor'}
    }

    -- FIXME: This doesnt work for some reason while the one on death does.
    player.force.add_chart_tag(player.surface, map_tag)
end
