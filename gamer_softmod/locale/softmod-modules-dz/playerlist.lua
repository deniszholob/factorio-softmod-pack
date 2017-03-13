-- Player List Soft Mod
-- Adds a player list sidebar that displays online players along with their online time.
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Dependencies
require "locale/softmod-modules-util/GUI"
require "locale/softmod-modules-util/Time"
require "config"

-- Colors
local colors = {
  red =    { r=210, g=40,  b=0   },
  orange = { r=230, g=140, b=0   },
  blue =   { r=0  , g=100, b=200 },
  green =  { r=80,  g=210, b=80  }
}

-- Roles
local roles = {
  owner =   { tag = "Owner",  color = colors.red    }, -- server owner
  admin =   { tag = "Admin",  color = colors.orange }, -- server admin
  regular = { tag = "Hero",   color = colors.purple }, -- player played more than REGULAR_TIME
  new =     { tag = "Minion", color = colors.green  }, -- player hasnt reached REGURLAR_TIME
}


-- When new player joins add the playerlist btn to their GUI
-- Redraw the playerlist frame to update with the new player
-- @param event on_player_joined_game
function on_player_join(event)
  local player = game.players[event.player_index]
  draw_playerlist_btn(player)
  draw_playerlist_frame()
end


-- When a player list, redraw the playerlist fram to update
-- @param event on_player_left_game
function on_player_leave(event)
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
          add_player_to_list(player, p_online, roles.owner.color, roles.owner.tag)
        else
          add_player_to_list(player, p_online, roles.admin.color, roles.admin.tag)
        end
      -- Players
      elseif Time.tick_to_min(p_online.online_time) >= REGULAR_TIME then
          add_player_to_list(player, p_online, roles.regular.color, roles.regular.tag)
      else
          add_player_to_list(player, p_online, roles.new.color, roles.new.tag)
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
