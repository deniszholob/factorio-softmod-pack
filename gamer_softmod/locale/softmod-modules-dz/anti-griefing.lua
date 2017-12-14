-- Anti-Griefing Soft Mod
-- Prevents new players from destroing stuff and spamming pavements
-- Ignores the early game
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Notes:
--       * Carfull with notifications as its very spammy in admin chat.
--       * A lot of the code is commented out because of the following rotation bug. Antigriefing for building only notifies at this stage.
--       * TODO:/FIXME: - Add "on_build event" to prevent building over other peoples structures (inserter/belt bug with rotations)

-- Dependencies
require "locale/softmod-modules-util/Time"
require "locale/softmod-modules-util/Time_Rank"

local early_game_range = 60 --(min)
local time_regular_player = Time_Rank.RANKS.lvl2.time -- hours
local item_to_remove = nil

-- When something is built...
-- If its tiles, and not a regular player, cancel the action, notify admins
-- @param event on_built_entity
function on_built_entity(event)
  local player = game.players[event.player_index]
  local entity = event.created_entity

  if (not player.admin and
     Time.tick_to_hour(player.online_time) < time_regular_player) then
     if (entity.type == "tile-ghost") then
      local entity_name = entity.ghost_name
      entity.destroy()
      player.print("Play more to unlock ghosting tiles (brick/concrete).")
      notify_admins(player.name .. " tried to ghost " .. entity_name)
     end
  end
end


-- Before player tries to mine something...
-- Note: Factorio API curretely does not allow for cancelling mining operations.
-- https://forums.factorio.com/viewtopic.php?f=7&t=27630#p175589
-- Replace mined item with identical copy, save the item that was mined for removal in on_player_mined_item event
-- @param event on_pre_player_mined_item
function on_pre_player_mined_item(event)
  local player = game.players[event.player_index]
  local entity = event.entity
  local entity_name = ""
  local is_entity_ghost = entity.name == "entity-ghost"

  -- Check if its the beginning of the game, and skip if it is
  if is_early_game() then
    return
  end

  -- Check for allowed entities or admins and exit
  if (player.admin
      or entity.force.name == "neutral"
      -- Dont care about cars, robots or tile-ghosts
      or entity.name == "tile-ghost"
      or entity.type == "car"
      or entity.type:find("robot")
      -- From testing Trains cant be replaced as of 2017-03-20 (v0.14)
      or entity.type == "locomotive"
      or entity.type == "cargo-wagon"
      or entity.last_user == nil
      ) then
    return
  end

  -- If not a regular player and mining structure was built by another player
  if (Time.tick_to_hour(player.online_time) < time_regular_player
      and entity.last_user.name ~= player.name
      ) then
    -- -- ghost entity (re-create the ghost entity)
    if is_entity_ghost then
      entity_name = entity.ghost_name
    --   local ghost = entity.surface.create_entity{
    --     name=entity.name,
    --     force=entity.force,
    --     inner_name=entity.ghost_name,
    --     position=entity.position,
    --     direction=entity.direction
    --   }
    --   ghost.last_user = entity.last_user
    else -- Regular entity (try to re-create the entity)
      entity_name = entity.name
    --   entity_player_name = entity.last_user.name
    --   local replacement_entity = entity.surface.create_entity{
    --     name=entity.name,
    --     force=entity.force.name,
    --     position=entity.position,
    --     direction=entity.direction,
    --     fast_replace=true,
    --     spill=false
    --   }

    --   -- Creation of new entity is successfull
    --   if replacement_entity ~= nil then
    --     -- Preserve the original entity creator when making the copy
    --     replacement_entity.last_user = game.players[entity_player_name]
    --     -- If the source entity is valid then coppy settings the the re-created copy (assembler/oil recipies, logic, etc...)
    --     if entity ~= nil and entity.valid then
    --       replacement_entity.copy_settings(entity)
    --       -- Prevent infinite items, set to remove the item from inventory on mined event.
    --       item_to_remove = {name=entity.name, count=1}
    --     end
    --   else
    --   -- Creation of the entity was unccessesfull (usually with rails)
    --     if entity ~= nil and entity.valid then
    --       -- Regular replacement failed, resorting to ghost replacement
    --       local ghost = entity.surface.create_entity{
    --         name="entity-ghost",
    --         force=entity.force,
    --         inner_name=entity_name,
    --         position=entity.position,
    --         direction=entity.direction
    --       }
    --       ghost.last_user = game.players[entity_player_name]
    --     end
    --   end

    end

    -- Notifications
    -- player.print("Play more to unlock mining structures created by others.")
    if is_entity_ghost then
      notify_admins(player.name .. " tried to mine ghost " .. entity_name)
      log("Warning: " .. player.name .. " tried to mine ghost" .. entity_name)
    else
      notify_admins(player.name .. " tried to mine " .. entity_name)
      log("Warning: " .. player.name .. " tried to mine " .. entity_name)
    end

  end
