-- Game Info Soft Module
-- Displays a game info windo containing rules, etc...
-- Uses locale dddgamer-game-info.cfg
-- @usage require('modules/dddgamer/game-info')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local mod_gui = require("mod-gui") -- From `Factorio\data\core\lualib`
local GUI = require('stdlib/GUI')
local Colors = require('util/Colors')
local Math = require('util/Math')
local Time = require('util/Time')
local Styles = require('util/Styles')

-- Constants --
-- ======================================================= --
GameInfo = {
    MASTER_BUTTON_NAME = 'btn_menu_game_info',
    MASTER_FRAME_NAME = 'frame_game_info',
    SECTION_CONTENT = {
        {
            title = '',
            content = {
                '* Gameplay: Vanilla with QOL Mods',
                -- '* Gameplay: Handcrafting is disabled',
                -- '* Gameplay: Handcrafting and Blueprints have been disabled',
                '* Chat with the [color=orange]`[/color] Key (Under the [color=orange]ESC[/color] Key)',
                '* Join discord for discussion, voice chat and admin support:',
                'https://discord.gg/PkyzXzz',
                '* Check the Factorio Cheat Sheet for help:',
                'https://factoriosheatsheet.com/',
                '* The softmod/scenario code:',
                'https://github.com/deniszholob/factorio-softmod-pack',
                '* Support on kofi:',
                'https://ko-fi.com/deniszholob',
            }
        },
        {
            title = "Train Guidelines",
            content = {
                '* Trains are [color=orange]RHD[/color] (Right Hand Drive)',
                '* Please do not make train roundabouts/loops, junctions/end point stations only',
                '* General Train size is [color=orange]2-4-2[/color]',
                '* Place junctions 2-4-2 width apart',
                '* [color=orange]Color[/color] the trains/stations appropriately',
            }
        },
        {
            title = "Station Naming Guidelines",
            content = {
                '* L = Load, U = Unload, Q = Queue/Stacker (Exclude "[" and "]" for the following examples):',
                '* Resource Trains: [Location/Name]_[L/U]_[Resource-Name]',
                '* Taxi Trains: #PAX_[Location]_[Resource-Name]_[ID]',
                '* Example Ore: "Mine_L_Iron-Ore_1"',
                '* Example PAX: "#PAX_Mine_Copper-Ore_3"',
            }
        },
    }
}

-- Event Functions --
-- ======================================================= --

--- When new player joins add the gameinfo btn to their GUI
--- Redraw the gameinfo frame to update with the new player
--- @param event defines.events.on_player_joined_game
function GameInfo.on_player_joined(event)
    local player = game.players[event.player_index]
    GameInfo.draw_gameinfo_btn(player)

    -- Force a gui refresh in case there where updates
    if player.gui.center[GameInfo.MASTER_FRAME_NAME] ~= nil then
        player.gui.center[GameInfo.MASTER_FRAME_NAME].destroy()
    end

    -- Show readme window (rules) when player (not admin) first joins, but not at later times
    if not player.admin and Time.tick_to_min(player.online_time) < 1 then
        GameInfo.draw_gameinfo_frame(player)
    end
end

--- On Player Leave
--- Clean up the GUI in case this mod gets removed next time
--- Redraw the gameinfo frame to update
--- @param event defines.events.on_player_left_game
function GameInfo.on_player_leave(event)
    local player = game.players[event.player_index]
    if player.gui.center[GameInfo.MASTER_FRAME_NAME] ~= nil then
        player.gui.center[GameInfo.MASTER_FRAME_NAME].destroy()
    end
    if mod_gui.get_button_flow(player)[GameInfo.MASTER_BUTTON_NAME] ~= nil then
        mod_gui.get_button_flow(player)[GameInfo.MASTER_BUTTON_NAME].destroy()
    end
end

--- Toggle gameinfo is called if gui element is gameinfo button
--- @param event defines.events.on_gui_click
function GameInfo.on_gui_click(event)
    local player = game.players[event.player_index]
    local el_name = event.element.name

    if el_name == GameInfo.MASTER_BUTTON_NAME or el_name == 'btn_gameinfo_close' then
        -- Call toggle if frame has been created
        if(player.gui.center[GameInfo.MASTER_FRAME_NAME] ~= nil) then
            GUI.destroy_element(player.gui.center[GameInfo.MASTER_FRAME_NAME])
        else -- Call create if it hasnt
            GameInfo.draw_gameinfo_frame(player)
        end
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_gui_click, GameInfo.on_gui_click)
Event.register(defines.events.on_player_joined_game, GameInfo.on_player_joined)
Event.register(defines.events.on_player_left_game, GameInfo.on_player_leave)

