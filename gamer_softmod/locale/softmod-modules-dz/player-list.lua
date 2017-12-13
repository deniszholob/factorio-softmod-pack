-- Player List Soft Mod
-- Adds a player list sidebar that displays online players along with their online time.
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Dependencies
require "locale/softmod-modules-util/GUI"
require "locale/softmod-modules-util/Math"
require "locale/softmod-modules-util/Time"
require "locale/softmod-modules-util/Time_Rank"
require "locale/softmod-modules-util/Roles"
require "locale/softmod-modules-util/Colors"

local OWNER = "DDDGamer"

-- Roles
local ROLES = {
  owner =   { tag = "Owner",  color = Colors.red    }, -- server owner
  admin =   { tag = "Admin",  color = Colors.orange }, -- server admin
}


-- When new player joins add the playerlist btn to their GUI
-- Redraw the playerlist frame to update with the new player
-- @param event on_player_joined_game
function on_player_joined(event)
  local player = game.players[event.player_index]
  draw_playerlist_btn(player)
  draw_playerlist_frame()
end


-- On Player Leave
-- Clean up the GUI in case this mod gets removed next time
-- Redraw the playerlist frame to update
-- @param event on_player_left_game
function on_player_leave(event)
  local player = game.players[event.player_index]
  if player.gui.left["frame_playerlist"] ~= nil then
    player.gui.left["frame_playerlist"].destroy()
  end
  if player.gui.top["btn_menu_playerlist"] ~= nil then
    player.gui.top["btn_menu_playerlist"].destroy()
  end
  draw_playerlist_frame()
end


-- Toggle playerlist is called if gui element is playerlist button
-- @param event on_gui_click
local function on_gui_click(event)
  local player = game.players[event.player_index]
  local el_name = event.element.name

  if el_name == "btn_menu_playerlist" then
    GUI.toggle_element(player.gui.left["frame_playerlist"])
  end
end


-- Create button for player if doesnt exist already
-- @param player
function draw_playerlist_btn(player)
  if player.gui.top["btn_menu_playerlist"] == nil then
    player.gui.top.add { type = "button", name = "btn_menu_playerlist", caption = "Online Players", tooltip = "Shows who is on the server" }
  end
end


-- Draws a pane on the left listing all of the players currentely on the server
function draw_playerlist_frame()
  for i, player in pairs(game.players) do
    -- Draw the vertical frame on the left if its not drawn already
    if player.gui.left["frame_playerlist"] == nil then
      player.gui.left.add { type = "frame", name = "frame_playerlist", direction = "vertical" }
    end
    -- Clear and repopulate player list
    GUI.clear_element(player.gui.left["frame_playerlist"])
    for j, p_online in pairs(game.connected_players) do
      local player_rank = Time_Rank.get_rank(p_online)
      local player_role = Roles.get_role(p_online)
      add_player_to_list(player, p_online, player_rank, player_role)
    end
  end
end


-- Add a player to the GUI list
-- @param player
-- @param p_online
-- @param color
-- @param tag
function add_player_to_list(player, p_online, rank, role)
  local played_hrs = Time.tick_to_hour(p_online.online_time)
  played_hrs = tostring(Math.round(played_hrs, 1))
  -- Player list entry
  local caption_str = string.format( "%s hr - %s [%s]", played_hrs, p_online.name, rank.tag)
  local color = rank.color
  --Also set the player tag above their head and on map
  p_online.tag = "[" .. rank.tag .. "]"

  -- If player has a role add it in
  if(role.tag and #role.tag > 0) then 
    caption_str = caption_str .. " <" .. role.tag .. ">"
    p_online.tag = p_online.tag .. " <" .. role.tag .. ">"
    color = role.color
  end

  -- Add in the entry to the player list
  player.gui.left["frame_playerlist"].add {
    type = "label", style = "caption_label_style", name = p_online.name,
    caption = caption_str
  }.style.font_color = color
end


-- Refresh the playerlist after 10 min
-- @param event on_tick
function on_tick(event)
  local refresh_period = 1 --(min)
  if (Time.tick_to_min(game.tick) % refresh_period == 0) then
    draw_playerlist_frame()
  end
end


-- Event Handlers
Event.register(defines.events.on_gui_click, on_gui_click)
Event.register(defines.events.on_player_joined_game, on_player_joined)
Event.register(defines.events.on_player_left_game, on_player_leave)
Event.register(defines.events.on_tick, on_tick)
