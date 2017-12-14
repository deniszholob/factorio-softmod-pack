-- Announcement Module
-- Displays announcements for players
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Dependencies
require "locale/softmod-modules-util/Time"
require "locale/softmod-modules-util/Roles"

-- Intro Messages
local intros = {
  "Welcome to Factorio Freeplay",
  -- "Welcome to Factorio Train World!",
  "Join discord for voice chat, discussion and support: https://discord.gg/hmwb3dB",
}

-- Periodic announcements
local announcements = {
  "Join discord for voice chat, discussion and support: https://discord.gg/hmwb3dB",
  "Go to Readme -> Social for more info",
}

-- How long to delay before showing announcement messages again (in minutes)
local announcement_delay = 1 --(min)


-- Show introduction messages to players upon joining
-- @param event - on_player_created
local function show_intro(event)
  local player = game.players[event.player_index]
  for i,v in pairs(intros) do
    player.print(v)
  end
end


-- Show anouncements after a delay
-- @param event - on_tick
local function show_announcement(event)
  -- Check if delay passed
  if (Time.tick_to_min(game.tick) % announcement_delay == 0) then
  -- Loop though announcements
    for i,message in pairs(announcements) do
      game.print(message)
      -- Roles.send_msg(message, Roles.DEFAULT)
      -- Roles.send_msg(message, Roles.ADMIN)
    end
  end
end


-- Event handlers
-- Event.register(defines.events.on_tick, show_announcement)
Event.register(defines.events.on_player_created, show_intro)
