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
PlayerInit = {
    -- Time in Minutes
    AGE = {
        NOMAD = 20,
        IRON = 60,
        STEEL = 120
    },
    REVEAL_AREA_RADIUS = 256, -- 256
}


-- Event Functions --
-- ======================================================= --

--- Various action when new player joins in game
--- @param event defines.events.on_player_created event
function PlayerInit.on_player_created(event)
    local player = game.players[event.player_index]
    PlayerInit.reveal_area(player)
    PlayerInit.addStartingItems(player)
    player.print({'msg-dddgamer-intro'})

    if (player.name == 'DDDGamer') then
        local color = Colors.red_sat
        player.color = color
        player.chat_color = color
    end
    game.print({'mgs-new-player', player.name})
end

--- Give player stuff after they respawn.
--- @param event defines.events.on_player_respawned event
function PlayerInit.on_player_respawned(event)
    local player = game.players[event.player_index]
    PlayerInit.addBasicItems(player)
end

--- Alert player left
--- @param event defines.events.on_player_leave event
function PlayerInit.on_player_leave(event)
    local player = game.players[event.player_index]
    game.print({"msg-player-left", player.name})
end

-- Event Registration
-- ======================================================= --
Event.register(defines.events.on_player_created, PlayerInit.on_player_created)
Event.register(defines.events.on_player_respawned, PlayerInit.on_player_respawned)
Event.register(defines.events.on_player_left_game, PlayerInit.on_player_leave)

-- Helper Functions --
-- ======================================================= --

--- Give player basic items appropriate with research: gun, ammo
--- @param player LuaPlayer
function PlayerInit.addBasicItems(player)
    -- Lets avoid hoarding pistols...
    if (PlayerInit.is_military_1_researched(player)) then
        player.insert {name = 'submachine-gun', count = 1}
    else
        player.insert {name = 'pistol', count = 1}
    end

    -- Yellow ammo is useless...
    if (PlayerInit.is_military_2_researched(player)) then
        player.insert {name = 'piercing-rounds-magazine', count = 10}
    else
        player.insert {name = 'firearm-magazine', count = 10}
    end
end

--- Give player basic starting items.
--- @param player LuaPlayer
function PlayerInit.addStartingItems(player)
    -- Always start a new player with these
    player.insert {name = 'iron-plate', count = 10}
    PlayerInit.addBasicItems(player)

    -- Give different items depending on game time
    -- Ex: No need for burner miners late game
    if Time.tick_to_min(game.tick) < PlayerInit.AGE.NOMAD then
        player.insert {name = 'stone-furnace', count = 1}
        player.insert {name = 'burner-mining-drill', count = 3}
        player.insert {name = 'wooden-chest', count = 1}
    end
end

--- Reveal area around the player
--- @param player LuaPlayer
function PlayerInit.reveal_area(player)
    local pX = player.position.x;
    local pY = player.position.y;
    local r = PlayerInit.REVEAL_AREA_RADIUS;
    player.force.chart(
        player.surface,
        {
            {x = pX - r, y = pY - r},
            {x = pX + r, y = pY + r}
        }
    )
end

--- @param player LuaPlayer
--- @return booleanTrue if steel is researched
function PlayerInit.is_steel_researched(player)
    return player.force.technologies['steel-processing'].researched
end

--- @param player LuaPlayer
--- @return boolean True if Military 1 is researched
function PlayerInit.is_military_1_researched(player)
    return player.force.technologies['military'].researched
end

--- @param player LuaPlayer
--- @return boolean True if Military 2 is researched
function PlayerInit.is_military_2_researched(player)
    return player.force.technologies['military-2'].researched
end
