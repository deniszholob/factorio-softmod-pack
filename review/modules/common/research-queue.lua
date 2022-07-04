-- __NAME__ Soft Module
-- __Description__
-- Uses locale __modulename__.cfg
-- @usage require('modules/__folder__/__modulename__')
-- @usage local ModuleName = require('modules/__folder__/__modulename__')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local mod_gui = require("mod-gui") -- From `Factorio\data\core\lualib`
local GUI = require("stdlib/GUI")

-- Constants --
-- ======================================================= --
local ResearchQueue = {}
local MENU_BTN_NAME = 'btn_menu_auto-research'
local MASTER_FRAME_NAME = 'frame_auto-research'

-- queue
-- Event Functions --
-- ======================================================= --
-- When new player joins add a btn to their button_flow
-- Redraw this softmod's frame
-- @param event on_player_joined_game
function ResearchQueue.on_player_joined(event)
    local player = game.players[event.player_index]
    local config = ResearchQueue.getConfig(player.force) -- triggers initialization of force config
    ResearchQueue.startNextResearch(player.force, true)
    ResearchQueue.draw_menu_btn(player)
    -- draw_master_frame(player) -- dont draw yet, when btn clicked instead
end

-- When a player leaves clean up their GUI in case this mod gets removed next time
-- @param event on_player_left_game
function ResearchQueue.on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(mod_gui.get_button_flow(player)[MENU_BTN_NAME])
    GUI.destroy_element(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME])
end

-- Toggle gameinfo is called if gui element is gameinfo button
-- @param event on_gui_click
function ResearchQueue.on_gui_click(event)
    local player = game.players[event.player_index]
    local el_name = event.element.name

    if el_name == MENU_BTN_NAME then
        -- Call toggle if frame has been created
        if(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME] ~= nil) then
            GUI.toggle_element(mod_gui.get_frame_flow(player)[MASTER_FRAME_NAME])
        else -- Call create if it hasnt
            draw_gameinfo_frame(player)
        end
    else
        gui.onClick(event)
    end
end

--
-- @param event on_force_created event
function ResearchQueue.on_force_created(event)
    ResearchQueue.getConfig(event.force) -- triggers initialization of force config
end

function ResearchQueue.on_research_finished(event)
    local force = event.research.force
    local config = ResearchQueue.getConfig(force)
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

    ResearchQueue.startNextResearch(event.research.force)
end

--
-- @param event on_gui_checked_state_changed event
function ResearchQueue.on_gui_checked_state_changed(event)

end

--
-- @param event on_gui_text_changed event
function ResearchQueue.on_gui_text_changed(event)

end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_force_created, ResearchQueue.on_force_created)
Event.register(defines.events.on_research_finished, ResearchQueue.on_research_finished)
Event.register(defines.events.on_gui_checked_state_changed, ResearchQueue.on_gui_checked_state_changed)
Event.register(defines.events.on_gui_click, ResearchQueue.on_gui_click)
Event.register(defines.events.on_gui_text_changed, ResearchQueue.on_gui_text_changed)



script.on_event(defines.events.on_gui_checked_state_changed, gui.onClick)
script.on_event(defines.events.on_gui_click, gui.onClick)
script.on_event(defines.events.on_gui_text_changed, function(event)
    if event.element.name ~= "auto_research_search_text" then
        return
    end
    gui.updateSearchResult(game.players[event.player_index], event.element.text)
end)

-- Helper Functions --
-- ======================================================= --

--
-- @param player LuaPlayer
function ResearchQueue.draw_menu_btn(player)
    if mod_gui.get_button_flow(player)[MENU_BTN_NAME] == nil then
        mod_gui.get_button_flow(player).add(
            {
                type = "sprite-button",
                name = MENU_BTN_NAME,
                sprite = "item/lab",
                -- caption = 'Auto Infinite Research',
                tooltip = "Research Queue"
            }
        )
    end
end

















function ResearchQueue.getConfig(force, config_changed)
    if not global.auto_research_config then
        global.auto_research_config = {}

        -- Disable Research Queue popup
        if remote.interfaces.RQ and remote.interfaces.RQ["popup"] then
            remote.call("RQ", "popup", false)
        end
    end

    if not global.auto_research_config[force.name] then
        global.auto_research_config[force.name] = {
            prioritized_techs = {}, -- "prioritized" is "queued". kept for backwards compatability (because i'm lazy and don't want migration code)
            deprioritized_techs = {} -- "deprioritized" is "blacklisted". kept for backwards compatability (because i'm lazy and don't want migration code)
        }
        -- Enable Auto Research
        ResearchQueue.setAutoResearch(force, true)

        -- Disable queued only
        ResearchQueue.setQueuedOnly(force, false)

        -- Allow switching research
        ResearchQueue.setAllowSwitching(force, true)

        -- Print researched technology
        ResearchQueue.setAnnounceCompletedResearch(force, true)
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