end


-- When a player finishes mining an item...
-- Continuation from on_pre_player_mined_item event
-- Remove the item that the player mined from their inventory (b/c we re-created a copy already and dont want infinite items.)
-- @param event on_player_rotated_entity
function on_player_mined_item(event)
  local player = game.players[event.player_index]
  if item_to_remove ~= nil then
    player.remove_item(item_to_remove)
    item_to_remove = nil
  end
end


-- When something is marked for deconstruction...
-- If its not a regular player, cancel the action, notify admins
-- Note: Cant filter by last_user as its replaced by the player doing the deconstruction already
-- @param event on_marked_for_deconstruction
function on_marked_for_deconstruction(event)
  local player = game.players[event.player_index]
  local entity = event.entity

  -- Check if its the beginning of the game, and skip if it is
  if is_early_game() then
    return
  end

  -- Check for allowed entities or admins and exit
  if (player.admin or
      entity.type == "tree" or
      entity.type == "simple-entity") then
      -- game.print(entity.name .. "(" .. entity.type .. ") was marked for deconstruction")
    return
  end

  -- If not a regular player marking structure for deconstruction built by another player
  if (Time.tick_to_hour(player.online_time) < time_regular_player) then
    entity.cancel_deconstruction("player")
    player.print("Play more to unlock the use of deconstruction planner on structures built by others.")
    notify_admins(player.name .. " tried to use the deconstruction planner")
  end
end


-- Player tired to rotate item...
-- If it doesnt belong to player, then rotate back (not implemented), and notify admins
-- @param event on_player_rotated_entity
function on_player_rotated_entity(event)
  local player = game.players[event.player_index]
  local entity = event.entity

  -- Check if its the beginning of the game, and skip if it is
  if is_early_game() then
    return
  end

  if (not player.admin and
      Time.tick_to_hour(player.online_time) < time_regular_player and
      entity.last_user.name ~= player.name) then
      -- How to rotate back?
      -- TODO: keep ownership
      -- player.print("Play more to unlock rotating structures built by others.")
      notify_admins(player.name .. " tried to rotate " .. entity.name)
  end
end


-- Print a message to all admins
-- @param message - string to print
function notify_admins(message)
--   for i, player in pairs(game.connected_players) do
--     if player.admin then
--       player.print("Warning: " .. message)
      -- Carefull of logging here as the game will log for every item,
      -- thus can slow down the game considerably if player is trying
      -- to deconstruct lots of items at once.
      -- log("Warning: " .. message)
--     end
--   end
end


-- Returns true is game time is less thatn the early_game_range
function is_early_game()
  return ((Time.tick_to_min(game.tick) < early_game_range))
end


-- Event Handlers
Event.register(defines.events.on_built_entity, on_built_entity)
Event.register(defines.events.on_player_mined_item, on_player_mined_item)
Event.register(defines.events.on_pre_player_mined_item, on_pre_player_mined_item)
Event.register(defines.events.on_player_rotated_entity, on_player_rotated_entity)
Event.register(defines.events.on_marked_for_deconstruction, on_marked_for_deconstruction)
