-- Online Player List Soft Module
-- Displays a list of current players
-- Uses locale player-list.cfg
-- @usage require('modules/common/online-player-list')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local mod_gui = require('mod-gui') -- From `Factorio\data\core\lualib`
local GUI = require('stdlib/GUI')
local Sprites = require('util/Sprites')
local Math = require('util/Math')
local Time = require('util/Time')

-- Constants --
-- ======================================================= --
PlayerList = {
    MENU_BTN_NAME = 'btn_menu_playerlist',
    MASTER_FRAME_NAME = 'frame_playerlist',
    CHECKBOX_OFFLINE_PLAYERS = 'chbx_playerlist_players',
    SPRITE_NAMES = {
        menu = Sprites.character,
        inventory = Sprites.item_editor_icon,
        inventory_empty = Sprites.slot_icon_armor
        -- inventory_alt = Sprites.grey_rail_signal_placement_indicator,
    },
    -- Utf shapes https://www.w3schools.com/charsets/ref_utf_geometric.asp
    -- Utf symbols https://www.w3schools.com/charsets/ref_utf_symbols.asp
    ONLINE_SYMBOL = '●',
    OFFLINE_SYMBOL = '○',
    ADMIN_SYMBOL = '★',
    OWNER = 'DDDGamer',
    BTN_INVENTORY_OWNER_ONLY = true, -- Only owner can open inventory or all admins
    BTN_INVENTORY_TAGET_ADMINS = true, -- Can only open reg players or target admins too
    PROGRESS_BAR_HEIGHT = 4,
}

-- Event Functions --
-- ======================================================= --

--- When new player joins add the playerlist btn to their GUI
--- Redraw the playerlist frame to update with the new player
--- @param event defines.events.on_player_joined_game
function PlayerList.on_player_joined_game(event)
    local player = game.players[event.player_index]
    PlayerList.draw_playerlist_btn(player)
    PlayerList.draw_playerlist_frame()
end

--- On Player Leave
--- Clean up the GUI in case this mod gets removed next time
--- Redraw the playerlist frame to update
--- @param event defines.events.on_player_left_game
function PlayerList.on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(mod_gui.get_button_flow(player)[PlayerList.MENU_BTN_NAME])
    GUI.destroy_element(mod_gui.get_frame_flow(player)[PlayerList.MASTER_FRAME_NAME])
    PlayerList.draw_playerlist_frame()
end

--- Toggle playerlist is called if gui element is playerlist button
--- @param event defines.events.on_gui_click
function PlayerList.on_gui_click(event)
    local player = game.players[event.player_index]
    local el_name = event.element.name

    -- Window toggle
    if el_name == PlayerList.MENU_BTN_NAME then
        GUI.toggle_element(mod_gui.get_frame_flow(player)[PlayerList.MASTER_FRAME_NAME])
    end
    -- Checkbox toggle to display only online players or not
    if (el_name == PlayerList.CHECKBOX_OFFLINE_PLAYERS) then
        local player_config = PlayerList.getConfig(player)
        player_config.show_offline_players = not player_config.show_offline_players
        PlayerList.draw_playerlist_frame()
    end
    -- LMB will open the map view to the clicked player
    if (string.find(el_name, "lbl_player_") and
        event.button == defines.mouse_button_type.left) then
        local target_player = game.players[string.sub(el_name, 12)]
        player.zoom_to_world(target_player.position, 2)
    end
end

--- Refresh the playerlist after 10 min
--- @param event defines.events.on_tick
function PlayerList.on_tick(event)
    local refresh_period = 1 --(min)
    if (Time.tick_to_min(game.tick) % refresh_period == 0) then
        PlayerList.draw_playerlist_frame()
    end
end

--- When new player uses decon planner
--- @param event defines.events.on_player_deconstructed_area
function PlayerList.on_player_deconstructed_area(event)
    local player = game.players[event.player_index]
    PlayerList.getConfig(player).decon = true
end

--- When new player mines something
--- @param event defines.events.on_player_mined_item
function PlayerList.on_player_mined_item(event)
    local player = game.players[event.player_index]
    PlayerList.getConfig(player).mine = true
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_gui_checked_state_changed, PlayerList.on_gui_click)
Event.register(defines.events.on_gui_click, PlayerList.on_gui_click)
Event.register(defines.events.on_player_joined_game, PlayerList.on_player_joined_game)
Event.register(defines.events.on_player_left_game, PlayerList.on_player_left_game)
Event.register(defines.events.on_tick, PlayerList.on_tick)
Event.register(defines.events.on_player_deconstructed_area, PlayerList.on_player_deconstructed_area)
Event.register(defines.events.on_player_mined_item, PlayerList.on_player_mined_item)

