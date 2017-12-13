-- Player Soft Mod
-- Changes spawn items from vanilla version
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Dependencies
require "locale/softmod-modules-util/Time"
require "locale/softmod-modules-util/Time_Rank"

local REVEAL_AREA_RADIUS = 200

-- Give player starting items.
-- @param event on_player_created event
function player_created(event)
  local player = game.players[event.player_index]

  -- Always start a new player with these
  player.insert { name = "iron-plate",          count = 10 }
  player.insert { name = "pistol",              count = 1  }
  player.insert { name = "firearm-magazine",    count = 10 }

  -- To mark the spawn location get some brick and concrete
  if(player.name=="DDDGamer") then
    player.insert { name = "stone-brick",       count = 16 }
    player.insert { name = "hazard-concrete",   count = 20 }
  end

  -- Less than 20min into the game
  if Time.tick_to_min(game.tick) < 20 then
    player.insert { name = "iron-axe",            count = 1  }
    player.insert { name = "stone-furnace",       count = 1  }
    player.insert { name = "burner-mining-drill", count = 3  }
    player.insert { name = "wooden-chest",        count = 1  }
  -- Less than 60min into the game
  elseif Time.tick_to_min(game.tick) < 60 then
    player.insert { name = "iron-axe",            count = 1  }
  -- After 2hrs into the game
  elseif Time.tick_to_min(game.tick) > 120 then
    player.insert { name = "steel-axe",           count = 1  }
  end
  reveal_area(player)
end

-- Give player weapons after they respawn.
-- @param event on_player_respawned event
function player_respawned(event)
  local player = game.players[event.player_index]

  -- Less than 20min into the game
  if Time.tick_to_min(game.tick) < 20 then
    player.insert { name = "iron-axe",         count = 1  }
    player.insert { name = "pistol",           count = 1  }
    player.insert { name = "firearm-magazine", count = 10 }
  -- Less than 60min into the game
  elseif Time.tick_to_min(game.tick) < 60 then
    player.insert { name = "iron-axe",         count = 1  }
    player.insert { name = "submachine-gun",   count = 1  }
    player.insert { name = "firearm-magazine", count = 10 }
  -- After 2hrs into the game
  elseif Time.tick_to_min(game.tick) > 120 then
    player.insert { name = "steel-axe",                count = 1  }
    player.insert { name = "submachine-gun",           count = 1  }
    player.insert { name = "piercing-rounds-magazine", count = 10 }
  end
end

-- Reveal area around the player
-- @param player
function reveal_area(player)
  player.force.chart(player.surface, {
    {player.position.x - REVEAL_AREA_RADIUS, player.position.y - REVEAL_AREA_RADIUS},
    {player.position.x + REVEAL_AREA_RADIUS, player.position.y + REVEAL_AREA_RADIUS}
  })
end


-- Register Events
Event.register(defines.events.on_player_created, player_created)
Event.register(defines.events.on_player_respawned, player_respawned)
