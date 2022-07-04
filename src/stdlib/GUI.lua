-- GUI Helper Module
-- @module GUI
-- Common GUI functions
-- @usage local GUI = require('stdlib/GUI')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local mod_gui = require('mod-gui') -- From `Factorio\data\core\lualib`
local GUI_Events = require("stdlib/GUI_Events")

-- Constants --
-- ======================================================= --
GUI = {
    MASTER_FRAME_LOCATIONS = {
        left = 'left', -- Frame flow
        center = 'center', -- gui.center
        menu = 'menu', -- Button flow
    }
}

-- Public Functions --
-- ======================================================= --

-- Destroys the children of a GUI element
-- @tparam LuaGuiElement el Element to destroy childen of
function GUI.clear_element(el)
    if el ~= nil then
        for i, child_el in pairs(el.children) do
            child_el.destroy()
        end
    end
end

-- Toggles element on off (visibility)
-- @tparam LuaGuiElement el Element to toggle visibility of
function GUI.toggle_element(el)
    if el ~= nil then
        if (el.visible == nil) then -- game treats nil as true
            el.visible = true
        end
        el.visible = not el.visible or false
    end
end

-- Destroys element if exists
-- @tparam LuaGuiElement el Element
function GUI.destroy_element(el)
    if (el ~= nil) then
        el.destroy()
    end
end

-- Applies a style to the passed in element
-- @tparam LuaGuiElement el Element
-- @tparam LuaStyle style
function GUI.element_apply_style(el, style)
    if style then
        for name, value in pairs(style) do
            if(el.style)then
                el.style[name] = value
            else
                error('Element doesnt have style ' .. name)
            end
        end
    end
end

-- Adds an element to the parent element
-- @param Element Definition
-- @tparam LuaGuiElement parent Element
-- @treturn LuaGuiElement el Element
function GUI.add_element(parent, el)
    if (parent and parent.el == nil) then
        return parent.add(el)
    else
        error("Parent Element is nil")
    end
end

-- Adds a button to the parent element
-- @tparam LuaGuiElement parent Element
-- @param el_definition element definition
-- @param callback function
-- @treturn LuaGuiElement el
function GUI.add_button(parent, el_definition, callback)
    GUI.fail_on_type_mismatch(el_definition, "button")

    -- Create element
    local el = GUI.add_element(parent, el_definition)

    GUI.register_if_callback(
        callback,
        el_definition.name,
        GUI_Events.register_on_gui_click
    )

    return el
end

-- Adds a sprite-button to the parent element
-- @tparam LuaGuiElement parent Element
-- @param el_definition element definition
-- @param callback function
-- @treturn LuaGuiElement el
function GUI.add_sprite_button(parent, el_definition, callback)
    GUI.fail_on_type_mismatch(el_definition, "sprite-button")

    -- Create element
    local el = GUI.add_element(parent, el_definition)

    GUI.register_if_callback(
        callback,
        el_definition.name,
        GUI_Events.register_on_gui_click
    )

    return el
end

-- Adds a checkbox to the parent element
-- @tparam LuaGuiElement parent Element
-- @param el_definition element definition
-- @param callback function
-- @treturn LuaGuiElement el
function GUI.add_checkbox(parent, el_definition, callback)
    GUI.fail_on_type_mismatch(el_definition, "checkbox")

    -- Create element
    local el = GUI.add_element(parent, el_definition)

    GUI.register_if_callback(
        callback,
        el_definition.name,
        GUI_Events.register_on_gui_checked_state_changed
    )

    return el
end

-- Helper Functions --
-- ======================================================= --

-- Cant register call back without a name, fail if missing
function GUI.register_if_callback(callback, name, register_function)
    -- Callback provided
    if (callback) then
        if (not name) then
            -- cant register without a name
            error("Element name not defined, callback not registered")
            return
        elseif (not register_function or not (type(register_function) == "function")) then
            -- cant register without a registration function
            error(
                "Registration function " ..
                    serpent.block(register_function) ..
                        " not provided or not a function, its a " .. type(register_function)
            )
            return
        else
            -- Name exists, registration function ok -> register callback
            register_function(name, callback)
        end
    end
end

-- If types dont match, error out
function GUI.fail_on_type_mismatch(el, type)
    if (not el.type == type) then
        error("Invalid element definition: element type" .. el.type .. " is not " .. type)
        return
    end
end

-- @tparam LuaPlayer player player who owns a gui
-- @tparam string sprite_name name/path of the sprite
-- @treturn string sprite_name if valid path if not a question mark sprite
function GUI.get_safe_sprite_name(player, sprite_name)
    if not player.gui.is_valid_sprite_path(sprite_name) then
        sprite_name = "utility/questionmark"
    end
    return sprite_name
end


-- @tparam LuaPlayer player player who owns a gui
function GUI.menu_bar_el(player)
    return mod_gui.get_button_flow(player)
end

-- @tparam LuaPlayer player player who owns a gui
function GUI.master_frame_location_el(player, location)
    if(location == GUI.MASTER_FRAME_LOCATIONS.left) then
        return mod_gui.get_frame_flow(player)
    elseif(location == GUI.MASTER_FRAME_LOCATIONS.center) then
        return player.gui.center
    elseif(location == GUI.MASTER_FRAME_LOCATIONS.menu) then
        return mod_gui.get_button_flow(player)
    else
        error('Inalid location ' .. location)
        return nil
    end
end

return GUI