function ResearchQueue.setAutoResearch(force, enabled)
    if not force then
        return
    end
    local config = ResearchQueue.getConfig(force)
    config.enabled = enabled

    -- start new research
    ResearchQueue.startNextResearch(force)
end

function ResearchQueue.setQueuedOnly(force, enabled)
    if not force then
        return
    end
    ResearchQueue.getConfig(force).prioritized_only = enabled

    -- start new research
    ResearchQueue.startNextResearch(force)
end

function ResearchQueue.setAllowSwitching(force, enabled)
    if not force then
        return
    end
    ResearchQueue.getConfig(force).allow_switching = enabled

    -- start new research
    ResearchQueue.startNextResearch(force)
end

function ResearchQueue.setAnnounceCompletedResearch(force, enabled)
    if not force then
        return
    end
    ResearchQueue.getConfig(force).announce_completed = enabled
end

function ResearchQueue.setDeprioritizeInfiniteTech(force, enabled)
    if not force then
        return
    end
    ResearchQueue.getConfig(force).deprioritize_infinite_tech = enabled

    -- start new research
    ResearchQueue.startNextResearch(force)
end

function ResearchQueue.getPretechs(tech)
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

function ResearchQueue.canResearch(force, tech, config)
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

function ResearchQueue.startNextResearch(force, override_spam_detection)
    local config = ResearchQueue.getConfig(force)
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
            local pretechs = ResearchQueue.getPretechs(tech)
            for _, pretech in pairs(pretechs) do
                local effort = calcEffort(pretech)
                if (not least_effort or effort < least_effort) and ResearchQueue.canResearch(force, pretech, config) then
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
                if (not least_effort or effort < least_effort) and ResearchQueue.canResearch(force, tech, config) then
                    next_research = techname
                    least_effort = effort
                end
            end
        end
    end

    force.current_research = next_research
end