-- Helper Functions --
-- ======================================================= --

--- @param player LuaPlayer
function PlayerList.getLblPlayerName(player)
    return 'lbl_player_' .. player.name
end

--- Create button for player if doesnt exist already
--- @param player LuaPlayer
function PlayerList.draw_playerlist_btn(player)
    if mod_gui.get_button_flow(player)[PlayerList.MENU_BTN_NAME] == nil then
        mod_gui.get_button_flow(player).add(
            {
                type = 'sprite-button',
                name = PlayerList.MENU_BTN_NAME,
                sprite = PlayerList.SPRITE_NAMES.menu,
                -- caption = 'Online Players',
                tooltip = {'player_list.btn_tooltip'}
            }
        )
    end
end

--- Draws a pane on the left listing all of the players currentely on the server
function PlayerList.draw_playerlist_frame()
    local player_list = {}
    -- Copy player list into local list
    for i, player in pairs(game.players) do
        table.insert(player_list, player)
    end

    -- Sort players based on admin role, and time played
    -- Admins first, highest playtime first
    table.sort(player_list, PlayerList.sort_players)

    for i, player in pairs(game.players) do
        local master_frame = mod_gui.get_frame_flow(player)[PlayerList.MASTER_FRAME_NAME]
        -- Draw the vertical frame on the left if its not drawn already
        if master_frame == nil then
            master_frame =
                mod_gui.get_frame_flow(player).add(
                {type = 'frame', name = PlayerList.MASTER_FRAME_NAME, direction = 'vertical'}
            )
        end
        -- Clear and repopulate player list
        GUI.clear_element(master_frame)

        -- Flow
        local flow_header = master_frame.add({type = 'flow', direction = 'horizontal'})
        flow_header.style.horizontal_spacing = 20

        -- Draw checkbox
        flow_header.add(
            {
                type = 'checkbox',
                name = PlayerList.CHECKBOX_OFFLINE_PLAYERS,
                caption = {'player_list.checkbox_caption'},
                tooltip = {'player_list.checkbox_tooltip'},
                state = PlayerList.getConfig(player).show_offline_players or false
            }
        )

        -- Draw total number
        flow_header.add(
            {
                type = 'label',
                caption = {'player_list.total_players', #game.players, #game.connected_players}
            }
        )

        -- Add scrollable section to content frame
        local scrollable_content_frame =
            master_frame.add(
            {
                type = 'scroll-pane',
                vertical_scroll_policy = 'auto-and-reserve-space',
                horizontal_scroll_policy = 'never'
            }
        )
        scrollable_content_frame.style.maximal_height = 600

        -- List all players
        for j, list_player in pairs(player_list) do
            if (list_player.connected or PlayerList.getConfig(player).show_offline_players) then
                PlayerList.add_player_to_list(scrollable_content_frame, player, list_player)
            end
        end
    end
end

--- @param player LuaPlayer the one who is doing the opening (display the other player inventory for this player)
--- @param target_player LuaPlayer who's inventory to open
function PlayerList.open_player_inventory(player, target_player)
    player.opened = target_player
    -- Tried to do a toggle, but cant close; for some reason opened is always nil even after setting
    -- if(player.opened == game.players[target_player.name]) then
    --     player.opened = nil
    -- elseif(not player.opened) then
    --     player.opened = game.players[target_player.name]
    -- end
end

function PlayerList.canDisplay(player, target_player)
    if (
        -- Only for owners
        ((PlayerList.BTN_INVENTORY_OWNER_ONLY and player.name == PlayerList.OWNER) and
         -- Reg players or both reg players and admins
         (PlayerList.BTN_INVENTORY_TAGET_ADMINS or not target_player.admin)) or
        -- For all admins
        ((not PlayerList.BTN_INVENTORY_OWNER_ONLY and player.admin == true) and
         -- Reg players or both reg players and admins
         (PlayerList.BTN_INVENTORY_TAGET_ADMINS or not target_player.admin))
    ) then
        return true
    end
    return false
end


-- Add a player to the GUI list
---@param container LuaGuiElement
---@param player LuaPlayer
---@param target_player LuaPlayer
function PlayerList.add_player_to_list(container, player, target_player)
    local played_hrs = Time.tick_to_hour(target_player.online_time)
    played_hrs = tostring(Math.round(played_hrs, 1))
    local played_percentage = 1
    if (game.tick > 0) then
        played_percentage = target_player.online_time / game.tick
    end
    local color = {
        r = target_player.color.r,
        g = target_player.color.g,
        b = target_player.color.b,
        a = 1
    }

    -- Player list entry
    local player_online_status = ''
    local player_admin_status = ''
    if (target_player.admin) then
        player_admin_status = ' ' .. PlayerList.ADMIN_SYMBOL
    end
    if (PlayerList.getConfig(player).show_offline_players) then
        player_online_status = PlayerList.OFFLINE_SYMBOL
        if (target_player.connected) then
            player_online_status = PlayerList.ONLINE_SYMBOL
        end
        player_online_status = player_online_status .. ' '
    end
    local caption_str =
        string.format('%s%s hr - %s%s', player_online_status, played_hrs, target_player.name, player_admin_status)

    local flow = container.add({type = 'flow', direction = 'horizontal'})

    -- Add an inventory open button for those with privilages
    if (PlayerList.canDisplay(player, target_player)) then
        local inventoryIconName = PlayerList.SPRITE_NAMES.inventory
        if(target_player and
           target_player.get_main_inventory() and -- So this one is nil sometimes
           target_player.get_main_inventory().is_empty()) then
            inventoryIconName = PlayerList.SPRITE_NAMES.inventory_empty
        end
        local btn_sprite = GUI.add_sprite_button(
            flow,
            {
                type = 'sprite-button',
                name = 'btn_open_inventory_'..target_player.name,
                sprite = GUI.get_safe_sprite_name(player, inventoryIconName),
                tooltip = {'player_list.player_tooltip_inventory', target_player.name}
            },
            -- On Click callback function
            function(event)
                PlayerList.open_player_inventory(player, target_player)
            end
        )
        GUI.element_apply_style(btn_sprite, Styles.small_button)
    end

    -- Add in the entry to the player list
    local entry = flow.add(
        {
            type = 'label',
            name = PlayerList.getLblPlayerName(target_player),
            caption = caption_str,
            tooltip= {'player_list.player_tooltip'}
        }
    )
    entry.style.font_color = color
    entry.style.font = 'default-bold'

    -- Griefer icons: mined/deconed flags
    if (PlayerList.canDisplay(player, target_player)) then
        -- Add decon planner icon if player deconed something
        if(PlayerList.getConfig(target_player).decon) then
            local sprite = flow.add({
                type = 'sprite-button',
                tooltip = {'player_list.player_tooltip_decon'},
                sprite = GUI.get_safe_sprite_name(player, Sprites.deconstruction_planner)
            })
            GUI.element_apply_style(sprite, Styles.small_button)
        end

        -- Add axe icon if player mined something
        if(PlayerList.getConfig(target_player).mine) then
            local sprite = flow.add({
                type = 'sprite-button',
                tooltip = {'player_list.player_tooltip_mine'},
                sprite = GUI.get_safe_sprite_name(player, Sprites.steel_axe)
            })
            GUI.element_apply_style(sprite, Styles.small_button)
        end
    end

    local entry_bar =
        container.add(
        {
            type = 'progressbar',
            name = 'bar_' .. target_player.name,
            -- style = 'achievement_progressbar',
            value = played_percentage,
            tooltip = {'player_list.player_tooltip_playtime', Math.round(played_percentage * 100, 2)}
        }
    )
    entry_bar.style.color = color
    entry_bar.style.height = PlayerList.PROGRESS_BAR_HEIGHT
end

--- Returns the playerlist config for specified player, creates default config if none exist
--- @param player LuaPlayer
function PlayerList.getConfig(player)
    if (not global.playerlist_config) then
        global.playerlist_config = {}
    end

    if (not global.playerlist_config[player.name]) then
        global.playerlist_config[player.name] = {
            show_offline_players = false,
            mine = false,
            decon = false
        }
    end

    return global.playerlist_config[player.name]
end

--- Sort players based on connection, admin role, and time played
--- Connected first, Admins first, highest playtime first
--- @param a LuaPlayer
--- @param b LuaPlayer
function PlayerList.sort_players(a, b)
    if ((a.connected and b.connected) or (not a.connected and not b.connected)) then
        if ((a.admin and b.admin) or (not a.admin and not b.admin)) then
            return a.online_time > b.online_time
        else
            return a.admin
        end
    else
        return a.connected
    end
end
