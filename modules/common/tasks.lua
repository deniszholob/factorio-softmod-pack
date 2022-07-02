-- Tasks Soft Module
-- Holds a list of tasks that need to be done
-- Add, delete, modify tasks
-- @usage require('modules/common/tasks')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local GUI = require("stdlib/GUI")
local Styles = require("util/Styles")
local Sprites = require('util/Sprites')

-- Constants --
-- ======================================================= --
Tasks = {
    MENU_BTN_NAME = "btn_menu_Tasks",
    MASTER_FRAME_NAME = "frame_Tasks",
    MASTER_FRAME_LOCATION = GUI.MASTER_FRAME_LOCATIONS.left,
    -- Check Factorio prototype definitions in \Factorio\data\core and \Factorio\data\base
    SPRITE_NAMES = {
        menu = Sprites.slot_icon_robot_material,
        add = Sprites.add,
        edit = Sprites.rename_icon_normal,
        -- delete = Sprites.remove
        delete = Sprites.set_bar_slot,
        confirm = Sprites.confirm_slot,
        up = Sprites.hint_arrow_up,
        down = Sprites.hint_arrow_down,
    },
    -- Utf shapes https://www.w3schools.com/charsets/ref_utf_geometric.asp
    -- Utf symbols https://www.w3schools.com/charsets/ref_utf_symbols.asp
    TEXT_SYMBOLS = {
        up = '▲',
        down = '▼',
        add = '✚',
        delete = '✖',
        edit = '✒',
        confirm = '✔',
    },
    get_menu_button = function(player)
        return GUI.menu_bar_el(player)[Tasks.MENU_BTN_NAME]
    end,
    get_master_frame = function(player)
        return GUI.master_frame_location_el(player, Tasks.MASTER_FRAME_LOCATION)[
            Tasks.MASTER_FRAME_NAME
        ]
    end,
    -- Stores tasks here, init with defaults.
    DEFAULT_TASKS = {
        "Get Power",
        "Build simple belt production",
        "Build simple red science automation",
        "Build simple circuit production",
        "Build simple inserter production",
        "Build simple green science automation",
        "Build Bus start (plan lanes)",
        "Build large smelteries (copper, iron)"
    }
}

-- Event Functions --
-- ======================================================= --
--- When new player joins add a btn to their menu bar
--- Redraw this softmod's master frame (if desired)
--- @param event defines.events.on_player_joined_game
function Tasks.on_player_joined_game(event)
    local player = game.players[event.player_index]
    Tasks.draw_menu_btn(player)
    Tasks.add_default_tasks(Tasks.DEFAULT_TASKS)
    -- Tasks.draw_master_frame(player) -- Will appear on load, comment out to load later on button click
end

--- When a player leaves clean up their GUI in case this mod gets removed or changed next time
--- @param event defines.events.on_player_left_game
function Tasks.on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(Tasks.get_menu_button(player))
    GUI.destroy_element(Tasks.get_master_frame(player))
end

--- Button Callback (On Click Event)
--- @param event event factorio lua event (on_gui_click)
function Tasks.on_gui_click_btn_menu(event)
    local player = game.players[event.player_index]
    local master_frame = Tasks.get_master_frame(player)

    if (master_frame ~= nil) then
        -- Call toggle if frame has been created
        GUI.toggle_element(master_frame)
    else
        -- Call create if it hasnt
        Tasks.draw_master_frame(player)
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_joined_game, Tasks.on_player_joined_game)
Event.register(defines.events.on_player_left_game, Tasks.on_player_left_game)

-- GUI Functions --
-- ======================================================= --

--- GUI Function
--- Draws a button in the menubar to toggle the GUI frame on and off
--- @param player LuaPlayer current player calling the function
function Tasks.draw_menu_btn(player)
    local menubar_button = Tasks.get_menu_button(player)
    if menubar_button == nil then
        GUI.add_sprite_button(
            GUI.menu_bar_el(player),
            {
                type = "sprite-button",
                name = Tasks.MENU_BTN_NAME,
                sprite = GUI.get_safe_sprite_name(player, Tasks.SPRITE_NAMES.menu),
                -- caption = 'Tasks.menu_btn_caption',
                tooltip = 'Show Task List'
            },
            function(event)
                -- On Click callback function
                Tasks.on_gui_click_btn_menu(event)
            end
        )
    end
end

--- GUI Function
--- Creates the main/master frame where all the GUI content will go in
--- @param player LuaPlayer current player calling the function
function Tasks.draw_master_frame(player)
    local master_frame = Tasks.get_master_frame(player)

    if (master_frame == nil) then
        master_frame =
            GUI.master_frame_location_el(player, Tasks.MASTER_FRAME_LOCATION).add(
            {
                type = "frame",
                name = Tasks.MASTER_FRAME_NAME,
                direction = "vertical",
                caption = 'Task List'
            }
        )
        GUI.element_apply_style(master_frame, Styles.frm_window)

        Tasks.fill_master_frame(master_frame, player)
    end
