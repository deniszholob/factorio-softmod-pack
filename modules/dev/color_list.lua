-- Color_List Soft Module
-- Shows a list of all the colors in the Colors.lua file
-- @usage require('modules/dev/color_list')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local GUI = require('stdlib/GUI')
local Styles = require('util/Styles')
local Colors = require('util/Colors')

-- Constants --
-- ======================================================= --
Color_List = {
    MENU_BTN_NAME = 'btn_menu_Color_List',
    MASTER_FRAME_NAME = 'frame_Color_List',
    MASTER_FRAME_LOCATION = GUI.MASTER_FRAME_LOCATIONS.left,
    -- Check Factorio prototype definitions in \Factorio\data\core and \Factorio\data\base
    SPRITE_NAMES = {
        menu = 'utility/color_effect'
    },
    get_menu_button = function(player)
        return GUI.menu_bar_el(player)[Color_List.MENU_BTN_NAME]
    end,
    get_master_frame = function(player)
        return GUI.master_frame_location_el(player, Color_List.MASTER_FRAME_LOCATION)[Color_List.MASTER_FRAME_NAME]
    end
}

-- Event Functions --
-- ======================================================= --
-- When new player joins add a btn to their menu bar
-- Redraw this softmod's master frame (if desired)
-- @param event on_player_joined_game
function Color_List.on_player_joined_game(event)
    local player = game.players[event.player_index]
    Color_List.draw_menu_btn(player)
    Color_List.draw_master_frame(player) -- Will appear on load, cooment out to load later on button click
end

-- When a player leaves clean up their GUI in case this mod gets removed or changed next time
-- @param event on_player_left_game
function Color_List.on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(Color_List.get_menu_button(player))
    GUI.destroy_element(Color_List.get_master_frame(player))
end

-- Button Callback (On Click Event)
-- @param event factorio lua event (on_gui_click)
function Color_List.on_gui_click_btn_menu(event)
    local player = game.players[event.player_index]
    local master_frame = Color_List.get_master_frame(player)

    if (master_frame ~= nil) then
        -- Call toggle if frame has been created
        GUI.toggle_element(master_frame)
    else
        -- Call create if it hasnt
        Color_List.draw_master_frame(player)
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_joined_game, Color_List.on_player_joined_game)
Event.register(defines.events.on_player_left_game, Color_List.on_player_left_game)

-- GUI Functions --
-- ======================================================= --

-- GUI Function
-- Draws a button in the menubar to toggle the GUI frame on and off
-- @tparam LuaPlayer player current player calling the function
function Color_List.draw_menu_btn(player)
    local menubar_button = Color_List.get_menu_button(player)
    if menubar_button == nil then
        GUI.add_sprite_button(
            GUI.menu_bar_el(player),
            {
                type = 'sprite-button',
                name = Color_List.MENU_BTN_NAME,
                sprite = GUI.get_safe_sprite_name(player, Color_List.SPRITE_NAMES.menu),
                tooltip = 'Show Colors'
            },
            -- On Click callback function
            Color_List.on_gui_click_btn_menu
        )
    end
end

-- GUI Function
-- Creates the main/master frame where all the GUI content will go in
-- @tparam LuaPlayer player current player calling the function
function Color_List.draw_master_frame(player)
    local master_frame = Color_List.get_master_frame(player)

    if (master_frame == nil) then
        master_frame =
            GUI.master_frame_location_el(player, Color_List.MASTER_FRAME_LOCATION).add(
            {
                type = 'frame',
                name = Color_List.MASTER_FRAME_NAME,
                direction = 'vertical',
                caption = 'Colors'
            }
        )
        GUI.element_apply_style(master_frame, Styles.frm_window)

        Color_List.fill_master_frame(master_frame, player)
    end
end

-- GUI Function
-- @tparam LuaGuiElement container parent container to add GUI elements to
-- @tparam LuaPlayer player current player calling the function
function Color_List.fill_master_frame(container, player)
    local scroll_pane =
        container.add(
        {
            type = 'scroll-pane',
            name = 'scroll_content',
            direction = 'vertical',
            vertical_scroll_policy = 'auto',
            horizontal_scroll_policy = 'never'
        }
    )
    for i, color in pairs(Colors) do
        scroll_pane.add({type = 'label', caption = i}).style.font_color = color
    end
end

-- Logic Functions --
-- ======================================================= --
