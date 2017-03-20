
-- Dependencies
require "locale/softmod-modules-util/GUI"
require "locale/softmod-modules-util/Colors"

-- Master button controlls the visibility of the readme window
local MASTER_BTN =   { name = "btn_color_test", caption = "Color Test", tooltip = "" }
-- Master frame(window), holds all the contents
local MASTER_FRAME = { name = "frame_color_test" }


-- On Player Join
-- @param event on_player_joined_game
function on_player_join(event)
  local player = game.players[event.player_index]
  draw_master_task_btn(player)

  -- Force a gui refresh in case there where updates
  if player.gui.center[MASTER_FRAME.name] ~= nil then
    player.gui.center[MASTER_FRAME.name].destroy()
  end
  draw_color_frame(player)
end


-- Draws the master button on the top of the screen
-- @param player
function draw_master_task_btn(player)
  if player.gui.top[MASTER_BTN.name] == nil then
    player.gui.top.add { type = "button", name = MASTER_BTN.name, caption = MASTER_BTN.caption, tooltip = MASTER_BTN.tooltip }
  end
end


-- On Player Leave
-- Clean up the GUI in case this mod gets removed next time
-- @param event on_player_left_game
function on_player_leave(event)
  local player = game.players[event.player_index]
  if player.gui.center[MASTER_FRAME.name] ~= nil then
    player.gui.center[MASTER_FRAME.name].destroy()
  end
  if player.gui.top[MASTER_BTN.name] ~= nil then
    player.gui.top[MASTER_BTN.name].destroy()
  end
end


-- Toggle playerlist is called if gui element is playerlist button
-- @param event on_gui_click
local function on_gui_click(event)
  local player = game.players[event.player_index]
  local el_name = event.element.name

  if el_name == MASTER_BTN.name then
    GUI.toggle_element(player.gui.left[MASTER_FRAME.name])
  end
end

-- Draws the color tester
-- @param player
function draw_color_frame(player)
    -- Draw the vertical frame on the left if its not drawn already
    if player.gui.left[MASTER_FRAME.name] == nil then
      player.gui.left.add { type = "frame", name = MASTER_FRAME.name, direction = "vertical" }
      player.gui.left[MASTER_FRAME.name].add { type = "scroll-pane", name = "scroll_content", direction = "vertical", vertical_scroll_policy = "always", horizontal_scroll_policy = "never" }
    end
    for i, color in pairs(Colors) do
      player.gui.left[MASTER_FRAME.name]["scroll_content"].add{
        type = "label", name = "color_" .. i, caption = i
      }
      player.gui.left[MASTER_FRAME.name]["scroll_content"]["color_" .. i].style.font_color = color
    end
end

-- Event Handlers
Event.register(defines.events.on_gui_click, on_gui_click)
Event.register(defines.events.on_player_joined_game, on_player_join)
Event.register(defines.events.on_player_left_game, on_player_leave)
