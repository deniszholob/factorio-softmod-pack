-- Sprite_List Soft Module
-- __Description__
-- Uses locale Sprite_List.cfg
-- @usage require('modules/__folder__/Sprite_List')
-- @usage local ModuleName = require('modules/__folder__/Sprite_List')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local GUI = require('stdlib/GUI')
local Styles = require('util/Styles')
local Sprites = require('util/Sprites')

-- Constants --
-- ======================================================= --
SpriteList = {
    MENU_BTN_NAME = 'btn_menu_Sprite_List',
    MASTER_FRAME_NAME = 'frame_Sprite_List',
    MASTER_FRAME_LOCATION = GUI.MASTER_FRAME_LOCATIONS.left,
    -- Check Factorio prototype definitions in \Factorio\data\core and \Factorio\data\base
    SPRITE_NAMES = {
        menu = 'utility/train_stop_placement_indicator'
    },
    get_menu_button = function(player)
        return GUI.menu_bar_el(player)[SpriteList.MENU_BTN_NAME]
    end,
    get_master_frame = function(player)
        return GUI.master_frame_location_el(player, SpriteList.MASTER_FRAME_LOCATION)[SpriteList.MASTER_FRAME_NAME]
    end
}

-- Event Functions --
-- ======================================================= --
--- When new player joins add a btn to their menu bar
--- Redraw this softmod's master frame (if desired)
--- @param event defines.events.on_player_joined_game
function SpriteList.on_player_joined_game(event)
    local player = game.players[event.player_index]
    SpriteList.draw_menu_btn(player)
    -- Sprite_List.draw_master_frame(player) -- Will appear on load, cooment out to load later on button click
end

--- When a player leaves clean up their GUI in case this mod gets removed or changed next time
--- @param event defines.events.on_player_left_game
function SpriteList.on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(SpriteList.get_menu_button(player))
    GUI.destroy_element(SpriteList.get_master_frame(player))
end

--- Button Callback (On Click Event)
--- @param event event factorio lua event (on_gui_click)
function SpriteList.on_gui_click_btn_menu(event)
    local player = game.players[event.player_index]
    local master_frame = SpriteList.get_master_frame(player)

    if (master_frame ~= nil) then
        -- Call toggle if frame has been created
        GUI.toggle_element(master_frame)
    else
        -- Call create if it hasnt
        SpriteList.draw_master_frame(player)
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_joined_game, SpriteList.on_player_joined_game)
Event.register(defines.events.on_player_left_game, SpriteList.on_player_left_game)

-- GUI Functions --
-- ======================================================= --

-- GUI Function
--- Draws a button in the menubar to toggle the GUI frame on and off
--- @param player LuaPlayer current player calling the function
function SpriteList.draw_menu_btn(player)
    local menubar_button = SpriteList.get_menu_button(player)
    if menubar_button == nil then
        GUI.add_sprite_button(
            GUI.menu_bar_el(player),
            {
                type = 'sprite-button',
                name = SpriteList.MENU_BTN_NAME,
                sprite = GUI.get_safe_sprite_name(player, SpriteList.SPRITE_NAMES.menu),
                -- caption = 'Sprite_List.menu_btn_caption',
                tooltip = 'List Of Sprites'
            },
            -- On Click callback function
            SpriteList.on_gui_click_btn_menu
        )
    end
end

--- GUI Function
--- Creates the main/master frame where all the GUI content will go in
--- @param player LuaPlayer current player calling the function
function SpriteList.draw_master_frame(player)
    local master_frame = SpriteList.get_master_frame(player)

    if (master_frame == nil) then
        master_frame =
            GUI.master_frame_location_el(player, SpriteList.MASTER_FRAME_LOCATION).add(
            {
                type = 'frame',
                name = SpriteList.MASTER_FRAME_NAME,
                direction = 'vertical',
                caption = 'Sprite List'
            }
        )
        GUI.element_apply_style(master_frame, Styles.frm_window)

        SpriteList.fill_master_frame(master_frame, player)
    end
end

--- GUI Function
--- @param container LuaGuiElement parent container to add GUI elements to
--- @param player LuaPlayer current player calling the function
function SpriteList.fill_master_frame(container, player)
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

    -- Selected icons i want to view at top
    local icons_to_test = {
        Sprites.game_stopped_visualization,
        Sprites.crafting_machine_recipe_not_unlocked,
        Sprites.clear,
        Sprites.rail_path_not_possible,
        Sprites.set_bar_slot,
        Sprites.remove,
        Sprites.trash_bin,
        Sprites.too_far,
        Sprites.destroyed_icon,
        Sprites.color_effect,
        Sprites.indication_arrow,
        Sprites.hint_arrow_up,
        Sprites.hint_arrow_down,
        Sprites.speed_up,
        Sprites.speed_down,
        Sprites.reset,
    }

    local counter = 1
    while scroll_pane['flow' .. counter] do
        scroll_pane['flow' .. counter].destroy()
        counter = counter + 1
    end
    counter = 1
    for i, spriteStr in pairs(icons_to_test) do
        local flow_name = 'flow' .. math.floor(counter / 10) + 1 -- x entries per "row"
        local sprite_flow = scroll_pane[flow_name]
        if not sprite_flow then
            sprite_flow = scroll_pane.add({type = 'flow', name = flow_name, direction = 'horizontal'})
        end
        local btn_sprite = sprite_flow.add({type = 'sprite-button', sprite = GUI.get_safe_sprite_name(player, spriteStr), tooltip = spriteStr})
        GUI.element_apply_style(btn_sprite, Styles.small_button)
        counter = counter + 1
    end

    -- List all icons
    for i, spriteStr in pairs(Sprites) do
        local sprite_h_flow = scroll_pane.add({type = 'flow', direction = 'horizontal'})
        sprite_h_flow.add({type = 'sprite-button', sprite = GUI.get_safe_sprite_name(player, spriteStr)})
        -- sprite_h_flow.add({type = 'textfield', text = spriteStr}) -- Sprite name
        sprite_h_flow.add({type = 'textfield', text = i}) -- Variable name
        sprite_h_flow.add({type = 'sprite', sprite = GUI.get_safe_sprite_name(player, spriteStr)})
    end
end

-- Logic Functions --
-- ======================================================= --
