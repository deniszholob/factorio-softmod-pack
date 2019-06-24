-- Player Init Soft Module
-- Changes spawn and respawn items from vanilla version
-- @usage require('modules/dddgamer/player-init-dddgamer')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local Time = require('util/Time')
local Colors = require('util/Colors')

-- Constants --
-- ======================================================= --

-- Time in Minutes
local AGE = {
    NOMAD = 20,
    IRON = 60,
    STEEL = 120
}

local REVEAL_AREA_RADIUS = 250

-- Event Functions --
-- ======================================================= --

-- Various action when new player joins in game
-- @param event on_player_created event
function on_player_created(event)
    local player = game.players[event.player_index]
    -- reveal_area(player)
    addStartingItems(player)
    -- addBasicItems(player)
    player.print({'msg-dddgamer-intro'})

    if (player.name == 'DDDGamer') then
        local color = Colors.red_sat
        player.color = color
        player.chat_color = color
    end
    game.print({'mgs-new-player', player.name})
end

-- Give player stuff after they respawn.
-- @param event on_player_respawned event
function on_player_respawned(event)
    local player = game.players[event.player_index]
    addBasicItems(player)
end

-- Event Registration
-- ======================================================= --
Event.register(defines.events.on_player_created, on_player_created)
Event.register(defines.events.on_player_respawned, on_player_respawned)

-- Helper Functions --
-- ======================================================= --

-- Give player basic items appropriate with research: gun, ammo
-- @param player LuaPlayer
function addBasicItems(player)
    -- Lets avoid hoarding pistols...
    if (is_military_1_researched(player)) then
        player.insert {name = 'submachine-gun', count = 1}
    else
        player.insert {name = 'pistol', count = 1}
    end

    -- Yellow ammo is useless...
    if (is_military_2_researched(player)) then
        player.insert {name = 'piercing-rounds-magazine', count = 10}
    else
        player.insert {name = 'firearm-magazine', count = 10}
    end
end

-- Give player basic starting items.
-- @param player LuaPlayer
function addStartingItems(player)
    -- Always start a new player with these
    player.insert {name = 'iron-plate', count = 10}
    player.insert {name = 'pistol', count = 1}
    player.insert {name = 'firearm-magazine', count = 10}

    -- Give different items depending on game time
    -- Ex: No need for burner miners late game
    if Time.tick_to_min(game.tick) < AGE.NOMAD then
        player.insert {name = 'stone-furnace', count = 1}
        player.insert {name = 'burner-mining-drill', count = 3}
        player.insert {name = 'wooden-chest', count = 1}
    end
end

-- Reveal area around the player
-- @param player LuaPlayer
function reveal_area(player)
    player.force.chart(
        player.surface,
        {
            {player.position.x - REVEAL_AREA_RADIUS, player.position.y - REVEAL_AREA_RADIUS},
            {player.position.x + REVEAL_AREA_RADIUS, player.position.y + REVEAL_AREA_RADIUS}
        }
    )
end

-- @return True if steel is researched
-- @param player LuaPlayer
function is_steel_researched(player)
    return player.force.technologies['steel-processing'].researched
end

-- @return True if Military 1 is researched
-- @param player LuaPlayer
function is_military_1_researched(player)
    return player.force.technologies['military'].researched
end

-- @return True if Military 2 is researched
-- @param player LuaPlayer
function is_military_2_researched(player)
    return player.force.technologies['military-2'].researched
end
