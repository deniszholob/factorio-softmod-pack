-- GUI Events Soft Module
-- Handles registration/dispatch of GUI clicks, etc...
-- @usage local ModuleName = require('stdlib/GUI_Events')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --

-- Constants --
-- ======================================================= --
GUI_Events = {}

-- Event Functions --
-- ======================================================= --

-- @param event any gui event
-- @param type event type string
function GUI_Events.call_handler(event, event_type)
    if not (event and event.element and event.element.valid) then
        return
    end

    if
        (event_type and
            (event_type == "on_gui_click" or event_type == "on_gui_checked_state_changed" or
                event_type == "on_gui_selection_state_changed"))
     then
        local config = GUI_Events.getConfig()
        local callback = config.callbacks[event_type][event.element.name]

        if callback then
            callback(event)
        -- else
        -- Callback not found -> either error in programming,
        -- or simply that event not using the GUI_Events registration
        -- game.print("DEBUG: Callback for '" .. event_type .. " | " .. event.element.name .. "' is not registered.")
        -- game.print("DEBUG: " .. serpent.block(callback))
        end
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(
    defines.events.on_gui_click,
    function(event)
        GUI_Events.call_handler(event, "on_gui_click")
    end
)
Event.register(
    defines.events.on_gui_selection_state_changed,
    function(event)
        GUI_Events.call_handler(event, "on_gui_selection_state_changed")
    end
)
Event.register(
    defines.events.on_gui_checked_state_changed,
    function(event)
        GUI_Events.call_handler(event, "on_gui_checked_state_changed")
    end
)

-- Helper Functions --
-- ======================================================= --

-- Registers a callback function to be called on_gui_click event
function GUI_Events.register_on_gui_click(el_name, callback)
    GUI_Events.register(el_name, callback, true, "on_gui_click")
end
-- Registers a callback function to be called on_gui_checked_state_changed event
function GUI_Events.register_on_gui_checked_state_changed(el_name, callback)
    GUI_Events.register(el_name, callback, true, "on_gui_checked_state_changed")
end
-- Registers a callback function to be called on_gui_selection_state_changed event
function GUI_Events.register_on_gui_selection_state_changed(el_name, callback)
    GUI_Events.register(el_name, callback, true, "on_gui_selection_state_changed")
end

-- Generic event registration
function GUI_Events.register(el_name, callback, overwrite, event_type)
    -- Invalid callback provided
    if (not callback or not (type(callback) == "function")) then
        error(
            "Element event registration failed: callback " ..
                serpent.block(callback) .. " not a function, its a " .. type(callback)
        )
        return
    end

    -- No element name provided
    if (not el_name) then
        error("Element event registration failed: name was nil!")
        return
    end

    if
        (event_type and
            (event_type == "on_gui_click" or event_type == "on_gui_checked_state_changed" or
                event_type == "on_gui_selection_state_changed"))
     then
        local config = GUI_Events.getConfig()
        if (config.callbacks[event_type][el_name] and not overwrite) then
            error("Element event registration failed: element callback already exists!")
        else
            -- game.print("DEBUG: Registered " .. event_type .. " " .. el_name)
            config.callbacks[event_type][el_name] = callback
        end
    end
end

-- Returns the module config, creates default config if doesnt exist
-- @tparam LuaPlayer player
function GUI_Events.getConfig()
    if (not global.gui_events_config) then
        global.gui_events_config = {
            callbacks = {
                on_gui_click = {},
                on_gui_checked_state_changed = {},
                on_gui_selection_state_changed = {}
            }
        }
    end

    return global.gui_events_config
end

return GUI_Events
