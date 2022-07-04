-- __MODULE_NAME__ Soft Module
-- __Description__
-- Uses locale __MODULE_NAME__.cfg
-- @usage require('modules/__folder__/__MODULE_NAME__')
-- @usage local ModuleName = require('modules/__folder__/__MODULE_NAME__')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local GUI = require('stdlib/GUI')

-- Constants --
-- ======================================================= --
__MODULE_NAME__ = {
    MENU_BTN_NAME = 'btn_menu___MODULE_NAME__',
    MASTER_FRAME_NAME = 'frame___MODULE_NAME__',
    MASTER_FRAME_LOCATION = GUI.MASTER_FRAME_LOCATIONS.left,
    -- Check Factorio prototype definitions in \Factorio\data\core and \Factorio\data\base
    SPRITE_NAMES = {
        menu = 'utility/questionmark'
    },
    get_menu_button = function(player)
        return GUI.menu_bar_el(player)[__MODULE_NAME__.MENU_BTN_NAME]
    end,
    get_master_frame = function(player)
        return GUI.master_frame_location_el(player, __MODULE_NAME__.MASTER_FRAME_LOCATION)[__MODULE_NAME__.MASTER_FRAME_NAME]
    end
}

-- Event Functions --
-- ======================================================= --
-- When new player joins add a btn to their menu bar
-- Redraw this softmod's master frame (if desired)
-- @param event on_player_joined_game
function __MODULE_NAME__.on_player_joined_game(event)
    local player = game.players[event.player_index]
    __MODULE_NAME__.draw_menu_btn(player)
    -- __MODULE_NAME__.draw_master_frame(player) -- Will appear on load, cooment out to load later on button click
end

-- When a player leaves clean up their GUI in case this mod gets removed or changed next time
-- @param event on_player_left_game
function __MODULE_NAME__.on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(__MODULE_NAME__.get_menu_button(player))
    GUI.destroy_element(__MODULE_NAME__.get_master_frame(player))
end

-- Button Callback (On Click Event)
-- @param event factorio lua event (on_gui_click)
function __MODULE_NAME__.on_gui_click_btn_menu(event)
    local player = game.players[event.player_index]
    local master_frame = __MODULE_NAME__.get_master_frame(player)

    if (master_frame ~= nil) then
        -- Call toggle if frame has been created
        GUI.toggle_element(master_frame)
    else
        -- Call create if it hasnt
        __MODULE_NAME__.draw_master_frame(player)
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_joined_game, __MODULE_NAME__.on_player_joined_game)
Event.register(defines.events.on_player_left_game, __MODULE_NAME__.on_player_left_game)

-- GUI Functions --
-- ======================================================= --

-- GUI Function
-- Draws a button in the menubar to toggle the GUI frame on and off
-- @tparam LuaPlayer player current player calling the function
function __MODULE_NAME__.draw_menu_btn(player)
    local menubar_button = __MODULE_NAME__.get_menu_button(player)
    if menubar_button == nil then
        GUI.add_sprite_button(
            GUI.menu_bar_el(player),
            {
                type = 'sprite-button',
                name = __MODULE_NAME__.MENU_BTN_NAME,
                sprite = GUI.get_safe_sprite_name(player, __MODULE_NAME__.SPRITE_NAMES.menu),
                -- caption = '__MODULE_NAME__.menu_btn_caption',
                tooltip = {'__MODULE_NAME__.menu_btn_tooltip'}
            },
            -- On Click callback function
            __MODULE_NAME__.on_gui_click_btn_menu
        )
    end
end

-- GUI Function
-- Creates the main/master frame where all the GUI content will go in
-- @tparam LuaPlayer player current player calling the function
function __MODULE_NAME__.draw_master_frame(player)
    local master_frame = __MODULE_NAME__.get_master_frame(player)

    if (master_frame == nil) then
        master_frame =
            GUI.master_frame_location_el(player, __MODULE_NAME__.MASTER_FRAME_LOCATION).add(
            {
                type = 'frame',
                name = __MODULE_NAME__.MASTER_FRAME_NAME,
                direction = 'vertical',
                caption = {'__MODULE_NAME__.master_frame_caption'}
            }
        )

        __MODULE_NAME__.fill_master_frame(master_frame, player)
    end
end

-- GUI Function
-- @tparam LuaGuiElement container parent container to add GUI elements to
-- @tparam LuaPlayer player current player calling the function
function __MODULE_NAME__.fill_master_frame(container, player)
    -- Your code here...
    local lbl_test =
        container.add(
        {
            type = 'label',
            caption = {'__MODULE_NAME__.lbl_test'}
        }
    )
end

-- Logic Functions --
-- ======================================================= --