end

--- GUI Function
--- @param container LuaGuiElement parent container to add GUI elements to
--- @param player LuaPlayer current player calling the function
function Tasks.fill_master_frame(container, player, edit_task)
    local config = Tasks.getConfig()

    GUI.clear_element(container)

    -- Loop through all the tasks...
    for key, task in pairs(config.tasks) do
        local task_flow = container.add({type = "flow", name = "task_flow" .. task.id, direction = "horizontal"})
        if (edit_task and config.tasks[key].id == edit_task.id) then
            -- Confirm Button
            local btn_confirm_task =
                GUI.add_sprite_button(
                task_flow,
                {
                    type = "sprite-button",
                    name = "btn_confirm_task_" .. task.id,
                    caption = Tasks.TEXT_SYMBOLS.confirm,
                    -- sprite = GUI.get_safe_sprite_name(player, Tasks.SPRITE_NAMES.confirm),
                    tooltip = "Confirm"
                },
                -- On Click callback function
                function(event)
                    local id = task.id
                    local text =
                        Tasks.get_master_frame(player)["task_flow" .. task.id]["textfield_" .. task.id].text
                    Tasks.edit_task(id, text)
                    Tasks.update_tasks_gui()
                end
            )
            GUI.element_apply_style(btn_confirm_task, Styles.small_button)
            GUI.element_apply_style(btn_confirm_task, Styles.txt_clr_green)
            local lbl_test = task_flow.add({type = "textfield", name = "textfield_" .. task.id, text = task.text})
        else
            -- Edit button
            local btn_edit_task_ =
                GUI.add_sprite_button(
                task_flow,
                {
                    type = "sprite-button",
                    name = "btn_edit_task_" .. task.id,
                    caption = Tasks.TEXT_SYMBOLS.edit,
                    -- sprite = GUI.get_safe_sprite_name(player, Tasks.SPRITE_NAMES.edit),
                    tooltip = "Edit"
                },
                -- On Click callback function
                function(event)
                    Tasks.fill_master_frame(container, player, task)
                end
            )
            GUI.element_apply_style(btn_edit_task_, Styles.small_button)
            GUI.element_apply_style(btn_edit_task_, Styles.txt_clr_yellow)

            -- Delete button
            local btn_delete_task_ =
                GUI.add_sprite_button(
                task_flow,
                {
                    type = "sprite-button",
                    name = "btn_delete_task_" .. task.id,
                    caption = Tasks.TEXT_SYMBOLS.delete,
                    -- sprite = GUI.get_safe_sprite_name(player, Tasks.SPRITE_NAMES.delete),
                    tooltip = "Delete"
                },
                -- On Click callback function
                function(event)
                    Tasks.delete_task(task, player.name)
                    Tasks.update_tasks_gui()
                end
            )
            GUI.element_apply_style(btn_delete_task_, Styles.small_button)
            GUI.element_apply_style(btn_delete_task_, Styles.txt_clr_red)

            -- Up button
            local btn_up_task =
                GUI.add_sprite_button(
                task_flow,
                {
                    -- type = "button",
                    type = "sprite-button",
                    name = "btn_up_task" .. task.id,
                    caption = Tasks.TEXT_SYMBOLS.up,
                    -- sprite = GUI.get_safe_sprite_name(player, Tasks.SPRITE_NAMES.up),
                    tooltip = "Increse Priority"
                },
                -- On Click callback function
                function(event)
                    Tasks.move_task(task.id, task.id - 1)
                    Tasks.update_tasks_gui()
                end
            )
            -- GUI.element_apply_style(btn_up_task, Styles.small_symbol_button)
            GUI.element_apply_style(btn_up_task, Styles.small_button)
            GUI.element_apply_style(btn_up_task, Styles.txt_clr_blue)
            if (key <= 1) then
                btn_up_task.enabled = false
            else
                btn_up_task.enabled = true
            end

            -- Down button
            local btn_down_task =
                GUI.add_sprite_button(
                task_flow,
                {
                    -- type = "button",
                    type = "sprite-button",
                    name = "btn_down_task" .. task.id,
                    caption = Tasks.TEXT_SYMBOLS.down,
                    -- sprite = GUI.get_safe_sprite_name(player, Tasks.SPRITE_NAMES.down),
                    tooltip = "Decrease Priority"
                },
                -- On Click callback function
                function(event)
                    Tasks.move_task(task.id, task.id + 1)
                    Tasks.update_tasks_gui()
                end
            )
            -- GUI.element_apply_style(btn_down_task, Styles.small_symbol_button)
            GUI.element_apply_style(btn_down_task, Styles.small_button)
            GUI.element_apply_style(btn_down_task, Styles.txt_clr_blue)
            if (key >= table.maxn(config.tasks)) then
                btn_down_task.enabled = false
            else
                btn_down_task.enabled = true
            end

            -- Task label
            local lbl_task =
                task_flow.add({type = "label", name = "label_" .. task.id, caption = task.id .. " | " .. task.text})

            lbl_task.style.font_color = Colors.lightgrey
            if(task.id == 1) then lbl_task.style.font_color = Colors.green end
            if(task.id == 2) then lbl_task.style.font_color = Colors.yellow end
            if(task.id == 3) then lbl_task.style.font_color = Colors.lightblue end
            if(task.id == 4) then lbl_task.style.font_color = Colors.white end
        end
    end

    -- Add Task Button
    local btn_add_task = Tasks.get_master_frame(player).btn_add_task
    if (btn_add_task == nil) then
        btn_add_task =
            GUI.add_sprite_button(
            container,
            {
                type = "sprite-button",
                name = "btn_add_task",
                caption = Tasks.TEXT_SYMBOLS.add,
                -- sprite = GUI.get_safe_sprite_name(player, Tasks.SPRITE_NAMES.add),
                tooltip = "Add new task"
            },
            -- On Click callback function
            function(event)
                local new_task = Tasks.add_new_task(player.name)
                Tasks.fill_master_frame(container, player, new_task)
            end
        )
    end
    -- GUI.element_apply_style(btn_add_task, Styles.small_button)
    GUI.element_apply_style(btn_add_task, Styles.small_symbol_button)
    GUI.element_apply_style(btn_add_task, Styles.txt_clr_green)
    if (edit_task) then
        btn_add_task.enabled = false
    else
        btn_add_task.enabled = true
    end
