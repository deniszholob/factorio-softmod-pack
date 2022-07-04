-- Silo Soft Module
-- Vanilla code modified with Event registration and structured more
-- @usage require('modules/vanilla/silo')s
-- ------------------------------------------------------- --
-- @author Factorio Devs
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies
-- ======================================================= --
local silo_script = require('silo-script') -- this is in factorio itself

-- Constants
-- ======================================================= --
local version = 1

-- Event Functions --
-- ======================================================= --
function on_init()
    global.version = version
    silo_script.on_init()
end

function on_configuration_changed(event)
    if global.version ~= version then
        global.version = version
    end
    silo_script.on_configuration_changed(event)
end

function on_player_created(event)
    silo_script.on_player_created(event)
end

function on_rocket_launched(event)
    silo_script.on_rocket_launched(event)
end

function on_gui_click(event)
    silo_script.on_gui_click(event)
end

silo_script.add_remote_interface()
silo_script.add_commands()

-- Event Registration --
-- ======================================================= --
Event.register(Event.core_events.init, on_init)
Event.register(Event.core_events.configuration_changed, on_configuration_changed)
Event.register(defines.events.on_player_created, on_player_created)
Event.register(defines.events.on_player_created, on_rocket_launched)
Event.register(defines.events.on_player_created, on_gui_click)
