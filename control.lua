-- Constants --
OWNER = "DDDGamer"
HERO_TIME = 150
COLOR_OVERLORD = {r=210, g=0,   b=0  }
COLOR_GUARDIAN = {r=255, g=128, b=200}
COLOR_HERO     = {r=100, g=0,   b=200}
COLOR_MINION   = {r=50,  g=255, b=50 }


-- ================ Original Functions =================== --

-- [[
-- On new player creation
-- Spawn some items to player and show scenario intro rules
-- ]]
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  player.insert{name="iron-plate", count=10}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
  player.insert{name="burner-mining-drill", count = 3}
  player.insert{name="stone-furnace", count = 1}
  player.insert{name="wooden-chest", count = 2}
  player.insert{name="iron-axe", count = 1}
  player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
  if (#game.players <= 1) then
    game.show_message_dialog{text = {"msg-intro"}}
  else
    player.print({"msg-intro"})
  end
end)

-- After death respawn player with pistol and ammo
script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
end)

-- Rocket launch messages
script.on_event(defines.events.on_rocket_launched, function(event)
  local force = event.rocket.force
  if event.rocket.get_item_count("satellite") == 0 then
    if (#game.players <= 1) then
      game.show_message_dialog{text = {"gui-rocket-silo.rocket-launched-without-satellite"}}
    else
      for index, player in pairs(force.players) do
        player.print({"gui-rocket-silo.rocket-launched-without-satellite"})
      end
    end
    return
  end
  if not global.satellite_sent then
    global.satellite_sent = {}
  end
  if global.satellite_sent[force.name] then
    global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1
  else
    game.set_game_state{game_finished=true, player_won=true, can_continue=true}
    global.satellite_sent[force.name] = 1
  end
  for index, player in pairs(force.players) do
    if player.gui.left.rocket_score then
      player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
    else
      local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption={"score"}}
      frame.add{name="rocket_count_label", type = "label", caption={"", {"rockets-sent"}, ":"}}
      frame.add{name="rocket_count", type = "label", caption=tostring(global.satellite_sent[force.name])}
    end
  end
end)


-- ================ Custom Event Functions =================== --

-- When player joins the game, show greeting
script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  player.print("Welcome to Factorio freeplay")
  clearPlayerGUI(player)
  drawMenuButtons()
  drawPlayerList()
end)

-- Redraw playerlist when player leaves
script.on_event(defines.events.on_player_left_game, function(event)
  -- local player = game.players[event.player_index]
  drawPlayerList()
end)

-- Manages our custom GUI clicks
script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]

  if event.element.name == "btn_menu_player_list" then
    togglePlayerList(player)
  end
end)

-- ================= GUI: Player List ================== --

-- Destroys a gui element and its children
function clearGuiElement(el)
  if el ~= nil then
    for i, child in pairs(el.children_names) do
      el[child].destroy()
    end
  end
end

-- Clears the GUI to start fresh
function clearPlayerGUI(player)
  if player.gui.top.MenuPlayerList ~= nil then
    player.gui.top.PlayerList.destroy()
  end
  if player.gui.top.MenuPlayerList ~= nil then
    player.gui.top.PlayerList.destroy()
  end
  if player.gui.left.Playerlist ~= nil then
    player.gui.left.PlayerList.destroy()
  end
end

-- Draws a pane on the left listing all of the players on the server
function drawPlayerList()
  for i, player in pairs(game.players) do
    -- Draw the vertical frame on the left if its not drawn already
    if player.gui.left.PlayerList == nil then
      player.gui.left.add{type = "frame",   name = "PlayerList",  direction = "vertical"}
    end
    -- Clear and repopulate player list
    clearGuiElement(player.gui.left.PlayerList)
    for j, p_online in pairs(game.connected_players) do
      -- Admins
      if p_online.admin == true then
        if p_online.name == OWNER then
          addPlayerToGUIList(player, p_online, COLOR_OVERLORD, "[Owner]", "(Owner)")
        else
          addPlayerToGUIList(player, p_online, COLOR_GUARDIAN, "[Admin]", "(Admin)")
        end
      -- Players
      elseif tickToMin(p_online.online_time) >= HERO_TIME then
          addPlayerToGUIList(player, p_online, COLOR_HERO,     "[Hero]", "")
      else
          addPlayerToGUIList(player, p_online, COLOR_MINION,   "[Minion]", "")
      end
    end
  end
end

-- Add a player to the GUI list
function addPlayerToGUIList(player, p_online, color, tag, label)
  local time_str = tostring(tickToHour(p_online.online_time))
  player.gui.left.PlayerList.add{
    type = "label", style = "caption_label_style", name = p_online.name,
    caption = {"", time_str, " hr - ", p_online.name, " ", label}
  }
  player.gui.left.PlayerList[p_online.name].style.font_color = color
  p_online.tag = tag
end

-- Draws the menu buttons user can use to open custom windows
function drawMenuButtons()
  for i, player in pairs(game.players) do
    local menu = player.gui.top
    clearGuiElement(menu)
    menu.add{type = "button", name = "btn_menu_player_list",  caption = "Player List",  tooltip = "Shows who is on the server"}
  end
end

-- Toogle the Playerlist visibility panel on/off
function togglePlayerList(player)
  if player.gui.left.PlayerList ~= nil then
    if player.gui.left.PlayerList.style.visible == false then
      player.gui.left.PlayerList.style.visible = true
    else
      player.gui.left.PlayerList.style.visible = false 
    end 
  end 
end


-- ================ Helper Functions =================== --

-- Returns hours converted from game ticks
function tickToHour(t)
  return math.floor(t * 1 / (60 * game.speed) / 3600)
end

-- Returns hours converted from game ticks
function tickToMin(t)
  return math.floor(t * 1 / (60 * game.speed) / 60)
end

-- Displays a message only to Admin Player(s)
function msgAdmin(msg)
  for i, player in pairs(game.players) do
    if player.admin then
      player.print(msg)
    end 
  end 
end
