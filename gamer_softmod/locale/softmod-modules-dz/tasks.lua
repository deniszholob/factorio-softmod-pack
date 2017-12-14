-- Tasks Soft Mod
-- Seasoned players (time defined in config) can add/delete tasks,
-- all players can view the different tasks to be done
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Dependencies
require "locale/softmod-modules-util/GUI"
require "locale/softmod-modules-util/Time"
require "locale/softmod-modules-util/Colors"
require "config"

-- Constants
local TASK_LIMIT = 10
local TASK_LEN_MIN = 3
local TASK_LEN_MAX = 100
local REGULAR_TIME = 60 -- min

-- stores tasks here, init with defaults.
local DEFAULT_TASKS = {
  "Get Power",
  "Build simple belt production",
  "Build simple red science automation",
  "Build simple circuit production",
  "Build simple inserter production",
  "Build simple green science automation",
  "Build Bus start (plan lanes)",
  "Build large smelteries (copper, iron)"
}

-- Errors to display on user operations
local ERROR_LIST = {
  length_limit = "Task must be "..TASK_LEN_MIN.." - "..TASK_LEN_MAX.." characters long.",
  rank_limit = "Play more to unlock task creation/deletion.",
  task_limit = "Complete tasks to add more"
}

-- Master button controlls the visibility of the readme window
local MASTER_BTN =   { name = "btn_task", caption = "Tasks", tooltip = "Current Tasks" }
-- Master frame(window), holds all the contents
local MASTER_FRAME = { name = "frame_task" }


-- Draw the task gui for new player
-- @param event on_player_joined_game
function on_player_join(event)
  setup_tasks()
  local player = game.players[event.player_index]
  draw_master_task_btn(player)

  -- Force a gui refresh in case there where updates
  if player.gui.center[MASTER_FRAME.name] ~= nil then
    player.gui.center[MASTER_FRAME.name].destroy()
  end

  draw_task_frame(player)
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


-- Creates a global var to read tasks from if it hasnt been created already
function setup_tasks()
  if global.scenario == nil then
    global.scenario = {}
  end
  if global.scenario.config == nil then
    global.scenario.config = {}
  end
  if global.scenario.config.task_list == nil then
    -- Populate with defaults if the game is fresh
    if Time.tick_to_min(game.tick) < REGULAR_TIME then
      global.scenario.config.task_list = DEFAULT_TASKS
    else
      global.scenario.config.task_list = {}
    end
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
    -- Call toggle if frame has been created
    if(player.gui.center[MASTER_FRAME.name] ~= nil) then
      GUI.toggle_element(player.gui.center[MASTER_FRAME.name])
      update_tasks_gui_player(player)
    else -- Call create if it hasn't
      draw_task_frame(player)
    end
    show_task_creation(player)
  elseif el_name == "btn_new_task" then
    create_new_task(player)
    update_tasks_gui_all()
  elseif el_name == "btn_task_close" then
    GUI.toggle_element(player.gui.center[MASTER_FRAME.name])
  end
    -- One of the tasks done?
    for i, task in pairs(global.scenario.config.task_list) do
      if el_name == ('btn_'..i) then
        delete_task(player, i)
        update_tasks_gui_all()
      end
    end
end


-- Draws the master readme button on the top of the screen
-- @param player
function draw_master_task_btn(player)
  if player.gui.top[MASTER_BTN.name] == nil then
    player.gui.top.add { type = "button", name = MASTER_BTN.name, caption = MASTER_BTN.caption, tooltip = MASTER_BTN.tooltip }
  end
end


