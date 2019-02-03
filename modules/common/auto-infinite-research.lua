-- Auto Infinite Research Soft Module
-- https://mods.factorio.com/mod/MegabaseAutoResearch
-- Automatically research robot worker speed and mining productivity research for ease of megabase researching.
-- The research to be chosen is based on cheapest total cumulative cost.
-- Uses locale __modulename__.cfg
-- @usage require('modules/common/auto-infinite-research')
-- ------------------------------------------------------- --
-- @author can00336 (https://mods.factorio.com/user/can00336)
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local mod_gui = require("mod-gui") -- From `Factorio\data\core\lualib`
local GUI = require("stdlib/GUI")
local Colors = require("util/Colors")

-- Constants --
-- ======================================================= --
local MENU_BTN_NAME = 'btn_menu_auto-infinite-research'
local MASTER_FRAME_NAME = 'frame_auto-infinite-research'

-- Event Functions --
-- ======================================================= --
-- When new player joins add a btn to their button_flow
-- Redraw this softmod's frame
-- @param event on_player_joined_game
function on_player_joined(event)
    local player = game.players[event.player_index]
    draw_menu_btn(player)
    -- draw_master_frame(player) -- dont draw yet, when btn clicked instead
end

-- When a player leaves clean up their GUI in case this mod gets removed next time
-- @param event on_player_left_game
function on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(mod_gui.get_button_flow(player)[MENU_BTN_NAME])
    GUI.destroy_element(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME])
end

-- Toggle gameinfo is called if gui element is gameinfo button
-- @param event on_gui_click
local function on_gui_click(event)
    local player = game.players[event.player_index]
    local el_name = event.element.name

    if el_name == MENU_BTN_NAME then
        -- Call toggle if frame has been created
        if(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME] ~= nil) then
            GUI.toggle_element(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME])
        else -- Call create if it hasnt
            draw_gameinfo_frame(player)
        end
    end
end


-- @param event on_research_finished
local function on_research_finished(event)
    local research = event.research
    local force = research.force
    local techs = force.technologies
    local wrs = techs["worker-robots-speed-6"].level
    local mp = techs["mining-productivity-16"].level
    local wrs_costs = 2^(wrs - 5) * 1000 + 50
    local mp_costs = 50 * (mp^2 - mp - 210) + 12000
    if mp_costs <= wrs_costs then
        force.current_research = "mining-productivity-16"
    else
        force.current_research = "worker-robots-speed-6"
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_joined_game, on_player_joined)
Event.register(defines.events.on_player_left_game, on_player_left_game)
-- Event.register(defines.events.on_research_finished, on_research_finished)

-- Helper Functions --
-- ======================================================= --

--
-- @tparam LuaPlayer player
function draw_menu_btn(player)
    if mod_gui.get_button_flow(player)[MENU_BTN_NAME] == nil then
        mod_gui.get_button_flow(player).add(
            {
                type = "sprite-button",
                name = MENU_BTN_NAME,
                sprite = "item/space-science-pack",
                -- caption = 'Auto Infinite Research',
                tooltip = "Auto Infinite Research Settings"
            }
        )
    end
end

--
-- @tparam LuaPlayer player
function draw_master_frame(player)

    -- game.print(serpent.block(infinite_research_list))

    local master_frame = mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME];
    -- Draw the vertical frame on the left if its not drawn already
    if master_frame == nil then
        master_frame = mod_gui.get_frame_flow(player).add({type = "frame", name = MASTER_FRAME_NAME, direction = "vertical"})
    end
    -- Clear and repopulate infinite research list
    GUI.clear_element(master_frame)
    for _, tech in pairs(infinite_research_list) do
        master_frame.add(
            {
                type = labe
            }
        )
    end


end

--
function canResearch(force, tech, config)
    if not tech or tech.researched or not tech.enabled then
        return false
    end
    for _, pretech in pairs(tech.prerequisites) do
        if not pretech.researched then
            return false
        end
    end
    -- if(config) then
    --     for _, ingredient in pairs(tech.research_unit_ingredients) do
    --         if not config.allowed_ingredients[ingredient.name] then
    --             return false
    --         end
    --     end
    -- end
    return true
end

-- @treturn LuaTechnology[] infinite_research_list List of technologies that can be infinite with space science
function get_infinite_research()
    local infinite_research_list = {}
    for _, tech in pairs(player.force.technologies) do
        if tech.research_unit_count_formula then -- Infinite tech
            local ingredients = tech.research_unit_ingredients
            for _, ingredient in pairs(ingredients) do -- Contains space science
                if(ingredient.name == 'space-science-pack') then
                    infinite_research_list[#infinite_research_list+1] = tech
                end
            end
      end
    end
    return infinite_research_list
end

--
function get_config()
    if not global.auto_infinite_research_config then
        global.auto_infinite_research_config = {}
    end
    if not global.auto_research_config[force.name] then
        global.auto_research_config[force.name] = {}
    end
end
