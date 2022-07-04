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
local AdminPlayerInventory = {
    MENU_BTN_NAME = 'btn_menu_admin_player_inventory',
    MASTER_FRAME_NAME = 'frame_admin_player_inventory',
    OWNER = 'DDDGamer',
    OWNER_ONLY = true
}

-- Event Functions --
-- ======================================================= --
--- When new player joins add a btn to their button_flow
--- Redraw this softmod's frame
--- Only happens for admins/owner depending on OWNER_ONLY flag
--- @param event on_player_joined_game
function AdminPlayerInventory.on_player_joined(event)
    local player = game.players[event.player_index]
    if (AdminPlayerInventory.OWNER_ONLY) then
        if (player.name == AdminPlayerInventory.OWNER) then
            AdminPlayerInventory.draw_menu_btn(player)
            AdminPlayerInventory.draw_master_frame(player)
        end
    elseif (player.admin == true) then
        AdminPlayerInventory.draw_menu_btn(player)
        AdminPlayerInventory.draw_master_frame(player)
    end
end


--- When a player leaves clean up their GUI in case this mod gets removed next time
--- @param event on_player_left_game
function AdminPlayerInventory.on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(
        mod_gui.get_button_flow(player)[AdminPlayerInventory.MENU_BTN_NAME]
    )
    GUI.destroy_element(
        mod_gui.get_frame_flow(player)[AdminPlayerInventory.MASTER_FRAME_NAME]
    )
end


-- Event Registration --
-- ======================================================= --
Event.register(
    defines.events.on_player_joined_game, AdminPlayerInventory.on_player_joined
)
Event.register(
    defines.events.on_player_left_game, AdminPlayerInventory.on_player_left_game
)

-- Helper Functions --
-- ======================================================= --

---
--- @param player LuaPlayer
function AdminPlayerInventory.draw_menu_btn(player)
    if mod_gui.get_button_flow(player)[AdminPlayerInventory.MENU_BTN_NAME] ==
        nil then
        mod_gui.get_button_flow(player).add(
            {
                type = "sprite-button",
                name = AdminPlayerInventory.MENU_BTN_NAME,
                sprite = "entity/player",
                -- caption = 'Players Inventory',
                tooltip = "Acces other players inventory"
            }
        )
    end
end


---
--- @param player LuaPlayer
function AdminPlayerInventory.draw_master_frame(player)

end

