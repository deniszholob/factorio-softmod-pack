-- Game Time Soft Module
-- Shows the game time at the top
-- Uses locale game-time.cfg
-- @usage require('modules/common/game-time')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local mod_gui = require("mod-gui") -- From `Factorio\data\core\lualib`
local GUI = require("stdlib/GUI")
local Colors = require("util/Colors")
local Styles = require("util/Styles")
local Math = require("util/Math")
local Time = require("util/Time")

-- Constants --
-- ======================================================= --

-- Constants --
-- ======================================================= --
Game_Time = {
    MASTER_BUTTON_NAME = 'btn_menu_gametime',
    MASTER_FRAME_NAME = 'frame_menu_gametime',
}

-- Event Functions --
-- ======================================================= --

-- When new player joins add the game time btn to their GUI
-- @param event on_player_joined_game
function Game_Time.on_player_joined(event)
    local player = game.players[event.player_index]
    Game_Time.draw_gametime_btn(player)
    Game_Time.draw_gametime_frame(player)
end

-- On Player Leave
-- Clean up the GUI in case this mod gets removed next time
-- @param event on_player_left_game
function Game_Time.on_player_leave(event)
    local player = game.players[event.player_index]
    if mod_gui.get_button_flow(player)[Game_Time.MASTER_BUTTON_NAME] ~= nil then
        mod_gui.get_button_flow(player)[Game_Time.MASTER_BUTTON_NAME].destroy()
    end
    if mod_gui.get_button_flow(player)[Game_Time.MASTER_FRAME_NAME] ~= nil then
        mod_gui.get_button_flow(player)[Game_Time.MASTER_FRAME_NAME].destroy()
    end
end

-- Toggle playerlist is called if gui element is playerlist button
-- @param event on_gui_click
function Game_Time.on_gui_click(event)
    local player = game.players[event.player_index]
    local el_name = event.element.name

    if el_name == Game_Time.MASTER_BUTTON_NAME then
        GUI.toggle_element(mod_gui.get_button_flow(player)[Game_Time.MASTER_FRAME_NAME])
    end
end

-- Refresh the game time each second
-- @param event on_tick
function Game_Time.on_tick(event)
    local refresh_period = 1 -- (sec)
    if (Time.tick_to_sec(game.tick) % refresh_period == 0) then
        for i, player in pairs(game.connected_players) do
            Game_Time.update_time(player)
        end
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_gui_click, Game_Time.on_gui_click)
Event.register(defines.events.on_player_joined_game, Game_Time.on_player_joined)
Event.register(defines.events.on_player_left_game, Game_Time.on_player_leave)
Event.register(defines.events.on_tick, Game_Time.on_tick)

-- Helper Functions --
-- ======================================================= --

function Game_Time.update_time(player)
    local time_hms = Time.game_time_pased()
    local formatted_time = string.format("%s:%02d:%02d", time_hms.h, time_hms.m, time_hms.s)
    local frame = mod_gui.get_button_flow(player)[Game_Time.MASTER_FRAME_NAME]
    local label = frame["lbl_gametime"]

    label.caption = formatted_time
end

-- Create button for player if doesnt exist already
-- @param player
function Game_Time.draw_gametime_btn(player)
    if mod_gui.get_button_flow(player)[Game_Time.MASTER_BUTTON_NAME] == nil then
        mod_gui.get_button_flow(player).add(
            {
                type = "sprite-button",
                name = Game_Time.MASTER_BUTTON_NAME,
                sprite = "utility/clock",
                tooltip = {"Game_Time.menu_btn_tooltip"}
            }
        )
    end
end

-- Create frame for player if doesnt exist already
-- @param player
function Game_Time.draw_gametime_frame(player)
    if mod_gui.get_button_flow(player)[Game_Time.MASTER_FRAME_NAME] == nil then
        local frame =
            mod_gui.get_button_flow(player).add({type = "frame", name = Game_Time.MASTER_FRAME_NAME, direction = "vertical"})

        local label = frame.add({
            type = "label",
            name = "lbl_gametime",
            tooltip = {"Game_Time.master_frame_caption"},
            caption = "",
        })
        GUI.element_apply_style(frame, Styles.frm_menu)
        GUI.element_apply_style(label, Styles.lbl_menu)
    end

    Game_Time.update_time(player)
end
