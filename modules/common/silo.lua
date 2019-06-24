-- Silo Soft Module
-- Keeps track of rockets launched
-- Uses locale silo.cfg
-- @usage require('modules/common/silo')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local mod_gui = require('mod-gui') -- From `Factorio\data\core\lualib`
local GUI = require('stdlib/GUI')
local Colors = require('util/Colors')
local Styles = require("util/Styles")

-- Constants --
-- ======================================================= --

-- Event Functions --
-- ======================================================= --

-- When new player joins add a silo btn to their GUI that toggles rocket score
-- Redraw the rocket score frame to update with the new player
-- @param event on_player_joined_game
function on_player_joined_game(event)
    local player = game.players[event.player_index]
    draw_rocket_score_btn(player)
    draw_rocket_score_frame(player)
end

-- On Player Leave
-- Clean up the GUI in case this mod gets removed next time
-- Redraw the rocket score frame to update
-- @param event on_player_left_game
function on_player_left_game(event)
    local player = game.players[event.player_index]
    if mod_gui.get_button_flow(player)['btn_menu_score'] ~= nil then
        mod_gui.get_button_flow(player)['btn_menu_score'].destroy()
    end
    if mod_gui.get_button_flow(player)['frame_menu_score'] ~= nil then
        mod_gui.get_button_flow(player)['frame_menu_score'].destroy()
    end
end

-- Toggle rocket score frame is called if gui element is the silo button
-- @param event on_player_joined_game
function on_gui_click(event)
    local player = game.players[event.player_index]
    local el_name = event.element.name

    if el_name == 'btn_menu_score' then
        GUI.toggle_element(mod_gui.get_button_flow(player)['frame_menu_score'])
    end
end

-- Increment rocket score and refresh the UI
-- @param event on_rocket_launched
function on_rocket_launched(event)
    game.print({'silo.rocket_launched'})

    for i, player in pairs(game.connected_players) do
        update_score(player)
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_joined_game, on_player_joined_game)
Event.register(defines.events.on_player_left_game, on_player_left_game)
Event.register(defines.events.on_gui_click, on_gui_click)
Event.register(defines.events.on_rocket_launched, on_rocket_launched)

-- Helper Functions --
-- ======================================================= --

-- Draws a small frame next to rocket button to show rocket count
-- @param player
function draw_rocket_score_btn(player)
    if mod_gui.get_button_flow(player)['btn_menu_score'] == nil then
        mod_gui.get_button_flow(player).add(
            {
                type = 'sprite-button',
                name = 'btn_menu_score',
                sprite = 'item/rocket-silo',
                tooltip = {'silo.btn_tooltip'}
            }
        )
    end
end

-- Draws a small frame next to rocket button to show rocket count
-- @param player
function draw_rocket_score_frame(player)
    local frame = mod_gui.get_button_flow(player)['frame_menu_score']
    if frame == nil then
        frame =
            mod_gui.get_button_flow(player).add({type = 'frame', name = 'frame_menu_score', direction = 'vertical'})

        local label = frame.add({type = 'label', name = 'lbl_rockets_launched', caption = ''})
        GUI.element_apply_style(frame, Styles.frm_menu)
        GUI.element_apply_style(label, Styles.lbl_menu)
        label.style.font_color = Colors.orange
    end

    update_score(player)

    -- Hide if no rockets launched yet
    if (player.force.rockets_launched <= 0) then
        frame.visible = false
    end
end

-- Refreshes the score for the player
-- @param player LuaPlayer
function update_score(player)
    local frame = mod_gui.get_button_flow(player)['frame_menu_score']
    local label = frame['lbl_rockets_launched']
    local rocket_score = tostring(player.force.rockets_launched)

    label.caption = {'silo.rocket_score', rocket_score}

    -- Show the score on first rocket launch
    if(rocket_score == 1) then frame.visible = true end
end
