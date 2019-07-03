-- Game Time Soft Module
-- Shows the game time at the top
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

-- Event Functions --
-- ======================================================= --

-- When new player joins add the game time btn to their GUI
-- @param event on_player_joined_game
function on_player_joined(event)
    local player = game.players[event.player_index]
    draw_gametime_btn(player)
    draw_gametime_frame(player)
end

-- On Player Leave
-- Clean up the GUI in case this mod gets removed next time
-- @param event on_player_left_game
function on_player_leave(event)
    local player = game.players[event.player_index]
    if mod_gui.get_button_flow(player)["btn_menu_gametime"] ~= nil then
        mod_gui.get_button_flow(player)["btn_menu_gametime"].destroy()
    end
    if mod_gui.get_button_flow(player)["frame_menu_gametime"] ~= nil then
        mod_gui.get_button_flow(player)["frame_menu_gametime"].destroy()
    end
end

-- Toggle playerlist is called if gui element is playerlist button
-- @param event on_gui_click
local function on_gui_click(event)
    local player = game.players[event.player_index]
    local el_name = event.element.name

    if el_name == "btn_menu_gametime" then
        GUI.toggle_element(mod_gui.get_button_flow(player)["frame_menu_gametime"])
    end
end

-- Refresh the game time each second
-- @param event on_tick
function on_tick(event)
    local refresh_period = 1 -- (sec)
    if (Time.tick_to_sec(game.tick) % refresh_period == 0) then
        for i, player in pairs(game.connected_players) do
            update_time(player)
        end
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_gui_click, on_gui_click)
Event.register(defines.events.on_player_joined_game, on_player_joined)
Event.register(defines.events.on_player_left_game, on_player_leave)
Event.register(defines.events.on_tick, on_tick)

-- Helper Functions --
-- ======================================================= --

function update_time(player)
    local time_hms = Time.game_time_pased()
    local formatted_time = string.format("%s:%s:%s", time_hms.h, time_hms.m, time_hms.s)
    local frame = mod_gui.get_button_flow(player)["frame_menu_gametime"]
    local label = frame["lbl_gametime"]

    label.caption = formatted_time
end

-- Create button for player if doesnt exist already
-- @param player
function draw_gametime_btn(player)
    if mod_gui.get_button_flow(player)["btn_menu_gametime"] == nil then
        mod_gui.get_button_flow(player).add(
            {
                type = "sprite-button",
                name = "btn_menu_gametime",
                sprite = "utility/clock",
                tooltip = "Show game time"
            }
        )
    end
end

-- Create frame for player if doesnt exist already
-- @param player
function draw_gametime_frame(player)
    if mod_gui.get_button_flow(player)["frame_menu_gametime"] == nil then
        local frame =
            mod_gui.get_button_flow(player).add({type = "frame", name = "frame_menu_gametime", direction = "vertical"})

        local label = frame.add({type = "label", name = "lbl_gametime", caption = ""})
        GUI.element_apply_style(frame, Styles.frm_menu)
        GUI.element_apply_style(label, Styles.lbl_menu)
    end

    update_time(player)
end