-- Helper Functions --
-- ======================================================= --
--- Create button for player if doesnt exist already
--- @param player LuaPlayer
function GameInfo.draw_gameinfo_btn(player)
    if mod_gui.get_button_flow(player)[GameInfo.MASTER_BUTTON_NAME] == nil then
        local btn = mod_gui.get_button_flow(player).add(
            {
                type = 'sprite-button',
                name = GameInfo.MASTER_BUTTON_NAME,
                -- caption = 'Info',
                sprite = 'utility/favourite_server_icon',
                tooltip = {"Game_Info.menu_btn_tooltip"}
            }
        )
        GUI.element_apply_style(btn, Styles.btn_menu)
    end
end

--- Draws a pane on the left listing all of the players currentely on the server
--- @param player LuaPlayer
function GameInfo.draw_gameinfo_frame(player)
    local master_frame = player.gui.center[GameInfo.MASTER_FRAME_NAME]
    if(master_frame == nil) then
        -- Window frame
        master_frame = player.gui.center.add({
            type = 'frame',
            direction = 'vertical',
            name = GameInfo.MASTER_FRAME_NAME,
            caption = {'Game_Info.master_frame_caption'},
        })
        -- master_frame.style.scaleable = true
        master_frame.style.height = 670
        master_frame.style.width = 650
        -- master_frame.style.left_padding = 10
        -- master_frame.style.right_padding = 10
        -- master_frame.style.top_padding = 10
        -- master_frame.style.bottom_padding = 10

        -- Add scrollable section to content frame
        local scrollable_content_frame =
            master_frame.add(
            {
                type = 'scroll-pane',
                vertical_scroll_policy = 'auto-and-reserve-space',
                horizontal_scroll_policy = 'never',
                style = 'scroll_pane_with_dark_background_under_subheader'
            }
        )
        scrollable_content_frame.style.vertically_stretchable = true
        scrollable_content_frame.style.horizontally_stretchable = true

        -- Content Frame
        -- local content_frame =
        --     scrollable_content_frame.add(
        --     {type = 'frame', direction = 'vertical', name = 'content_frame', style = 'crafting_frame'}
        -- )
        -- content_frame.style.horizontally_stretchable = true
        -- content_frame.style.vertically_stretchable = true

        scrollable_content_frame.style.left_padding = 10
        scrollable_content_frame.style.right_padding = 0
        scrollable_content_frame.style.top_padding = 10
        scrollable_content_frame.style.bottom_padding = 10

        -- Flow
        local mapInfoSection = scrollable_content_frame.add({type = 'flow', direction = 'horizontal'})
        mapInfoSection.style.horizontally_stretchable = true
        mapInfoSection.style.bottom_padding = 15

        local text_box = mapInfoSection.add({
            type = "label",
            caption = "Map Seed"
        })
        local text_box = mapInfoSection.add({
            type = "textfield",
            text = player.surface.map_gen_settings.seed
        })

        -- Insert content
        for i, section in pairs(GameInfo.SECTION_CONTENT) do
            GameInfo.draw_section(scrollable_content_frame, section)
        end

        -- Flow
        local button_flow = master_frame.add({type = 'flow', direction = 'horizontal'})
        button_flow.style.horizontally_stretchable = true -- Needed for align to work
        button_flow.style.horizontal_align = 'left'

        -- Close Button
        local close_button = button_flow.add({
            type = 'button',
            name = 'btn_gameinfo_close',
            caption = {'Game_Info.master_frame_close_btn_caption'},
            tooltip = {'Game_Info.master_frame_close_btn_tooltip'},
            style="red_back_button"
        })
        close_button.style.top_margin = 8
    end
end

--- Draws a list of labels from content passed in
--- @param container table gui element to add to
--- @param content any array list of string to display
function GameInfo.draw_static_content(container, content)
    -- GUI.clear_element(container) -- Clear the current info before adding new
    for i, text in pairs(content) do
        -- Regular text
        if (string.find(text, 'http', 1) == nil) then
            -- Links go into textfields, rest as text
            local txt = container.add({type = 'label', name = i, caption = text})
            if (string.find(text, '===', 1) ~= nil) then
                txt.style.font_color = Colors.orange
                txt.style.font = 'default-bold'
                txt.style.horizontal_align = 'center'
            end
        else
            local txt = container.add({type = 'textfield', name = i, text = text})
            txt.style.horizontally_stretchable = true
            -- txt.read_only = true
            txt.style.width = 500
            -- txt.style.color = Colors.grey
        end
    end
end


---@param container table
---@param section_content_data table
function GameInfo.draw_section(container, section_content_data)
    -- Flow
    local section = container.add({type = 'flow', direction = 'vertical'})
    section.style.horizontally_stretchable = true
    section.style.bottom_padding = 15

    -- Header flow
    local header_flow = section.add({type = 'flow', direction = 'horizontal'})
    header_flow.style.horizontally_stretchable = true -- Needed for align to work
    header_flow.style.horizontal_align = 'center'

    -- Section Header Text
    if(#section_content_data.title > 0) then
        local header = header_flow.add({type = 'label', caption = '=== ' .. section_content_data.title .. ' ==='})
        header.style.font = 'default-bold'
        header.style.font_color = Colors.orange
    end

    -- Section Contents
    GameInfo.draw_static_content(section, section_content_data.content)
end
