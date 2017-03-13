-- Periodic announcements and intro messages
local intros = {
  "Welcome to Factorio freeplay",
  "Join discord for voice chat and admin support: https://discord.gg/hmwb3dB"
}
local announcements = {
  "Join discord for voice chat and admin support: https://discord.gg/hmwb3dB"
}

-- Show introduction messages to players upon joining
-- @param event
local function show_intro(event)
  local player = game.players[event.player_index]
  for i,v in pairs(intros) do
    player.print(v)
  end
end

-- Show and anouncements after 10 minutes
local function show_announcement(event)
  global.last_announcement_time = global.last_announcement_time or 0
  local cur_time = game.tick / 60
  local announcement_delay = 600 --seconds (10 min)
  local announcement_time_passed = cur_time - global.last_announcement_time
  if announcement_time_passed > announcement_delay then
    for i,v in pairs(announcements) do
      game.print(v)
      global.last_announcement_time = cur_time
    end
  end
end

-- Event handlers
-- Event.register(defines.events.on_tick, show_announcement)
Event.register(defines.events.on_player_created, show_intro)
