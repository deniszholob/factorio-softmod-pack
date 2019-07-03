-- Auto Research Soft Module
-- Provides a way to queue up research that will automatically research prerequizites.
-- Softmod conversion from the original auto-research mod by canidae (https://mods.factorio.com/user/canidae)
-- @see https://mods.factorio.com/mod/auto-research
-- Uses locale auto-research.cfg
-- @usage require('modules/common/research-queue/auto-research')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local GUI = require("stdlib/GUI")
local Styles = require("util/Styles")
local Research_Queue_Styles = require('modules/common/research-queue/Research_Queue_Styles')

-- Constants --
-- ======================================================= --
Auto_Research = {
    MENU_BTN_NAME = "btn_menu_Auto_Research",
    MASTER_FRAME_NAME = "frame_Auto_Research",
    MASTER_FRAME_LOCATION = GUI.MASTER_FRAME_LOCATIONS.left,
    -- Check Factorio prototype definitions in \Factorio\data\core and \Factorio\data\base
    SPRITE_NAMES = {
        menu = Sprites.lab,
        up = Sprites.hint_arrow_up,
        down = Sprites.hint_arrow_down,
        blacklist = Sprites.clear,
        remove = Sprites.set_bar_slot,
        tech_prefix = 'technology/',
        item_prefix = 'item/',
    },
    -- Utf shapes https://www.w3schools.com/charsets/ref_utf_geometric.asp
    -- Utf symbols https://www.w3schools.com/charsets/ref_utf_symbols.asp
    TEXT_SYMBOLS = {
        up = '▲',
        down = '▼',
        blacklist = '⊘',
        remove = '✖',
    },
    get_menu_button = function(player)
        return GUI.menu_bar_el(player)[Auto_Research.MENU_BTN_NAME]
    end,
    get_master_frame = function(player)
        return GUI.master_frame_location_el(player, Auto_Research.MASTER_FRAME_LOCATION)[
            Auto_Research.MASTER_FRAME_NAME
        ]
    end,
    default_queued_techs = {
        'automation',
        'military-1',
        'logistics',
        'turrets',
    },
    default_blacklisted_techs = {
        'combat-robotics',
    },
    default_allowed_research_ingredients = {
        ['automation-science-pack'] = true
    }
}

-- Event Functions --
-- ======================================================= --

-- When new player joins add a btn to their menu bar
-- Redraw this softmod's master frame (if desired)
-- @param event on_player_joined_game
function Auto_Research.on_player_joined_game(event)
    local player = game.players[event.player_index]
    Auto_Research.disableDefaultGameQueue(player.force)
    Auto_Research.setDefaultConfig(player.force)
    Auto_Research.draw_menu_btn(player)
    -- Auto_Research.draw_master_frame(player) -- Will appear on load, cooment out to load later on button click
end

-- When a player leaves clean up their GUI in case this mod gets removed or changed next time
-- @param event on_player_left_game
function Auto_Research.on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(Auto_Research.get_menu_button(player))
    GUI.destroy_element(Auto_Research.get_master_frame(player))
end

-- Button Callback (On Click Event)
-- @param event factorio lua event (on_gui_click)
function Auto_Research.on_gui_click_btn_menu(event)
    local player = game.players[event.player_index]
    local master_frame = Auto_Research.get_master_frame(player)

    if (master_frame ~= nil) then
        -- Call toggle if frame has been created
        GUI.toggle_element(master_frame)
    else
        -- Call create if it hasnt
        Auto_Research.draw_master_frame(player)
    end
end

--
-- @param event factorio lua event
function Auto_Research.on_research_finished(event)
    local force = event.research.force
    local config = Auto_Research.getConfig(force)
    -- remove researched stuff from prioritized_techs and deprioritized_techs
    for i = #config.prioritized_techs, 1, -1 do
        local tech = force.technologies[config.prioritized_techs[i]]
        if not tech or tech.researched then
            table.remove(config.prioritized_techs, i)
        end
    end
    for i = #config.deprioritized_techs, 1, -1 do
        local tech = force.technologies[config.deprioritized_techs[i]]
        if not tech or tech.researched then
            table.remove(config.deprioritized_techs, i)
        end
    end
    -- announce completed research
    if config.announce_completed and config.no_announce_this_tick ~= game.tick then
        if config.last_research_finish_tick == game.tick then
            config.no_announce_this_tick = game.tick
            force.print{"auto_research.announce_multiple_completed"}
        else
            local level = ""
            if event.research.research_unit_count_formula then
                level = (event.research.researched and event.research.level) or (event.research.level - 1)
            end
            force.print{"auto_research.announce_completed", event.research.localised_name, level}
        end
    end

    Auto_Research.startNextResearch(event.research.force)
end

-- TODO: Convert to GUI registration instead of here?
-- @param event factorio lua event
function Auto_Research.GUI_onClick(event)
    local player = game.players[event.player_index]
    local force = player.force
    local config = Auto_Research.getConfig(force)
    local name = event.element.name
    if name == "auto_research_enabled" then
        Auto_Research.setAutoResearch(force, event.element.state)
    elseif name == "auto_research_queued_only" then
        Auto_Research.setQueuedOnly(force, event.element.state)
    elseif name == "auto_research_allow_switching" then
        Auto_Research.setAllowSwitching(force, event.element.state)
    elseif name == "auto_research_announce_completed" then
        Auto_Research.setAnnounceCompletedResearch(force, event.element.state)
    elseif name == "auto_research_deprioritize_infinite_tech" then
        Auto_Research.setDeprioritizeInfiniteTech(force, event.element.state)
    elseif name == "auto_research_search_text" then
        if event.button == defines.mouse_button_type.right then
            Auto_Research.get_master_frame(player).split_flow.frameflow_right.searchflow.auto_research_search_text.text = ""
            Auto_Research.GUI_updateSearchResult(player, Auto_Research.get_master_frame(player).split_flow.frameflow_right.searchflow.auto_research_search_text.text)
        end
    elseif name == "auto_research_ingredients_filter_search_results" then
        config.filter_search_results = event.element.state
        Auto_Research.GUI_updateSearchResult(player, Auto_Research.get_master_frame(player).split_flow.frameflow_right.searchflow.auto_research_search_text.text)
    elseif string.find(name, "auto_research_research") then
        config.research_strategy = string.match(name, "^auto_research_research_(.*)$")
        Auto_Research.get_master_frame(player).split_flow.frameflow_left.research_strategies_one.auto_research_research_fast.state = (config.research_strategy == "fast")
        Auto_Research.get_master_frame(player).split_flow.frameflow_left.research_strategies_one.auto_research_research_cheap.state = (config.research_strategy == "cheap")
        Auto_Research.get_master_frame(player).split_flow.frameflow_left.research_strategies_one.auto_research_research_balanced.state = (config.research_strategy == "balanced")
        Auto_Research.get_master_frame(player).split_flow.frameflow_left.research_strategies_two.auto_research_research_slow.state = (config.research_strategy == "slow")
        Auto_Research.get_master_frame(player).split_flow.frameflow_left.research_strategies_two.auto_research_research_expensive.state = (config.research_strategy == "expensive")
        Auto_Research.get_master_frame(player).split_flow.frameflow_left.research_strategies_two.auto_research_research_random.state = (config.research_strategy == "random")
        -- start new research
        Auto_Research.startNextResearch(force)
    else
        local prefix, name = string.match(name, "^auto_research_([^-]*)-(.*)$")
        if prefix == "allow_ingredient" then
            config.allowed_ingredients[name] = not config.allowed_ingredients[name]
            Auto_Research.GUI_updateAllowedIngredientsList(Auto_Research.get_master_frame(player).split_flow.frameflow_left.allowed_ingredients, player, config)
            if Auto_Research.get_master_frame(player).split_flow.frameflow_right.searchoptionsflow.auto_research_ingredients_filter_search_results.state then
                Auto_Research.GUI_updateSearchResult(player, Auto_Research.get_master_frame(player).split_flow.frameflow_right.searchflow.auto_research_search_text.text)
            end
            Auto_Research.startNextResearch(force)
        elseif name and force.technologies[name] then
            -- remove tech from prioritized list
            for i = #config.prioritized_techs, 1, -1 do
                if config.prioritized_techs[i] == name then
                    table.remove(config.prioritized_techs, i)
                end
            end
            -- and from deprioritized list
            for i = #config.deprioritized_techs, 1, -1 do
                if config.deprioritized_techs[i] == name then
                    table.remove(config.deprioritized_techs, i)
                end
            end
            if prefix == "queue_top" then
                -- add tech to top of prioritized list
                table.insert(config.prioritized_techs, 1, name)
            elseif prefix == "queue_bottom" then
                -- add tech to bottom of prioritized list
                table.insert(config.prioritized_techs, name)
            elseif prefix == "blacklist" then
                -- add tech to list of deprioritized techs
                table.insert(config.deprioritized_techs, name)
            end
            Auto_Research.GUI_updateTechnologyList(Auto_Research.get_master_frame(player).split_flow.frameflow_right.prioritized, config.prioritized_techs, player, true)
            Auto_Research.GUI_updateTechnologyList(Auto_Research.get_master_frame(player).split_flow.frameflow_right.deprioritized, config.deprioritized_techs, player)
            Auto_Research.GUI_updateSearchResult(player, Auto_Research.get_master_frame(player).split_flow.frameflow_right.searchflow.auto_research_search_text.text)

            -- start new research
            Auto_Research.startNextResearch(force)
        end
    end
end

-- Event Registration --
-- ======================================================= --
-- Event.register(defines.events.on_force_created, Auto_Research.on_player_joined_game)
Event.register(defines.events.on_player_joined_game, Auto_Research.on_player_joined_game)
Event.register(defines.events.on_player_left_game, Auto_Research.on_player_left_game)
Event.register(defines.events.on_research_finished, Auto_Research.on_research_finished)
Event.register(defines.events.on_gui_checked_state_changed, Auto_Research.GUI_onClick)
Event.register(defines.events.on_gui_click, Auto_Research.GUI_onClick)
Event.register(defines.events.on_gui_text_changed, function(event)
    if event.element.name ~= "auto_research_search_text" then
        return
    end
    Auto_Research.GUI_updateSearchResult(game.players[event.player_index], event.element.text)
end)

-- GUI Functions --
-- ======================================================= --

-- GUI Function
-- Draws a button in the menubar to toggle the GUI frame on and off
-- @tparam LuaPlayer player current player calling the function
function Auto_Research.draw_menu_btn(player)
    local menubar_button = Auto_Research.get_menu_button(player)
    if menubar_button == nil then
        GUI.add_sprite_button(
            GUI.menu_bar_el(player),
            {
                type = "sprite-button",
                name = Auto_Research.MENU_BTN_NAME,
                sprite = GUI.get_safe_sprite_name(player, Auto_Research.SPRITE_NAMES.menu),
                -- caption = 'Auto_Research.menu_btn_caption',
                tooltip = {"auto_research_gui.menu_btn_tooltip"}
            },
            function(event)
                -- On Click callback function
                Auto_Research.on_gui_click_btn_menu(event)
            end
        )
    end
end

-- GUI Function
-- Creates the main/master frame where all the GUI content will go in
-- @tparam LuaPlayer player current player calling the function
function Auto_Research.draw_master_frame(player)
    local master_frame = Auto_Research.get_master_frame(player)

    if (master_frame == nil) then
        master_frame =
            GUI.master_frame_location_el(player, Auto_Research.MASTER_FRAME_LOCATION).add(
            {
                type = "frame",
                name = Auto_Research.MASTER_FRAME_NAME,
                direction = "vertical",
                caption = {"auto_research_gui.title"}
            }
        )
        GUI.element_apply_style(master_frame, Styles.frm_window)

        Auto_Research.fill_master_frame(master_frame, player)
    end
end

-- GUI Function
-- @tparam LuaGuiElement container parent container to add GUI elements to
-- @tparam LuaPlayer player current player calling the function
function Auto_Research.fill_master_frame(container, player)
    local master_frame = container
    local force = player.force
    local config = Auto_Research.getConfig(force)

    local split_flow =
        master_frame.add {
        type = "flow",
        name = "split_flow",
        direction = "horizontal"
    }

    local frameflow_left =
        split_flow.add {
        type = "flow",
        name = "frameflow_left",
        direction = "vertical"
    }

    local frameflow_right =
        split_flow.add {
        type = "flow",
        name = "frameflow_right",
        direction = "vertical"
    }
    -- GUI.element_apply_style(frameflow, Research_Queue_Styles.auto_research_list_flow)

    -- === Left Panel === --

    -- checkboxes
    frameflow_left.add {
        type = "checkbox",
        name = "auto_research_enabled",
        caption = {"auto_research_gui.enabled"},
        tooltip = {"auto_research_gui.enabled_tooltip"},
        state = config.enabled or false
    }
    frameflow_left.add {
        type = "checkbox",
        name = "auto_research_queued_only",
        caption = {"auto_research_gui.prioritized_only"},
        tooltip = {"auto_research_gui.prioritized_only_tooltip"},
        state = config.prioritized_only or false
    }
    frameflow_left.add {
        type = "checkbox",
        name = "auto_research_allow_switching",
        caption = {"auto_research_gui.allow_switching"},
        tooltip = {"auto_research_gui.allow_switching_tooltip"},
        state = config.allow_switching or false
    }
    frameflow_left.add {
        type = "checkbox",
        name = "auto_research_announce_completed",
        caption = {"auto_research_gui.announce_completed"},
        tooltip = {"auto_research_gui.announce_completed_tooltip"},
        state = config.announce_completed or false
    }
    frameflow_left.add {
        type = "checkbox",
        name = "auto_research_deprioritize_infinite_tech",
        caption = {"auto_research_gui.deprioritize_infinite_tech"},
        tooltip = {"auto_research_gui.deprioritize_infinite_tech_tooltip"},
        state = config.deprioritize_infinite_tech or false
    }

    -- Research strategy
    local lbl_research_strategy =
        frameflow_left.add {
        type = "label",
        caption = {"auto_research_gui.research_strategy"}
    }
    GUI.element_apply_style(lbl_research_strategy, Research_Queue_Styles.auto_research_header_label)

    local research_strategies_one =
        frameflow_left.add {
        type = "flow",
        name = "research_strategies_one",
        direction = "horizontal"
    }
    -- GUI.element_apply_style(research_strategies_one, Research_Queue_Styles.auto_research_tech_flow)
    research_strategies_one.add(
        {
            type = "radiobutton",
            name = "auto_research_research_fast",
            caption = {"auto_research_gui.research_fast"},
            tooltip = {"auto_research_gui.research_fast_tooltip"},
            state = config.research_strategy == "fast"
        }
    )
    research_strategies_one.add(
            {
                type = "radiobutton",
                name = "auto_research_research_cheap",
                caption = {"auto_research_gui.research_cheap"},
                tooltip = {"auto_research_gui.research_cheap_tooltip"},
                state = config.research_strategy == "cheap"
            }
        ).style.left_padding = 15
    research_strategies_one.add(
            {
                type = "radiobutton",
                name = "auto_research_research_balanced",
                caption = {"auto_research_gui.research_balanced"},
                tooltip = {"auto_research_gui.research_balanced_tooltip"},
                state = config.research_strategy == "balanced"
            }
        ).style.left_padding = 15

    local research_strategies_two =
        frameflow_left.add {
        type = "flow",
        name = "research_strategies_two",
        direction = "horizontal"
    }
    -- GUI.element_apply_style(research_strategies_one, Research_Queue_Styles.auto_research_tech_flow)
    research_strategies_two.add(
        {
            type = "radiobutton",
            name = "auto_research_research_slow",
            caption = {"auto_research_gui.research_slow"},
            tooltip = {"auto_research_gui.research_slow_tooltip"},
            state = config.research_strategy == "slow"
        }
    )
    research_strategies_two.add(
            {
                type = "radiobutton",
                name = "auto_research_research_expensive",
                caption = {"auto_research_gui.research_expensive"},
                tooltip = {"auto_research_gui.research_expensive_tooltip"},
                state = config.research_strategy == "expensive"
            }
        ).style.left_padding = 15
    research_strategies_two.add(
            {
                type = "radiobutton",
                name = "auto_research_research_random",
                caption = {"auto_research_gui.research_random"},
                tooltip = {"auto_research_gui.research_random_tooltip"},
                state = config.research_strategy == "random"
            }
        ).style.left_padding = 15

    -- Allowed ingredients
    local lbl_allowed_ingredients =
        frameflow_left.add {
        type = "label",
        caption = {"auto_research_gui.allowed_ingredients_label"}
    }
    GUI.element_apply_style(lbl_allowed_ingredients, Research_Queue_Styles.auto_research_header_label)

    local allowed_ingredients =
        frameflow_left.add {
        type = "flow",
        name = "allowed_ingredients",
        direction = "vertical"
    }
    -- GUI.element_apply_style(allowed_ingredients, Research_Queue_Styles.auto_research_list_flow)

    Auto_Research.GUI_updateAllowedIngredientsList(allowed_ingredients, player, config)


    -- === Right Panel === --

    -- Search for techs
    local searchflow =
        frameflow_right.add {
        type = "flow",
        name = "searchflow",
        direction = "horizontal"
    }
    -- GUI.element_apply_style(searchflow, Research_Queue_Styles.auto_research_tech_flow)
    local lbl_searchflow =
        searchflow.add {
        type = "label",
        caption = {"auto_research_gui.search_label"}
    }
    GUI.element_apply_style(lbl_searchflow, Research_Queue_Styles.auto_research_header_label)
    searchflow.add {
        type = "textfield",
        name = "auto_research_search_text",
        tooltip = {"auto_research_gui.search_tooltip"}
    }
    local searchoptionsflow =
        frameflow_right.add {
        type = "flow",
        name = "searchoptionsflow",
        direction = "horizontal"
    }
    -- GUI.element_apply_style(searchoptionsflow, Research_Queue_Styles.auto_research_tech_flow)
    searchoptionsflow.add {
        type = "checkbox",
        name = "auto_research_ingredients_filter_search_results",
        caption = {"auto_research_gui.ingredients_filter_search_results"},
        tooltip = {"auto_research_gui.ingredients_filter_search_results_tooltip"},
        state = config.filter_search_results or false
    }
    local search =
        frameflow_right.add {
        type = "scroll-pane",
        name = "search",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "auto"
    }
    GUI.element_apply_style(search, Research_Queue_Styles.scroll_pane)
    -- draw search result list
    Auto_Research.GUI_updateSearchResult(player, "")

    -- Queued/Prioritized techs
    local lbl_queued_techs =
        frameflow_right.add {
        type = "label",
        caption = {"auto_research_gui.prioritized_label"}
    }
    GUI.element_apply_style(lbl_queued_techs, Research_Queue_Styles.auto_research_header_label)
    local prioritized =
        frameflow_right.add {
        type = "scroll-pane",
        name = "prioritized",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "auto"
    }
    GUI.element_apply_style(prioritized, Research_Queue_Styles.scroll_pane)
    -- Draw prioritized tech list
    Auto_Research.GUI_updateTechnologyList(prioritized, config.prioritized_techs, player, true)

    -- Blacklisted/Deprioritized techs
    local lbl_blacklisted_techs =
        frameflow_right.add {
        type = "label",
        caption = {"auto_research_gui.deprioritized_label"}
    }
    GUI.element_apply_style(lbl_blacklisted_techs, Research_Queue_Styles.auto_research_header_label)
    local deprioritized =
        frameflow_right.add {
        type = "scroll-pane",
        name = "deprioritized",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "auto"
    }
    GUI.element_apply_style(deprioritized, Research_Queue_Styles.scroll_pane)
    -- Draw deprioritized tech list
    Auto_Research.GUI_updateTechnologyList(deprioritized, config.deprioritized_techs, player)

end

-- GUI Function
function Auto_Research.GUI_updateAllowedIngredientsList(flow, player, config)
    local counter = 1
    while flow["flow" .. counter] do
        flow["flow" .. counter].destroy()
        counter = counter + 1
    end
    counter = 1
    for ingredientname, allowed in pairs(config.allowed_ingredients) do
        local flowname = "flow" .. math.floor(counter / 10) + 1 -- 10 entries per "row"
        local ingredientflow = flow[flowname]
        if not ingredientflow then
            ingredientflow =
                flow.add {
                type = "flow",
                name = flowname,
                direction = "horizontal"
            }
        -- GUI.element_apply_style(ingredientflow, Research_Queue_Styles.auto_research_tech_flow)
        end

        -- Hack a background with image frame since you cant set one on a button....
        local button_frame = ingredientflow.add({type = "frame"})
        GUI.element_apply_style(button_frame, Research_Queue_Styles.button_outer_frame)
        if (allowed) then
            button_frame.style = "image_frame"
        end

        -- Make sprite button
        local sprite = GUI.get_safe_sprite_name(player, "item/" .. ingredientname)
        local button =
            button_frame.add(
            {
                type = "sprite-button",
                name = "auto_research_allow_ingredient-" .. ingredientname,
                tooltip = {"item-name." .. ingredientname},
                sprite = sprite
            }
        )
        GUI.element_apply_style(
            button,
            Research_Queue_Styles["auto_research_sprite_button_toggle" .. (allowed and "_pressed" or "")]
        )
        counter = counter + 1
    end
end

-- GUI Function
function Auto_Research.GUI_updateTechnologyList(scrollpane, technologies, player, show_queue_buttons)
    if scrollpane.flow then
        scrollpane.flow.destroy()
    end
    local flow =
        scrollpane.add {
        type = "flow",
        name = "flow",
        direction = "vertical"
    }
    -- GUI.element_apply_style(flow, Research_Queue_Styles.auto_research_tech_flow)

    --  used to store element to be able to set custom style
    local temp_var_for_el_style

    if #technologies > 0 then
        for _, techname in pairs(technologies) do
            local tech = player.force.technologies[techname]
            if tech then
                local entryflow = flow.add {type = "flow", direction = "horizontal"}
                -- GUI.element_apply_style(entryflow, Research_Queue_Styles.auto_research_tech_flow)
                if show_queue_buttons then
                    temp_var_for_el_style =
                        entryflow.add {
                        type = "sprite-button",
                        name = "auto_research_queue_top-" .. techname,
                        caption = Auto_Research.TEXT_SYMBOLS.up,
                        -- sprite = GUI.get_safe_sprite_name(player, Auto_Research.SPRITE_NAMES.up),
                        tooltip = 'Move to beginning of Queue'
                    }
                    GUI.element_apply_style(temp_var_for_el_style, Research_Queue_Styles.auto_research_sprite_button)
                    GUI.element_apply_style(temp_var_for_el_style, Styles.txt_clr_blue)
                    temp_var_for_el_style =
                        entryflow.add {
                        type = "sprite-button",
                        name = "auto_research_queue_bottom-" .. techname,
                        caption = Auto_Research.TEXT_SYMBOLS.down,
                        -- sprite = GUI.get_safe_sprite_name(player, Auto_Research.SPRITE_NAMES.down),
                        tooltip = 'Move to end of Queue'
                    }
                    GUI.element_apply_style(temp_var_for_el_style, Research_Queue_Styles.auto_research_sprite_button)
                    GUI.element_apply_style(temp_var_for_el_style, Styles.txt_clr_blue)
                end
                temp_var_for_el_style =
                    entryflow.add {
                    type = "sprite-button",
                    name = "auto_research_delete-" .. techname,
                    caption = Auto_Research.TEXT_SYMBOLS.remove,
                    -- sprite = GUI.get_safe_sprite_name(player, Auto_Research.SPRITE_NAMES.remove),
                    tooltip = 'Remove'
                }
                GUI.element_apply_style(temp_var_for_el_style, Research_Queue_Styles.auto_research_sprite_button)
                GUI.element_apply_style(temp_var_for_el_style, Styles.txt_clr_red)

                -- Tech icon
                local sprite = GUI.get_safe_sprite_name(player, Auto_Research.SPRITE_NAMES.tech_prefix .. techname)
                temp_var_for_el_style = entryflow.add {type = "sprite", sprite = sprite}
                GUI.element_apply_style(temp_var_for_el_style, Research_Queue_Styles.auto_research_sprite)

                -- Research text name
                temp_var_for_el_style = entryflow.add {type = "label", caption = tech.localised_name}
                GUI.element_apply_style(temp_var_for_el_style, Research_Queue_Styles.auto_research_tech_label)

                -- Research science req (pots)
                for _, ingredient in pairs(tech.research_unit_ingredients) do
                    local sprite = GUI.get_safe_sprite_name(player, Auto_Research.SPRITE_NAMES.item_prefix .. ingredient.name)
                    temp_var_for_el_style = entryflow.add {type = "sprite", sprite = sprite}
                    GUI.element_apply_style(temp_var_for_el_style, Research_Queue_Styles.auto_research_sprite)
                end
            end
        end
    else
        local entryflow = flow.add {type = "flow", direction = "horizontal"}
        entryflow.add {type = "label", caption = {"auto_research_gui.none"}}
    end
end

--GUI Function
function Auto_Research.GUI_updateSearchResult(player, text)
    --  used to store element to be able to set custom style
    local temp_var_for_el_style

    local scrollpane = Auto_Research.get_master_frame(player).split_flow.frameflow_right.search
    if scrollpane.flow then
        scrollpane.flow.destroy()
    end
    local flow =
        scrollpane.add {
        type = "flow",
        name = "flow",
        direction = "vertical"
    }
    -- GUI.element_apply_style(flow, Research_Queue_Styles.auto_research_list_flow)

    local ingredients_filter =
    Auto_Research.get_master_frame(player).split_flow.frameflow_right.searchoptionsflow.auto_research_ingredients_filter_search_results.state
    ingredients_filter = (ingredients_filter == nil or ingredients_filter)
    local config = Auto_Research.getConfig(player.force)
    local shown = 0
    text = string.lower(text)
    -- NOTICE: localised name matching does not work at present, pending unlikely changes to Factorio API
    for name, tech in pairs(player.force.technologies) do
        if not tech.researched and tech.enabled then
            local showtech = false
            if string.find(string.lower(name), text, 1, true) then
                -- elseif string.find(string.lower(game.technology_prototypes[name].localised_name), text, 1, true) then
                --     -- show techs that match by localised name
                --     showtech = true
                -- show techs that match by name
                showtech = true
            else
                for _, effect in pairs(tech.effects) do
                    if string.find(effect.type, text, 1, true) then
                        -- show techs that match by effect type
                        showtech = true
                    elseif effect.type == "unlock-recipe" then
                        if string.find(effect.recipe, text, 1, true) then
                            -- elseif string.find(string.lower(game.recipe_prototypes[effect.recipe].localised_name), text, 1, true) then
                            --     -- show techs that match by unlocked recipe localised name
                            --     showtech = true
                            -- show techs that match by unlocked recipe name
                            showtech = true
                        else
                            for _, product in pairs(game.recipe_prototypes[effect.recipe].products) do
                                if string.find(product.name, text, 1, true) then
                                    -- elseif string.find(string.lower(game.item_prototypes[product.name].localised_name), text, 1, true) then
                                    --     -- show techs that match by unlocked recipe product localised name
                                    --     showtech = true
                                    -- show techs that match by unlocked recipe product name
                                    showtech = true
                                else
                                    local prototype = game.item_prototypes[product.name]
                                    if prototype then
                                        if prototype.place_result then
                                            if string.find(prototype.place_result.name, text, 1, true) then
                                                -- show techs that match by unlocked recipe product placed entity name
                                                showtech = true
                                            -- elseif string.find(string.lower(game.entity_prototypes[prototype.place_result.name].localised_name), text, 1, true) then
                                            --     -- show techs that match by unlocked recipe product placed entity localised name
                                            --     showtech = true
                                            end
                                        elseif prototype.place_as_equipment_result then
                                            if string.find(prototype.place_as_equipment_result.name, text, 1, true) then
                                                -- show techs that match by unlocked recipe product placed equipment name
                                                showtech = true
                                            -- elseif string.find(string.lower(game.equipment_prototypes[prototype.place_as_equipment_result.name].localised_name), text, 1, true) then
                                            --     -- show techs that match by unlocked recipe product placed equipment localised name
                                            --     showtech = true
                                            end
                                        elseif prototype.place_as_tile_result then
                                            if string.find(prototype.place_as_tile_result.result.name, text, 1, true) then
                                                -- show techs that match by unlocked recipe product placed tile name
                                                showtech = true
                                            -- elseif string.find(string.lower(prototype.place_as_tile_result.result.localised_name), text, 1, true) then
                                            --     -- show techs that match by unlocked recipe product placed tile localised name
                                            --     showtech = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if showtech and config.prioritized_techs then
                for _, queued_tech in pairs(config.prioritized_techs) do
                    if name == queued_tech then
                        showtech = false
                        break
                    end
                end
            end
            if showtech and config.deprioritized_techs then
                for _, blacklisted_tech in pairs(config.deprioritized_techs) do
                    if name == blacklisted_tech then
                        showtech = false
                        break
                    end
                end
            end
            if showtech and ingredients_filter then
                for _, ingredient in pairs(tech.research_unit_ingredients) do
                    if not config.allowed_ingredients[ingredient.name] then
                        -- filter out techs that require disallowed ingredients (optional)
                        showtech = false
                    end
                end
            end
            if showtech then
                shown = shown + 1
                local entryflow = flow.add {type = "flow", direction = "horizontal"}
                -- GUI.element_apply_style(entryflow, Research_Queue_Styles.auto_research_tech_flow)
                temp_var_for_el_style =
                    entryflow.add {
                    type = "sprite-button",
                    name = "auto_research_queue_top-" .. name,
                    caption = Auto_Research.TEXT_SYMBOLS.up,
                    -- sprite = GUI.get_safe_sprite_name(player, Auto_Research.SPRITE_NAMES.up),
                    tooltip = 'Move to beginning of Queue'
                }
                GUI.element_apply_style(temp_var_for_el_style, Research_Queue_Styles.auto_research_sprite_button)
                GUI.element_apply_style(temp_var_for_el_style, Styles.txt_clr_blue)
                temp_var_for_el_style =
                    entryflow.add {
                    type = "sprite-button",
                    name = "auto_research_queue_bottom-" .. name,
                    caption = Auto_Research.TEXT_SYMBOLS.down,
                    -- sprite = GUI.get_safe_sprite_name(player, Auto_Research.SPRITE_NAMES.down),
                    tooltip = 'Move to end of Queue'
                }
                GUI.element_apply_style(temp_var_for_el_style, Research_Queue_Styles.auto_research_sprite_button)
                GUI.element_apply_style(temp_var_for_el_style, Styles.txt_clr_blue)
                temp_var_for_el_style =
                    entryflow.add {
                    type = "sprite-button",
                    name = "auto_research_blacklist-" .. name,
                    caption = Auto_Research.TEXT_SYMBOLS.blacklist,
                    -- sprite = GUI.get_safe_sprite_name(player, Auto_Research.SPRITE_NAMES.blacklist),
                    tooltip = 'Blacklist'
                }
                GUI.element_apply_style(temp_var_for_el_style, Research_Queue_Styles.auto_research_sprite_button)
                GUI.element_apply_style(temp_var_for_el_style, Styles.txt_clr_red)

                -- Tech icon
                local sprite = GUI.get_safe_sprite_name(player, Auto_Research.SPRITE_NAMES.tech_prefix .. name)
                temp_var_for_el_style = entryflow.add {type = "sprite", sprite = sprite}
                GUI.element_apply_style(temp_var_for_el_style, Research_Queue_Styles.auto_research_sprite)

                -- Research text name
                temp_var_for_el_style = entryflow.add {type = "label", name = name, caption = tech.localised_name}
                GUI.element_apply_style(temp_var_for_el_style, Research_Queue_Styles.auto_research_tech_label)

                -- Research science req (pots)
                for _, ingredient in pairs(tech.research_unit_ingredients) do
                    local sprite = GUI.get_safe_sprite_name(player, "item/" .. ingredient.name)
                    temp_var_for_el_style = entryflow.add({type = "sprite", sprite = sprite})
                    GUI.element_apply_style(temp_var_for_el_style, Research_Queue_Styles.auto_research_sprite)
                end
            end
        end
    end
end

-- Logic Functions --
-- ======================================================= --

--
-- @tparam LuaForce force
function Auto_Research.setDefaultConfig(force)
    local config = Auto_Research.getConfig(force)
    if(not config.initialized) then
        local queued_tech = Auto_Research.default_queued_techs
        local blacklisted_tech = Auto_Research.default_blacklisted_techs
        local allowed_research_ingredients = Auto_Research.default_allowed_research_ingredients

        -- set any default queued techs
        for i, tech in pairs(queued_tech) do
            if force.technologies[tech] and force.technologies[tech].enabled and not force.technologies[tech].researched then
                table.insert(config.prioritized_techs, tech)
            end
        end

        -- set any default blacklisted techs
        for i, tech in pairs(blacklisted_tech) do
            if force.technologies[tech] and force.technologies[tech].enabled and not force.technologies[tech].researched then
                table.insert(config.deprioritized_techs, tech)
            end
        end

        -- set any default allowed research ingredients, false otherwise
        for name, enabled in pairs(config.allowed_ingredients) do
            if(allowed_research_ingredients[name])then
                config.allowed_ingredients[name] = allowed_research_ingredients[name]
            else
                config.allowed_ingredients[name] = false
            end
        end
        config.initialized = true
    end
end

--
-- @tparam LuaForce force
-- @tparam boolean config_changed
function Auto_Research.getConfig(force, config_changed)
    if not global.auto_research_config then
        global.auto_research_config = {}

        -- Disable Research Queue popup
        if remote.interfaces.RQ and remote.interfaces.RQ["popup"] then
            remote.call("RQ", "popup", false)
        end
    end

    if not global.auto_research_config[force.name] then
        global.auto_research_config[force.name] = {
            prioritized_techs = {}, -- "prioritized" is "queued".
            deprioritized_techs = {}, -- "deprioritized" is "blacklisted".
            filter_search_results = true,
        }
        -- Enable Auto Research
        Auto_Research.setAutoResearch(force, true)

        -- Disable queued only
        Auto_Research.setQueuedOnly(force, true)

        -- Allow switching research
        Auto_Research.setAllowSwitching(force, true)

        -- Print researched technology
        Auto_Research.setAnnounceCompletedResearch(force, true)

        -- Focus on finite research
        Auto_Research.setDeprioritizeInfiniteTech(force, true)
    end

    -- set research strategy
    global.auto_research_config[force.name].research_strategy = global.auto_research_config[force.name].research_strategy or "balanced"

    if config_changed or not global.auto_research_config[force.name].allowed_ingredients or not global.auto_research_config[force.name].infinite_research then
        -- remember any old ingredients
        local old_ingredients = {}
        if global.auto_research_config[force.name].allowed_ingredients then
            for name, enabled in pairs(global.auto_research_config[force.name].allowed_ingredients) do
                old_ingredients[name] = enabled
            end
        end
        -- find all possible tech ingredients
        -- also scan for research that are infinite: techs that have no successor and tech.research_unit_count_formula is not nil
        global.auto_research_config[force.name].allowed_ingredients = {}
        global.auto_research_config[force.name].infinite_research = {}
        local finite_research = {}
        for _, tech in pairs(force.technologies) do
            for _, ingredient in pairs(tech.research_unit_ingredients) do
                global.auto_research_config[force.name].allowed_ingredients[ingredient.name] = (old_ingredients[ingredient.name] == nil or old_ingredients[ingredient.name])
            end
            if tech.research_unit_count_formula then
                global.auto_research_config[force.name].infinite_research[tech.name] = tech
            end
            for _, pretech in pairs(tech.prerequisites) do
                if pretech.enabled and not pretech.researched then
                    finite_research[pretech.name] = true
                end
            end
        end
        for techname, _ in pairs(finite_research) do
            global.auto_research_config[force.name].infinite_research[techname] = nil
        end
    end

    return global.auto_research_config[force.name]
end

function Auto_Research.setAutoResearch(force, enabled)
    if not force then
        return
    end
    local config = Auto_Research.getConfig(force)
    config.enabled = enabled

    -- start new research
    Auto_Research.startNextResearch(force)
end

function Auto_Research.setQueuedOnly(force, enabled)
    if not force then
        return
    end
    Auto_Research.getConfig(force).prioritized_only = enabled

    -- start new research
    Auto_Research.startNextResearch(force)
end

function Auto_Research.setAllowSwitching(force, enabled)
    if not force then
        return
    end
    Auto_Research.getConfig(force).allow_switching = enabled

    -- start new research
    Auto_Research.startNextResearch(force)
end

function Auto_Research.setAnnounceCompletedResearch(force, enabled)
    if not force then
        return
    end
    Auto_Research.getConfig(force).announce_completed = enabled
end

function Auto_Research.setDeprioritizeInfiniteTech(force, enabled)
    if not force then
        return
    end
    Auto_Research.getConfig(force).deprioritize_infinite_tech = enabled

    -- start new research
    Auto_Research.startNextResearch(force)
end

function Auto_Research.getPretechs(tech)
    local pretechs = {}
    pretechs[#pretechs + 1] = tech
    local index = 1
    while (index <= #pretechs) do
        for _, pretech in pairs(pretechs[index].prerequisites) do
            if pretech.enabled and not pretech.researched then
                pretechs[#pretechs + 1]  = pretech
            end
        end
        index = index + 1
    end
    return pretechs
end

function Auto_Research.canResearch(force, tech, config)
    if not tech or tech.researched or not tech.enabled then
        return false
    end
    for _, pretech in pairs(tech.prerequisites) do
        if not pretech.researched then
            return false
        end
    end
    for _, ingredient in pairs(tech.research_unit_ingredients) do
        if not config.allowed_ingredients[ingredient.name] then
            return false
        end
    end
    for _, deprioritized in pairs(config.deprioritized_techs) do
        if tech.name == deprioritized then
            return false
        end
    end
    return true
end

function Auto_Research.startNextResearch(force, override_spam_detection)
    local config = Auto_Research.getConfig(force)
    if not config.enabled or (force.current_research and not config.allow_switching) or (not override_spam_detection and config.last_research_finish_tick == game.tick) then
        return
    end
    config.last_research_finish_tick = game.tick -- if multiple research finish same tick for same force, the user probably enabled all techs

    -- function for calculating tech effort
    local calcEffort = function(tech)
        local ingredientCount = function(ingredients)
            local tech_ingredients = 0
            for _, ingredient in pairs(tech.research_unit_ingredients) do
                tech_ingredients = tech_ingredients + ingredient.amount
            end
            return tech_ingredients
        end
        local effort = 0
        if config.research_strategy == "fast" then
            effort = math.max(tech.research_unit_energy, 1) * math.max(tech.research_unit_count, 1)
        elseif config.research_strategy == "slow" then
            effort = math.max(tech.research_unit_energy, 1) * math.max(tech.research_unit_count, 1) * -1
        elseif config.research_strategy == "cheap" then
            effort = math.max(ingredientCount(tech.research_unit_ingredients), 1) * math.max(tech.research_unit_count, 1)
        elseif config.research_strategy == "expensive" then
            effort = math.max(ingredientCount(tech.research_unit_ingredients), 1) * math.max(tech.research_unit_count, 1) * -1
        elseif config.research_strategy == "balanced" then
            effort = math.max(tech.research_unit_count, 1) * math.max(tech.research_unit_energy, 1) * math.max(ingredientCount(tech.research_unit_ingredients), 1)
        else
            effort = math.random(1, 999)
        end
        if (config.deprioritize_infinite_tech and config.infinite_research[tech.name]) then
            return effort * (effort > 0 and 1000 or -1000)
        else
            return effort
        end
    end

    -- see if there are some techs we should research first
    local next_research = nil
    local least_effort = nil
    for _, techname in pairs(config.prioritized_techs) do
        local tech = force.technologies[techname]
        if tech and not next_research then
            local pretechs = Auto_Research.getPretechs(tech)
            for _, pretech in pairs(pretechs) do
                local effort = calcEffort(pretech)
                if (not least_effort or effort < least_effort) and Auto_Research.canResearch(force, pretech, config) then
                    next_research = pretech.name
                    least_effort = effort
                end
            end
        end
    end

    -- if no queued tech should be researched then research the "least effort" tech not researched yet
    if not config.prioritized_only and not next_research then
        for techname, tech in pairs(force.technologies) do
            if tech.enabled and not tech.researched then
                local effort = calcEffort(tech)
                if (not least_effort or effort < least_effort) and Auto_Research.canResearch(force, tech, config) then
                    next_research = techname
                    least_effort = effort
                end
            end
        end
    end

    -- v0.16 Intention
    -- force.current_research = next_research

    -- v0.17 Adaptation of the above
    -- We overwrite what ever the game has in the queue with the next tech from this custom queue
    if(next_research) then
        force.research_queue = nil;
        -- force.cancel_current_research();
        force.add_research(next_research);
    end
end


-- Disable the default recearch qeue that ships with the game and use ours instead
function Auto_Research.disableDefaultGameQueue(force)
    force.research_queue_enabled = false;
end
