-- Admin Open Player Inventory Soft Module
-- Displays a table of all players with and button to open their inventory
-- Uses locale __modulename__.cfg
-- @usage require('modules/dddgamer/admin/admin-open-player-inventory')
-- ------------------------------------------------------- --
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
local MENU_BTN_NAME = 'btn_menu_admin_player_inventory'
local MASTER_FRAME_NAME = 'frame_admin_player_inventory'
local OWNER = 'DDDGamer'
local OWNER_ONLY = true

-- Event Functions --
-- ======================================================= --
-- When new player joins add a btn to their button_flow
-- Redraw this softmod's frame
-- Only happens for admins/owner depending on OWNER_ONLY flag
-- @param event on_player_joined_game
function on_player_joined(event)
    local player = game.players[event.player_index]
    if(OWNER_ONLY) then
        if(player.name == OWNER) then
            draw_menu_btn(player)
            draw_master_frame(player)
        end
    elseif(player.admin == true) then
        draw_menu_btn(player)
        draw_master_frame(player)
    end
end

-- When a player leaves clean up their GUI in case this mod gets removed next time
-- @param event on_player_left_game
function on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(mod_gui.get_button_flow(player)[MENU_BTN_NAME])
    GUI.destroy_element(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME])
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_joined_game, on_player_joined)
Event.register(defines.events.on_player_left_game, on_player_left_game)

-- Helper Functions --
-- ======================================================= --

--
-- @param player LuaPlayer
function draw_menu_btn(player)
    if mod_gui.get_button_flow(player)[MENU_BTN_NAME] == nil then
        mod_gui.get_button_flow(player).add(
            {
                type = "sprite-button",
                name = MENU_BTN_NAME,
                sprite = "entity/player",
                -- caption = 'Players Inventory',
                tooltip = "Acces other players inventory"
            }
        )
    end
end

--
-- @param player LuaPlayer
function draw_master_frame(player)

end

--
function function_name()

end

--
function function_name()

end

--
function function_name()

end
