-- Vanilla 0.15 Rocket code

-- Dependencies
require("silo-script")

local version = 1


script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  silo_script.gui_init(player)
end)

script.on_event(defines.events.on_gui_click, function(event)
  silo_script.on_gui_click(event)
end)

script.on_init(function()
  global.version = version
  silo_script.init()
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
