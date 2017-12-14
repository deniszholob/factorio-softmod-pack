-- Vanilla 0.16 Rocket code

-- Dependencies
local silo_script = require("silo-script")

local version = 1


script.on_event(defines.events.on_player_created, function(event)
  silo_script.on_player_created(event)
end)

script.on_event(defines.events.on_gui_click, function(event)
  silo_script.on_gui_click(event)
end)

script.on_init(function()
  global.version = version
  silo_script.on_init()
end)

script.on_event(defines.events.on_rocket_launched, function(event)
  silo_script.on_rocket_launched(event)
end)

script.on_configuration_changed(function(event)
  if global.version ~= version then
    global.version = version
  end
  silo_script.on_configuration_changed(event)
end)

silo_script.add_remote_interface()
silo_script.add_commands()
