-- No Handcrafting Soft Module
-- Based on arya's kit mod
-- Uses locale no-hand-crafting.cfg
-- @usage require('modules/common/no-hand-crafting')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --

-- Constants --
-- ======================================================= --
local NO_HAND_CRAFT_PERMISSION_GROUP = 'no_hand_craft'
local NO_HAND_CRAFT_DEFAULT_SETTINGS = {
    -- Clear out inventory b4 giving items, or add the no handcraft kit items to whatever player has already
    onlyNoHandCraftKit = false,
    -- Gives steam engine instead of solar panel
    useSteamInsteadOfSolar = false,
    -- Adds an accumulator to be able to craft at night
    addAccumulator = false
}

-- Event Functions --
-- ======================================================= --

-- Various action when new player joins in game
-- @param event on_player_created event
function on_player_created(event)
    local player = game.players[event.player_index]
    addNoHandcraftKitItems(player)
    disallowHandcrafting(player)
    player.print({'no-hand-craft.info'})
end

-- Event Registration
-- ================== --
Event.register(defines.events.on_player_created, on_player_created)

-- Helper Functions --
-- ======================================================= --

-- Give player starting items for a no-handcrafting game.
-- @param player LuaPlayer
function addNoHandcraftKitItems(player)
    -- Always get the Lvl 3 Assembler as it can craft every item in the game
    player.insert {name = 'assembling-machine-3', count = 1}
    -- Always include power pole as needed to transmit power
    player.insert {name = 'medium-electric-pole', count = 1}

    -- Power (solar or steam)
    if NO_HAND_CRAFT_DEFAULT_SETTINGS.useSteamInsteadOfSolar then
        player.insert {name = 'offshore-pump', count = 1}
        player.insert {name = 'boiler', count = 1}
        player.insert {name = 'steam-engine', count = 1}
    else
        player.insert {name = 'solar-panel', count = 1}
    end

    -- Accumulators
    if NO_HAND_CRAFT_DEFAULT_SETTINGS.addAccumulator then
        player.insert {name = 'basic-accumulator', count = 1}
    end
end

-- Disable handcrafting permissions for player
-- @param player LuaPlayer
function disallowHandcrafting(player)
    -- Get existing grouip or add one if doesnt exist
    local group =
        game.permissions.get_group(NO_HAND_CRAFT_PERMISSION_GROUP) or
        game.permissions.create_group(NO_HAND_CRAFT_PERMISSION_GROUP)

    -- Dissalow Hand Crafting (https://lua-api.factorio.com/latest/defines.html)
    group.set_allows_action(defines.input_action['craft'], false)
    -- Add player to the group
    game.permissions.get_group(NO_HAND_CRAFT_PERMISSION_GROUP).add_player(player)
end
