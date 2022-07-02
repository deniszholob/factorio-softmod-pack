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
CustomTech = {
    -- Research to disable
    DISABLED_RESEARCH_LIST = {
        -- 'atomic-bomb',
        'discharge-defense-equipment',
        -- 'logistic-system'
        -- 'logistics-3'
    },
    -- Recipies to disable
    DISABLED_RECIPE_LIST = {
        -- 'atomic-bomb',
        'discharge-defense-equipment',
        -- 'fast-transport-belt',
        -- 'express-transport-belt',
        -- 'underground-belt',
        -- 'fast-underground-belt',
        -- 'express-underground-belt',
        -- 'splitter',
        -- 'fast-splitter',
        -- 'express-splitter'
    },
    -- Tech to begin researched with (ignored if "RESEARCH_ALL_TECH" is true)
    RESEARCH_TECH = {
        'toolbelt',
        'steel-axe',
        'optics',
        'circuit-network',
        'construction-robotics',
        'logistic-robotics',
        'logistic-system',
    },
    -- Turn off to only research "RESEARCH_TECH" list above
    RESEARCH_ALL_TECH = false,
    PRINT_DISABLED_TECH = false,
    ENABLE_RESEARCH_QUEUE = true,
}

-- Event Functions --
-- ======================================================= --

--- Various action when new player joins in game
--- @param event defines.events.on_player_created event
function CustomTech.on_player_created(event)
    local player = game.players[event.player_index]

    -- Research to disable
    for i, research in ipairs(CustomTech.DISABLED_RESEARCH_LIST) do
        player.force.technologies[research].enabled = false
        if CustomTech.PRINT_DISABLED_TECH then player.print({'custom_tech.disable_research', research}) end
    end

    -- Recipies to disable
    for i, recipe in ipairs(CustomTech.DISABLED_RECIPE_LIST) do
        player.force.recipes[recipe].enabled = false
        if CustomTech.PRINT_DISABLED_TECH then player.print({'custom_tech.disable_recipe', recipe}) end
    end

    -- Tech to start already researched with
    if(CustomTech.RESEARCH_ALL_TECH) then
        player.force.research_all_technologies()
    else
        for i, research in ipairs(CustomTech.RESEARCH_TECH) do
            player.force.technologies[research].researched = true
        end
    end

    -- Enable Research Queue
    if(CustomTech.ENABLE_RESEARCH_QUEUE) then
        player.force.research_queue_enabled = true
        -- game.difficulty_settings.research_queue_setting = "always"
    end

    -- Research all tech

end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_created, CustomTech.on_player_created)

-- Helper Functions --
-- ======================================================= --