-- user interface
gui = {
    toggleGui = function(player)
        if player.gui.top.auto_research_gui then
            player.gui.top.auto_research_gui.destroy()
        else
            local force = player.force
            local config = ResearchQueue.getConfig(force)
            local frame = player.gui.top.add{
                type = "frame",
                name = "auto_research_gui",
                direction = "vertical",
                caption = {"auto_research_gui.title"}
            }
            local frameflow = frame.add{
                type = "flow",
                style = "auto_research_list_flow",
                name = "flow",
                direction = "vertical"
            }

            -- checkboxes
            frameflow.add{type = "checkbox", name = "auto_research_enabled", caption = {"auto_research_gui.enabled"}, tooltip = {"auto_research_gui.enabled_tooltip"}, state = config.enabled or false}
            frameflow.add{type = "checkbox", name = "auto_research_queued_only", caption = {"auto_research_gui.prioritized_only"}, tooltip = {"auto_research_gui.prioritized_only_tooltip"}, state = config.prioritized_only or false}
            frameflow.add{type = "checkbox", name = "auto_research_allow_switching", caption = {"auto_research_gui.allow_switching"}, tooltip = {"auto_research_gui.allow_switching_tooltip"}, state = config.allow_switching or false}
            frameflow.add{type = "checkbox", name = "auto_research_announce_completed", caption = {"auto_research_gui.announce_completed"}, tooltip = {"auto_research_gui.announce_completed_tooltip"}, state = config.announce_completed or false}
            frameflow.add{type = "checkbox", name = "auto_research_deprioritize_infinite_tech", caption = {"auto_research_gui.deprioritize_infinite_tech"}, tooltip = {"auto_research_gui.deprioritize_infinite_tech_tooltip"}, state = config.deprioritize_infinite_tech or false}

            -- research strategy
            frameflow.add{
                type = "label",
                style = "auto_research_header_label",
                caption = {"auto_research_gui.research_strategy"}
            }
            local research_strategies_one = frameflow.add{
                type = "flow",
                style = "auto_research_tech_flow",
                name = "research_strategies_one",
                direction = "horizontal"
            }
            research_strategies_one.add{type = "radiobutton", name = "auto_research_research_fast", caption = {"auto_research_gui.research_fast"}, tooltip = {"auto_research_gui.research_fast_tooltip"}, state = config.research_strategy == "fast"}
            research_strategies_one.add({type = "radiobutton", name = "auto_research_research_cheap", caption = {"auto_research_gui.research_cheap"}, tooltip = {"auto_research_gui.research_cheap_tooltip"}, state = config.research_strategy == "cheap"}).style.left_padding = 15
            research_strategies_one.add({type = "radiobutton", name = "auto_research_research_balanced", caption = {"auto_research_gui.research_balanced"}, tooltip = {"auto_research_gui.research_balanced_tooltip"}, state = config.research_strategy == "balanced"}).style.left_padding = 15
            local research_strategies_two = frameflow.add{
                type = "flow",
                style = "auto_research_tech_flow",
                name = "research_strategies_two",
                direction = "horizontal"
            }
            research_strategies_two.add{type = "radiobutton", name = "auto_research_research_slow", caption = {"auto_research_gui.research_slow"}, tooltip = {"auto_research_gui.research_slow_tooltip"}, state = config.research_strategy == "slow"}
            research_strategies_two.add({type = "radiobutton", name = "auto_research_research_expensive", caption = {"auto_research_gui.research_expensive"}, tooltip = {"auto_research_gui.research_expensive_tooltip"}, state = config.research_strategy == "expensive"}).style.left_padding = 15
            research_strategies_two.add({type = "radiobutton", name = "auto_research_research_random", caption = {"auto_research_gui.research_random"}, tooltip = {"auto_research_gui.research_random_tooltip"}, state = config.research_strategy == "random"}).style.left_padding = 15

            -- allowed ingredients
            frameflow.add{
                type = "label",
                style = "auto_research_header_label",
                caption = {"auto_research_gui.allowed_ingredients_label"}
            }
            local allowed_ingredients = frameflow.add{
                type = "flow",
                style = "auto_research_list_flow",
                name = "allowed_ingredients",
                direction = "vertical"
            }
            gui.updateAllowedIngredientsList(player.gui.top.auto_research_gui.flow.allowed_ingredients, player, config)

            -- prioritized techs
            frameflow.add{
                type = "label",
                style = "auto_research_header_label",
                caption = {"auto_research_gui.prioritized_label"}
            }
            local prioritized = frameflow.add{
                type = "scroll-pane",
                name = "prioritized",
                horizontal_scroll_policy = "never",
                vertical_scroll_policy = "auto"
            }
            prioritized.style.top_padding = 5
            prioritized.style.bottom_padding = 5
            prioritized.style.maximal_height = 127
            -- draw prioritized tech list
            gui.updateTechnologyList(player.gui.top.auto_research_gui.flow.prioritized, config.prioritized_techs, player, true)

            -- deprioritized techs
            frameflow.add{
                type = "label",
                style = "auto_research_header_label",
                caption = {"auto_research_gui.deprioritized_label"}
            }
            local deprioritized = frameflow.add{
                type = "scroll-pane",
                name = "deprioritized",
                horizontal_scroll_policy = "never",
                vertical_scroll_policy = "auto"
            }
            deprioritized.style.top_padding = 5
            deprioritized.style.bottom_padding = 5
            deprioritized.style.maximal_height = 127
            -- draw deprioritized tech list
            gui.updateTechnologyList(player.gui.top.auto_research_gui.flow.deprioritized, config.deprioritized_techs, player)

            -- search for techs
            local searchflow = frameflow.add{
                type = "flow",
                name = "searchflow",
                style = "auto_research_tech_flow",
                direction = "horizontal"
            }
            searchflow.add{
                type = "label",
                style = "auto_research_header_label",
                caption = {"auto_research_gui.search_label"}
            }
            searchflow.add{
                type = "textfield",
                name = "auto_research_search_text",
                tooltip = {"auto_research_gui.search_tooltip"}
            }
            local searchoptionsflow = frameflow.add{
                type = "flow",
                name = "searchoptionsflow",
                style = "auto_research_tech_flow",
                direction = "horizontal"
            }
            searchoptionsflow.add{
                type = "checkbox",
                name = "auto_research_ingredients_filter_search_results",
                caption = {"auto_research_gui.ingredients_filter_search_results"},
                tooltip = {"auto_research_gui.ingredients_filter_search_results_tooltip"},
                state = config.filter_search_results or false
            }
            local search = frameflow.add{
                type = "scroll-pane",
                name = "search",
                horizontal_scroll_policy = "never",
                vertical_scroll_policy = "auto"
            }
            search.style.top_padding = 5
            search.style.bottom_padding = 5
            search.style.maximal_height = 127
            -- draw search result list
            gui.updateSearchResult(player, "")
        end
    end,

    onClick = function(event)
        local player = game.players[event.player_index]
        local force = player.force
        local config = ResearchQueue.getConfig(force)
        local name = event.element.name
        if name == "auto_research_enabled" then
            ResearchQueue.setAutoResearch(force, event.element.state)
        elseif name == "auto_research_queued_only" then
            ResearchQueue.setQueuedOnly(force, event.element.state)
        elseif name == "auto_research_allow_switching" then
            ResearchQueue.setAllowSwitching(force, event.element.state)
        elseif name == "auto_research_announce_completed" then
            ResearchQueue.setAnnounceCompletedResearch(force, event.element.state)
        elseif name == "auto_research_deprioritize_infinite_tech" then
            ResearchQueue.setDeprioritizeInfiniteTech(force, event.element.state)
        elseif name == "auto_research_search_text" then
            if event.button == defines.mouse_button_type.right then
                player.gui.top.auto_research_gui.flow.searchflow.auto_research_search_text.text = ""
                gui.updateSearchResult(player, player.gui.top.auto_research_gui.flow.searchflow.auto_research_search_text.text)
            end
        elseif name == "auto_research_ingredients_filter_search_results" then
            config.filter_search_results = event.element.state
            gui.updateSearchResult(player, player.gui.top.auto_research_gui.flow.searchflow.auto_research_search_text.text)
        elseif string.find(name, "auto_research_research") then
            config.research_strategy = string.match(name, "^auto_research_research_(.*)$")
            player.gui.top.auto_research_gui.flow.research_strategies_one.auto_research_research_fast.state = (config.research_strategy == "fast")
            player.gui.top.auto_research_gui.flow.research_strategies_one.auto_research_research_cheap.state = (config.research_strategy == "cheap")
            player.gui.top.auto_research_gui.flow.research_strategies_one.auto_research_research_balanced.state = (config.research_strategy == "balanced")
            player.gui.top.auto_research_gui.flow.research_strategies_two.auto_research_research_slow.state = (config.research_strategy == "slow")
            player.gui.top.auto_research_gui.flow.research_strategies_two.auto_research_research_expensive.state = (config.research_strategy == "expensive")
            player.gui.top.auto_research_gui.flow.research_strategies_two.auto_research_research_random.state = (config.research_strategy == "random")
            -- start new research
            ResearchQueue.startNextResearch(force)
        else
            local prefix, name = string.match(name, "^auto_research_([^-]*)-(.*)$")
            if prefix == "allow_ingredient" then
                config.allowed_ingredients[name] = not config.allowed_ingredients[name]
                gui.updateAllowedIngredientsList(player.gui.top.auto_research_gui.flow.allowed_ingredients, player, config)
                if player.gui.top.auto_research_gui.flow.searchoptionsflow.auto_research_ingredients_filter_search_results.state then
                    gui.updateSearchResult(player, player.gui.top.auto_research_gui.flow.searchflow.auto_research_search_text.text)
                end
                ResearchQueue.startNextResearch(force)
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
                gui.updateTechnologyList(player.gui.top.auto_research_gui.flow.prioritized, config.prioritized_techs, player, true)
                gui.updateTechnologyList(player.gui.top.auto_research_gui.flow.deprioritized, config.deprioritized_techs, player)
                gui.updateSearchResult(player, player.gui.top.auto_research_gui.flow.searchflow.auto_research_search_text.text)

                -- start new research
                ResearchQueue.startNextResearch(force)
            end
        end
    end,

    updateAllowedIngredientsList = function(flow, player, config)
        local counter = 1
        while flow["flow" .. counter] do
            flow["flow" .. counter].destroy()
            counter = counter + 1
        end
        counter = 1
        for ingredientname, allowed in pairs(config.allowed_ingredients) do
            local flowname = "flow" .. math.floor(counter / 10) + 1
            local ingredientflow = flow[flowname]
            if not ingredientflow then
                ingredientflow = flow.add {
                    type = "flow",
                    style = "auto_research_tech_flow",
                    name = flowname,
                    direction = "horizontal"
                }
            end
            local sprite = "auto_research_tool_" .. ingredientname
            if not player.gui.is_valid_sprite_path(sprite) then
                sprite = "auto_research_unknown"
            end
            ingredientflow.add{type = "sprite-button", style = "auto_research_sprite_button_toggle" .. (allowed and "_pressed" or ""), name = "auto_research_allow_ingredient-" .. ingredientname, tooltip = {"item-name." .. ingredientname}, sprite = sprite}
            counter = counter + 1
        end
    end,

    updateTechnologyList = function(scrollpane, technologies, player, show_queue_buttons)
        if scrollpane.flow then
            scrollpane.flow.destroy()
        end
        local flow = scrollpane.add{
            type = "flow",
            style = "auto_research_list_flow",
            name = "flow",
            direction = "vertical"
        }
        if #technologies > 0 then
            for _, techname in pairs(technologies) do
                local tech = player.force.technologies[techname]
                if tech then
                    local entryflow = flow.add{type = "flow", style = "auto_research_tech_flow", direction = "horizontal"}
                    if show_queue_buttons then
                        entryflow.add{type = "sprite-button", style = "auto_research_sprite_button", name = "auto_research_queue_top-" .. techname, sprite = "auto_research_prioritize_top"}
                        entryflow.add{type = "sprite-button", style = "auto_research_sprite_button", name = "auto_research_queue_bottom-" .. techname, sprite = "auto_research_prioritize_bottom"}
                    end
                    entryflow.add{type = "sprite-button", style = "auto_research_sprite_button", name = "auto_research_delete-" .. techname, sprite = "auto_research_delete"}
                    entryflow.add{type = "label", style = "auto_research_tech_label", caption = tech.localised_name}
                    for _, ingredient in pairs(tech.research_unit_ingredients) do
                        local sprite = "auto_research_tool_" .. ingredient.name
                        if not player.gui.is_valid_sprite_path(sprite) then
                            sprite = "auto_research_unknown"
                        end
                        entryflow.add{type = "sprite", style = "auto_research_sprite", sprite = sprite}
                    end
                end
            end
        else
            local entryflow = flow.add{type = "flow", direction = "horizontal"}
            entryflow.add{type = "label", caption = {"auto_research_gui.none"}}
        end
    end,

    updateSearchResult = function(player, text)
        local scrollpane = player.gui.top.auto_research_gui.flow.search
        if scrollpane.flow then
            scrollpane.flow.destroy()
        end
        local flow = scrollpane.add{
            type = "flow",
            style = "auto_research_list_flow",
            name = "flow",
            direction = "vertical"
        }
        local ingredients_filter = player.gui.top.auto_research_gui.flow.searchoptionsflow.auto_research_ingredients_filter_search_results.state
        local config = ResearchQueue.getConfig(player.force)
        local shown = 0
        text = string.lower(text)
        -- NOTICE: localised name matching does not work at present, pending unlikely changes to Factorio API
        for name, tech in pairs(player.force.technologies) do
            if not tech.researched and tech.enabled then
                local showtech = false
                if string.find(string.lower(name), text, 1, true) then
                    -- show techs that match by name
                    showtech = true
                -- elseif string.find(string.lower(game.technology_prototypes[name].localised_name), text, 1, true) then
                --     -- show techs that match by localised name
                --     showtech = true
                else
                    for _, effect in pairs(tech.effects) do
                        if string.find(effect.type, text, 1, true) then
                            -- show techs that match by effect type
                            showtech = true
                        elseif effect.type == "unlock-recipe" then
                            if string.find(effect.recipe, text, 1, true) then
                                -- show techs that match by unlocked recipe name
                                showtech = true
                            -- elseif string.find(string.lower(game.recipe_prototypes[effect.recipe].localised_name), text, 1, true) then
                            --     -- show techs that match by unlocked recipe localised name
                            --     showtech = true
                            else
                                for _, product in pairs(game.recipe_prototypes[effect.recipe].products) do
                                    if string.find(product.name, text, 1, true) then
                                        -- show techs that match by unlocked recipe product name
                                        showtech = true
                                    -- elseif string.find(string.lower(game.item_prototypes[product.name].localised_name), text, 1, true) then
                                    --     -- show techs that match by unlocked recipe product localised name
                                    --     showtech = true
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
                    local entryflow = flow.add{type = "flow", style = "auto_research_tech_flow", direction = "horizontal"}
                    entryflow.add{type = "sprite-button", style = "auto_research_sprite_button", name = "auto_research_queue_top-" .. name, sprite = "auto_research_prioritize_top"}
                    entryflow.add{type = "sprite-button", style = "auto_research_sprite_button", name = "auto_research_queue_bottom-" .. name, sprite = "auto_research_prioritize_bottom"}
                    entryflow.add{type = "sprite-button", style = "auto_research_sprite_button", name = "auto_research_blacklist-" .. name, sprite = "auto_research_deprioritize"}
                    entryflow.add{type = "label", style = "auto_research_tech_label", name = name, caption = tech.localised_name}
                    for _, ingredient in pairs(tech.research_unit_ingredients) do
                        local sprite = "auto_research_tool_" .. ingredient.name
                        if not player.gui.is_valid_sprite_path(sprite) then
                            sprite = "auto_research_unknown"
                        end
                        entryflow.add{type = "sprite", style = "auto_research_sprite", sprite = sprite}
                    end
                end
            end
        end
    end
}
