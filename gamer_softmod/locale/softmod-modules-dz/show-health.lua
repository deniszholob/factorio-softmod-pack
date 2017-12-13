-- Show Health Soft Mod
-- Show the health of a player as a small piece of colored text above their head
-- @author Denis Zholob (DDDGamer) - Remix of 3Ra Gaming showhealth
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Dependencies
require "locale/softmod-modules-util/Colors"

-- Max player Health is 250 as of v0.15 (changed from 100 in v0.14)
local MAX_PLAYER_HP = 250


-- On tick go through all the players and see if need to display health text
-- @param event on_tick
local function on_tick (event)
  -- Show every half second
  if game.tick % 30 ~= 0 then return end

  -- For every player thats online...
  for i, player in pairs(game.connected_players) do
    if player.character then
      -- Exit if player character doesnt have health
      if player.character.health == nil then return end
      local health = math.ceil(player.character.health)
      -- Set up global health var if doesnt exist
      if global.player_health == nil then global.player_health = {} end
      if global.player_health[player.name] == nil then global.player_health[player.name] = health end
      -- If mismatch b/w global and current hp, display hp text
      if global.player_health[player.name] ~= health then
        global.player_health[player.name] = health
        show_player_health(player, health)
      end
    end
  end
end


-- Draws different color health # above the player based on HP value
-- @param player
-- @param health
function show_player_health(player, health)
  if health <= percent_to_hp(30) then
    draw_flying_text(player, Colors.red,    hp_to_percent(health) .. "%")
  elseif health <= percent_to_hp(50) then
    draw_flying_text(player, Colors.yellow, hp_to_percent(health) .. "%")
  elseif health <= percent_to_hp(80) then
    draw_flying_text(player, Colors.green,  hp_to_percent(health) .. "%")
  end
end


-- Draws text above the player
-- @param player
-- @param t_color <- text color (rgb)
-- @param t_text  <- text to display (string)
function draw_flying_text(player, t_color, t_text)
  player.surface.create_entity{
    name = "flying-text",
    color = t_color,
    text = t_text,
    position = {player.position.x, player.position.y - 2}
  }
end


-- Returns an HP value from apercentage
-- @param val - HP number to convert to Percentage
function hp_to_percent(val)
  return math.ceil(100 / MAX_PLAYER_HP * val)
end


-- Returns HP as a percentage instead of raw number
-- @param val - Percentage number to convert to HP
function percent_to_hp(val)
  return math.ceil(MAX_PLAYER_HP / 100 * val)
end


-- Event Registraion
Event.register(defines.events.on_tick, on_tick)
