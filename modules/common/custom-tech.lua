-- Custom_Tech Soft Module
-- Disables certain technologies from being researched
-- Reference `factorio/data/base/prototypes/technology/rechnology.lua`
-- for list of tech and recipie names
-- @usage require('modules/common/custom-tech')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --

-- Constants --
-- ======================================================= --

-- Research to disable
local DISABLED_RESEARCH_LIST = {
    'atomic-bomb',
    'discharge-defense-equipment',
    -- 'logistic-system'
}

-- Recipies to disable
local DISABLED_RECIPE_LIST = {
    'atomic-bomb',
    'discharge-defense-equipment',
}

-- Tech to begin researched with
local RESEARCH_TECH = {
    'toolbelt',
    'steel-axe',
    'optics',
}

local PRINT_DISABLED_TECH = false

-- Event Functions --
-- ======================================================= --

-- Various action when new player joins in game
-- @param event on_player_created event
function on_player_created(event)
    local player = game.players[event.player_index]

    -- Research to disable
    for i, research in ipairs(DISABLED_RESEARCH_LIST) do
        player.force.technologies[research].enabled = false
        if PRINT_DISABLED_TECH then player.print({'custom_tech.disable_research', research}) end
    end

    -- Recipies to disable
    for i, recipe in ipairs(DISABLED_RECIPE_LIST) do
        player.force.recipes[recipe].enabled = false
        if PRINT_DISABLED_TECH then player.print({'custom_tech.disable_recipe', recipe}) end
    end

    -- Tech to start already researched with
    for i, research in ipairs(RESEARCH_TECH) do
        player.force.technologies[research].researched = true
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_created, on_player_created)

-- Helper Functions --
-- ======================================================= --