-- Draws the main task container window
-- @param player
function draw_task_frame(player)
  if(player.gui.center[MASTER_FRAME.name] == nil) then
    local frame = player.gui.center.add { type = "frame", name = MASTER_FRAME.name, direction = "vertical" }
    -- make a container for adding new task and add button and textfield
    frame.add { type = "label", name = "lbl_title", caption = "=== TASK LIST ===" }.style.font_color = Colors.green
    frame.add { type = "flow", name = "flow_task_ctrl", direction = "horizontal" }
    frame["flow_task_ctrl"].add { type = "button",    name = "btn_new_task", caption = "Add Task" }
    frame["flow_task_ctrl"].add { type = "textfield", name = "txt_new_task" }
    frame["flow_task_ctrl"].add { type = "button",    name = "btn_task_close", caption = "Close" }.style.font_color = Colors.red
    frame.add { type = "label", name = "lbl_error", caption = "" }.style.font_color = Colors.red
    -- make a tab content container
    frame.add { type = "scroll-pane", name = "scroll_content", direction = "vertical", vertical_scroll_policy = "always", horizontal_scroll_policy = "auto" }
    -- Style config for content
    frame.scroll_content.style.maximal_height = 400;
    frame.scroll_content.style.minimal_height = 400;
    frame.scroll_content.style.maximal_width  = 500;
    frame.scroll_content.style.minimal_width  = 500;
    -- Make frame invisible upon startup
    frame.style.visible = false
  end
end


-- Shows the textfield and add task button if player is seasoned
-- @param player
function show_task_creation(player)
  local frame = player.gui.center[MASTER_FRAME.name]
  -- Limit task addition/deletion to seasoned players
  if player.admin or Time.tick_to_min(player.online_time) >= REGULAR_TIME then
    frame.flow_task_ctrl.style.visible = true
    hide_error(player)
  else
    frame.flow_task_ctrl.style.visible = false
    show_error(player, ERROR_LIST.rank_limit)
  end
end

-- Updates the tasks in the gui
function update_tasks_gui_all()
  for i, player in pairs(game.connected_players) do
    update_tasks_gui_player(player)
  end
end


-- Updates the tasks in the gui
function update_tasks_gui_player(player)
  local task_frame = player.gui.center[MASTER_FRAME.name]["scroll_content"]
  GUI.clear_element(task_frame)
  for i, task in pairs(global.scenario.config.task_list) do
    draw_task(player, task_frame, i, task)
  end
end

-- adds a new task to component
-- @param parent_el - gui parent element top add task to
function draw_task(player, parent_el, task_idx, task_contents)
  local task = parent_el.add { type = "flow", name = "task_"..task_idx, direction = "horizontal" }
  if player.admin or Time.tick_to_min(player.online_time) >= REGULAR_TIME then
    task.add { type = "button", name = "btn_"..task_idx, caption = "X"}
  end
  task.add { type = "label",  name = "lbl_"..task_idx, caption = task_idx .. ". " .. task_contents }
end


-- Creates a new task and clears textbox
-- @param player
function create_new_task(player)
  local frame = player.gui.center[MASTER_FRAME.name]
  if table.maxn(global.scenario.config.task_list) < TASK_LIMIT then
    hide_error(player)
    local task_text = frame.flow_task_ctrl.txt_new_task.text
    if string.len(task_text) >= TASK_LEN_MIN and string.len(task_text) <= TASK_LEN_MAX then
      table.insert( global.scenario.config.task_list, task_text )
      frame.flow_task_ctrl.txt_new_task.text =  ""
      hide_error(player)
      game.print(player.name .. " created a new task: " .. task_text)
    else
      show_error(player, ERROR_LIST.length_limit)
    end
  else
      show_error(player, ERROR_LIST.task_limit)
  end
end


-- Delete task
-- @param task name
function delete_task(player, task_idx)
  game.print(player.name .. " removed a task: " .. global.scenario.config.task_list[task_idx])
  table.remove( global.scenario.config.task_list, task_idx )
end


-- Changes error label text and turns it on.
-- @param player
function show_error(player, error_txt)
  player.gui.center[MASTER_FRAME.name]["lbl_error"].caption = error_txt
  player.gui.center[MASTER_FRAME.name]["lbl_error"].style.visible = true
end


-- Hides the error label
-- @param player
function hide_error(player)
  player.gui.center[MASTER_FRAME.name]["lbl_error"].style.visible = false
end


-- Event Handlers
Event.register(defines.events.on_gui_click, on_gui_click)
Event.register(defines.events.on_player_joined_game, on_player_join)
Event.register(defines.events.on_player_left_game, on_player_leave)

-- Put in the default task at the start of a new game
Event.register(-1, function()
    global.scenario.config.task_list = DEFAULT_TASKS
end)
