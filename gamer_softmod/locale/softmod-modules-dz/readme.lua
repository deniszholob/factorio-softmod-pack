-- Readme Soft Mod
-- Adds an readme window that contains rules and server info.
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Dependencies
require "locale/softmod-modules-util/GUI"
require "locale/softmod-modules-util/Time"

-- Master button controlls the visibility of the readme window
local MASTER_BTN =   { name = "btn_readme", caption = "Read Me", tooltip = "Server rules, communication, and more" }
-- Master frame(window), holds all the contents
local MASTER_FRAME = { name = "frame_readme" }
-- Tabs and the corresponding buttons to but in the master frame
local FRAME_TABS = {
  rules = {
    btn = { name = "btn_readme_rules", caption = "Rules",  tooltip = "" },
    win = { name = "win_rules", content = {}},
  },
  comm = {
    btn = { name = "btn_readme_comm",  caption = "Social", tooltip = "" },
    win = { name = "win_comm", content = {}},
  },
  close = {
    btn = { name = "btn_readme_close", caption = "Close",  tooltip = "" },
    win = { name = "win_close", content = {}},
  }
}

-- Rules
local content_rules = {
  "Check the tasklist for things that need doing, update as needed",
  "Build cleanly: no spaghetti factories near the bus! (except temp ones)",
  "Do not spam: chat spam, item/chest spam, concrete/brick spam, etc...",
  "Use brick/concrete for roads not spam whole base (increases pollution)",
  "Leave plenty of space between builds (at least 3 tiles)",
  "Do not make train roundabouts, junctions only",
  "Right Hand drive",
  "Train Stations are 'one 2-way'' track",
  "Do not walk in a random direction for no reason (to save map size)"
}

-- Social/Comm
local content_comm = {
  "* Chat using the lua console (toggle with TILDE (~) key under the ESC key)",
  "",
  "* Join discord for voice chat and admin support:",
  "  https://discord.gg/hmwb3dB",
  "",
  "* Visit the youtube page for tutorials and letplays:",
  "  https://www.youtube.com/channel/UCUrxnam98XPOY6xpP7WBKXg",
  "  or search 'DDDGamer Lp'",
  --add github link here
}


-- On Player Join
-- Display the master button, and show rules if new player
-- @param event on_player_joined_game
function on_player_join(event)
  local player = game.players[event.player_index]
  draw_master_readme_btn(player)
  -- Show readme window (rules) when player (not admin) first joins, but not at later times
  if not player.admin and Time.tick_to_min(player.online_time) < 1 then
    draw_master_readme_frame(player, FRAME_TABS.rules.win.name) 
  end
end


-- On GUI Click
-- Depending of what button was click open a different tab
-- @param event on_gui_click
function on_gui_click(event)
  local player = game.players[event.player_index]
  local el_name = event.element.name
  -- Master frame gui button?
  if el_name == MASTER_BTN.name then
    -- toggle_master_readme_frame(player) -- DEPRICATED --
    -- Call toggle if frame has been created
    if(player.gui.center[MASTER_FRAME.name] ~= nil) then
      GUI.toggle_element(player.gui.center[MASTER_FRAME.name])
    else -- Call create if it hasnt
      draw_master_readme_frame(player, FRAME_TABS.rules.win.name)
    end
  end
  -- One of the tabs?
  for i, frame_tab in pairs(FRAME_TABS) do
    if el_name == frame_tab.btn.name then
      draw_master_readme_frame(player, frame_tab.win.name)
    end
  end
end


-- Draws the master readme button on the top of the screen
-- @param player
function draw_master_readme_btn(player)
  if player.gui.top[MASTER_BTN.name] == nil then
    player.gui.top.add { type = "button", name = MASTER_BTN.name, caption = MASTER_BTN.caption, tooltip = MASTER_BTN.tooltip }
  end
end


-- Draws the master frame and a tab inside it base on arg
-- *Recursive (only 1 deep)
-- @param player
-- @param window_name - which window to display in the frame
function draw_master_readme_frame(player, window_name)
  -- Master frame is already created, just draw a new tab
  if player.gui.center[MASTER_FRAME.name] ~= nil then
    if window_name == FRAME_TABS.rules.win.name then
      GUI.clear_element(player.gui.center[MASTER_FRAME.name]["scroll_content"])
      draw_readme_rules(player.gui.center[MASTER_FRAME.name]["scroll_content"])
    elseif window_name == FRAME_TABS.comm.win.name then
      GUI.clear_element(player.gui.center[MASTER_FRAME.name]["scroll_content"])
      draw_readme_comm(player.gui.center[MASTER_FRAME.name]["scroll_content"])
    elseif window_name == FRAME_TABS.close.win.name then
      GUI.toggle_element(player.gui.center[MASTER_FRAME.name])
    end
  else -- create the master frame and call function again to draw specific tab
    local frame = player.gui.center.add { type = "frame", direction = "vertical", name = MASTER_FRAME.name }
    -- make a nav container and add nav buttons
    frame.add { type = "flow", name = "readme_nav", direction = "horizontal" }
    draw_frame_nav(frame.readme_nav)
    -- make a tab content container
    frame.add { type = "scroll-pane", name = "scroll_content", direction = "vertical", vertical_scroll_policy = "always", horizontal_scroll_policy = "never" }
    -- Style config for nav
    frame.readme_nav.style.maximal_width = 500;
    frame.readme_nav.style.minimal_width = 500;
    -- Style config for content
    frame.scroll_content.style.maximal_height = 400;
    frame.scroll_content.style.minimal_height = 400;
    frame.scroll_content.style.maximal_width  = 500;
    frame.scroll_content.style.minimal_width  = 500;
    -- Recursive call
    draw_master_readme_frame(player, window_name)
  end
end


-- Draws the nav buttons for readme frame
-- @param nav_container GUI element to add the buttons to
  function draw_frame_nav(nav_container)
  for i, frame_tab in pairs(FRAME_TABS) do
    nav_container.add {
      type = "button",
      name = frame_tab.btn.name,
      caption = frame_tab.btn.caption,
      tooltip = frame_tab.btn.tooltip
    }
  end
end


-- Draws the Rules tab
function draw_readme_rules( container )
  for i, text in pairs(content_rules) do
    container.add { type = "label", name = i, caption = i .. ". " .. text }
  end
end


-- Draws the comm tab
function draw_readme_comm( container )
  for i, text in pairs(content_comm) do
    container.add { type = "label", name = i, caption = text }
  end
end


-- Event Handlers
Event.register(defines.events.on_gui_click, on_gui_click)
Event.register(defines.events.on_player_joined_game, on_player_join)




-- DEPRICATED use GUI instead
-- Toggled readme window on and off
-- function toggle_master_readme_frame(player)
--   -- Master frame is already created...
--   if player.gui.center[MASTER_FRAME.name] ~= nil then
--     destroy_master_readme_frame(player)
--     return
--   else --dont have a frame so create one
--     draw_master_readme_frame(player, FRAME_WINDOWS.rules.name, true)
--   end
-- end


-- -- Destroys the master frame
-- -- @param player
-- function destroy_master_readme_frame(player)
--     player.gui.center[MASTER_FRAME.name].destroy()
-- end
