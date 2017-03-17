-- Player List Soft Mod
-- Adds a player list sidebar that displays online players along with their online time.
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Dependencies
require "locale/softmod-modules-util/GUI"
require "locale/softmod-modules-util/Time"

local OWNER = "DDDGamer"

-- Colors
local COLORS = {
  red =    { r=242, g=13,  b=13  },
  orange = { r=242, g=70,  b=13  },
  purple = { r=90,  g=32,  b=233 },
  cyan =   { r=19,  g=182, b=236 },
  blue =   { r=0,   g=100, b=200 },
  green =  { r=80,  g=210, b=80  },
  white =  { r=255, g=255, b=255 },
}

-- Roles
local ROLES = {
  owner =   { tag = "Owner",  color = COLORS.red    }, -- server owner
  admin =   { tag = "Admin",  color = COLORS.orange }, -- server admin
}

-- Regurlar player ranks (time in hrs)
local RANKS = {
  lvl1 = { time = 0,  color = COLORS.green,  tag = "Commoner" },
  lvl2 = { time = 1,  color = COLORS.cyan,   tag = "Minion",  },
  lvl3 = { time = 5,  color = COLORS.blue,   tag = "Hero",    },
  lvl4 = { time = 20, color = COLORS.purple, tag = "Elite",   },
}


-- When new player joins add the playerlist btn to their GUI
-- Redraw the playerlist frame to update with the new player
-- @param event on_player_joined_game
function on_player_join(event)
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
      -- Admins
      if p_online.admin == true then
        if p_online.name == OWNER then
          add_player_to_list(player, p_online, ROLES.owner.color, ROLES.owner.tag)
        else
          add_player_to_list(player, p_online, ROLES.admin.color, ROLES.admin.tag)
        end
      -- Players
      elseif Time.tick_to_hour(p_online.online_time) < RANKS.lvl2 then
          add_player_to_list(player, p_online, RANKS.lvl1.color, RANKS.lvl1.tag)
      elseif Time.tick_to_hour(p_online.online_time) >= RANKS.lvl2 then
          add_player_to_list(player, p_online, RANKS.lvl2.color, RANKS.lvl2.tag)
      elseif Time.tick_to_hour(p_online.online_time) >= RANKS.lvl3 then
          add_player_to_list(player, p_online, RANKS.lvl3.color, RANKS.lvl3.tag)
      elseif Time.tick_to_hour(p_online.online_time) >= RANKS.lvl4 then
          add_player_to_list(player, p_online, RANKS.lvl4.color, RANKS.lvl4.tag)
      else
          add_player_to_list(player, p_online, COLORS.white, "")
      end
    end
  end
end


-- Add a player to the GUI list
-- @param player
-- @param p_online
-- @param color
-- @param tag
function add_player_to_list(player, p_online, color, tag)
  local played_hrs = tostring(Time.tick_to_hour(p_online.online_time))
  player.gui.left["frame_playerlist"].add {
    type = "label", style = "caption_label_style", name = p_online.name,
    caption = { "", played_hrs, " hr - ", p_online.name, " ", "[" .. tag .. "]" }
  }
  player.gui.left["frame_playerlist"][p_online.name].style.font_color = color
  p_online.tag = "[" .. tag .. "]"
end


-- Refresh the playerlist after 10 min
-- @param event on_tick
function on_tick(event)
  global.last_refresh = global.last_refresh or 0
  local cur_time = game.tick / 60
  local refresh_period = 10 -- 600 seconds (10 min)
  local refresh_time_passed = cur_time - global.last_refresh
  if refresh_time_passed > refresh_period then
    draw_playerlist_frame()
    global.last_refresh = cur_time
  end
end


-- Event Handlers
Event.register(defines.events.on_gui_click, on_gui_click)
Event.register(defines.events.on_player_joined_game, on_player_join)
Event.register(defines.events.on_player_left_game, on_player_leave)
Event.register(defines.events.on_tick, on_tick)
