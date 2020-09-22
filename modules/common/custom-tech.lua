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
local Custom_Tech = {
    -- Research to disable
    DISABLED_RESEARCH_LIST = {
        'atomic-bomb',
        'discharge-defense-equipment',
        -- 'logistic-system'
    },
    -- Recipies to disable
    DISABLED_RECIPE_LIST = {
        'atomic-bomb',
        'discharge-defense-equipment',
    },
    -- Tech to begin researched with
    RESEARCH_TECH = {
        'toolbelt',
        'steel-axe',
        'optics',
    },
    PRINT_DISABLED_TECH = false,
    ENABLE_RESEARCH_QUEUE = true,
}

-- Event Functions --
-- ======================================================= --

-- Various action when new player joins in game
-- @param event on_player_created event
function Custom_Tech.on_player_created(event)
    local player = game.players[event.player_index]

    -- Research to disable
    for i, research in ipairs(Custom_Tech.DISABLED_RESEARCH_LIST) do
        player.force.technologies[research].enabled = false
        if Custom_Tech.PRINT_DISABLED_TECH then player.print({'custom_tech.disable_research', research}) end
    end

    -- Recipies to disable
    for i, recipe in ipairs(Custom_Tech.DISABLED_RECIPE_LIST) do
        player.force.recipes[recipe].enabled = false
        if Custom_Tech.PRINT_DISABLED_TECH then player.print({'custom_tech.disable_recipe', recipe}) end
    end

    -- Tech to start already researched with
    for i, research in ipairs(Custom_Tech.RESEARCH_TECH) do
        player.force.technologies[research].researched = true
    end

    if(Custom_Tech.ENABLE_RESEARCH_QUEUE) then
        player.force.research_queue_enabled = true
        -- game.difficulty_settings.research_queue_setting = "always"
    end

    -- Enable Research Queue
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_created, Custom_Tech.on_player_created)

-- Helper Functions --
-- ======================================================= --