end


--- GUI Function
--- Updates the task list for all players in game
function Tasks.update_tasks_gui()
    for _, player in pairs(game.connected_players) do
        local master_frame = Tasks.get_master_frame(player)
        Tasks.fill_master_frame(master_frame, player)
    end
end

-- Logic Functions --
-- ======================================================= --

--- Returns the task config
function Tasks.getConfig()
    if (not global.Tasks_config) then
        global.Tasks_config = {
            tasks = {},
            notifications = true
        }
    end

    return global.Tasks_config
end


--- Adds some default tasks to the global task table
function Tasks.add_default_tasks(task_strings)
    -- Only want to add the default tasks if not initialized yet
    if (not global.Tasks_config) then
        local name = 'soft-mod'
        -- Loop trough the strings and add in the task objects to the global task table
        for _, task_str in pairs(task_strings) do
            local task_obj = Tasks.add_new_task(name)
            Tasks.edit_task(task_obj.id, task_str, name)
        end
    end
end

--- Creates, and adds a new blank task to the global task table, and returns it
--- @param player LuaPlayer
function Tasks.add_new_task(player_name)
    local config = Tasks.getConfig()
    local task = {
        id = 0,
        text = '',
        created_by = player_name,
        modified_by = player_name,
        assigned_to = ''
    }
    task.id = table.maxn(config.tasks) + 1
    table.insert(config.tasks, task.id, task)
    game.print('New task created by ' .. player_name)
    return task
end

--- Deletes the task from the global task table
--- @param task table object
function Tasks.delete_task(task, player_name)
    local config = Tasks.getConfig()
    table.remove(config.tasks, task.id)
    Tasks.sync_task_ids(config.tasks)
    game.print('Task deleted by ' .. player_name .. ': "' .. task.text .. '"')
end

--- Modifies the task text corresponding with the id passed in with the new text passed in
--- @param id number task integer position in the table
--- @param text string new text to replace the current task text with
function Tasks.edit_task(id, text, player_name)
    local config = Tasks.getConfig()
    config.tasks[id].text = text
    config.tasks[id].modified_by = player_name
end

--- Moves the task to a new position in the global task table
--- @param cur_position integer current position of the task in the table
--- @param new_position integer new position of the task in the table
function Tasks.move_task(cur_position, new_position)
    local config = Tasks.getConfig()
    local task = table.remove(config.tasks, cur_position)
    table.insert(config.tasks, new_position, task)
    Tasks.sync_task_ids(config.tasks)
end

--- Makes sure that the task object's id is the same as the position in the table
--- @param tasks table object table
function Tasks.sync_task_ids(tasks)
    for k, v in pairs(tasks) do
        tasks[k].id = k
    end
end
