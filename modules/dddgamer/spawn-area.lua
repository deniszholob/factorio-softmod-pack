-- Spawn Area Module
-- Set tiles on the spawn area with concrete/bricks
-- Set entities on the spawn area for convenience
-- @usage require('modules/dddgamer/spawn-area')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local Math = require("util/Math")

-- Constants --
-- ======================================================= --

SpawnArea = {
    DO_PLACE_TILES = true,
    DO_PLACE_OBJECTS = true,
    POWER_POLE_TYPE = "medium-electric-pole", -- "small-electric-pole", "medium-electric-pole", "big-electric-pole"

    DO_PLACE_POWER = true,
    DO_PLACE_WALLS = true,

    DO_PLACE_TURRETS = true,
    INCLUDE_TURRET_AMMO = {name = 'firearm-magazine', count = 25},

    DO_PLACE_ROBOPORT = true,
    INCLUDE_ROBOPORT_ITEMS = {
        {name = 'construction-robot', count = 300},
        {name = 'logistic-robot', count = 50},
        {name = 'repair-pack', count = 100},
    },

    INCLUDE_PLAYER_ITEMS = {
        -- Solar Power
        {name = 'medium-electric-pole', count = 50},
        {name = 'substation', count = 16},
        {name = 'accumulator', count = 151},
        {name = 'solar-panel', count = 180},

        -- Steam power
        {name = 'small-electric-pole', count = 50},
        {name = 'offshore-pump', count = 20},
        {name = 'boiler', count = 20},
        {name = 'steam-engine', count = 40},
        {name = 'pipe-to-ground', count = 4},
        {name = 'pipe', count = 50},
        {name = 'transport-belt', count = 200},
        {name = 'underground-belt', count = 4},
        {name = 'burner-inserter', count = 20},
        {name = 'landfill', count = 20},
        {name = 'electric-mining-drill', count = 20},

        -- Smelting
        {name = 'small-electric-pole', count = 150},
        {name = 'stone-furnace', count = 80},
        {name = 'inserter', count = 100},
        {name = 'transport-belt', count = 400},
        {name = 'underground-belt', count = 50},
        {name = 'splitter', count = 200},

        -- Misc
        {name = "logistic-chest-storage", count = 50},
        {name = 'assembling-machine-1', count = 10},
        {name = 'big-electric-pole', count = 50},
        {name = 'radar', count = 3},
        {name = 'repair-pack', count = 100},
        {name = 'gun-turret', count = 10},
        {name = 'firearm-magazine', count = 100},
        -- {name = 'stone-wall', count = 50},
        -- {name = 'gate', count = 10},
    },

    DO_PLACE_CHESTS = true,
    -- "wooden-chest", "iron-chest", "steel-chest",
    -- "logistic-chest-passive-provider", "logistic-chest-storage", "logistic-chest-buffer", "logistic-chest-active-provider"
    CHEST_TYPE = "logistic-chest-storage",
    INCLUDE_CHEST_ITEMS = {
        -- {name = "cliff-explosives", count = 3},
        {name = "logistic-chest-storage", count = 5},
        {name = "logistic-chest-passive-provider", count = 11},
        {name = "logistic-chest-active-provider", count = 1},
        {name = "logistic-chest-requester", count = 2},
        {name = "logistic-chest-buffer", count = 5},
        {name = "roboport", count = 20},
        -- {name = "rail", count = 100},
        -- {name = "locomotive", count = 2},
        -- {name = "cargo-wagon", count = 1},
        -- {name = "car", count = 1},
        {name = 'radar', count = 4},
        {name = 'stone-brick', count = 200},
        {name = 'landfill', count = 20},
    },
}

-- Event Functions --
-- ======================================================= --

--- Various action when new player joins in game
--- @param event defines.events.on_player_created event
function SpawnArea.on_player_created(event)
    local player = game.players[event.player_index]

    if (SpawnArea.DO_PLACE_TILES and not global.IS_SPAWN_AREA_CREATED) then
        SpawnArea.placeTiles(player)
        if(SpawnArea.DO_PLACE_OBJECTS) then
            SpawnArea.placeObjects(player)
        end
        global.IS_SPAWN_AREA_CREATED = true
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_created, SpawnArea.on_player_created)

-- Helper Functions --
-- ======================================================= --

--- Draws tiles around the spawned player if they havnt been already
--- @param player LuaPlayer
function SpawnArea.placeTiles(player)
    local spawn_position = player.force.get_spawn_position(player.surface)
    local tile_refined_concrete = 'refined-concrete'
    local tile_refined_concrete_paint = 'refined-hazard-concrete-left'
    local tile_brick = 'stone-path'
    local tile_concrete = 'concrete'

    -- local inner_radius = 1
    -- local outer_radius = 3

    local marked_area_inner = {}
    local marked_area_outer = {}
    local marked_corners = {}

    -- |-----------------| --
    -- | -,- | 0,+ | +,- | --
    -- |-----------------| --
    -- | -,0 | 0,0 | +,0 | --
    -- |-----------------| --
    -- | -,+ | 0,- | +,+ | --
    -- |-----------------| --

    -- Turret concrete
    local t4 = {
        {-1.5, -4.5},
        {-2.5, -4.5},
        {-1.5, -3.5},
        {-2.5, -3.5},
        --
        {-3.5, -2.5},
        {-4.5, -2.5},
        {-3.5, -1.5},
        {-4.5, -1.5},
        --==--
        {1.5, -4.5},
        {2.5, -4.5},
        {1.5, -3.5},
        {2.5, -3.5},
        --
        {3.5, -2.5},
        {4.5, -2.5},
        {3.5, -1.5},
        {4.5, -1.5},
        --==--
        {-1.5, 4.5},
        {-2.5, 4.5},
        {-1.5, 3.5},
        {-2.5, 3.5},
        --
        {-3.5, 2.5},
        {-4.5, 2.5},
        {-3.5, 1.5},
        {-4.5, 1.5},
        --==--
        {1.5, 4.5},
        {2.5, 4.5},
        {1.5, 3.5},
        {2.5, 3.5},
        --
        {3.5, 2.5},
        {4.5, 2.5},
        {3.5, 1.5},
        {4.5, 1.5},
    }

    -- Path refined
    local t1 = {
        {0, 4},
        {1, 4},
        --
        {0, 2},
        {1, 2},
        --
        {-3, 1},
        {-1, 1},
        {0, 1},
        {1, 1},
        {2, 1},
        {4, 1},
        -- === --
        {-3, 0},
        {-1, 0},
        {0, 0},
        {1, 0},
        {2, 0},
        {4, 0},
        --
        {0, -1},
        {1, -1},
        --
        {0, -3},
        {1, -3}
    }
    -- Poles/lights hazard
    local t2 = {
        {-2.5, -2.5},
        {2.5, -2.5},
        {-2.5, 2.5},
        {2.5, 2.5},
        -- === --
        {-3.5, -3.5},
        {3.5, -3.5},
        {-3.5, 3.5},
        {3.5, 3.5},
    }
    -- Background Brick
    local t3 = {
        {0, 5},
        {1, 5},
        --
        {-2, 4},
        {-1, 4},
        {2, 4},
        {3, 4},
        --
        {-3, 3},
        {-1, 3},
        {0, 3},
        {1, 3},
        {2, 3},
        {4, 3},
        --
        {-3, 2},
        {-2, 2},
        {-1, 2},
        {2, 2},
        {3, 2},
        {4, 2},
        --
        {-4, 1},
        {-2, 1},
        {3, 1},
        {5, 1},
        -- === --
        {-4, 0},
        {-2, 0},
        {3, 0},
        {5, 0},
        --
        {-3, -1},
        {-2, -1},
        {-1, -1},
        {2, -1},
        {3, -1},
        {4, -1},
        --
        {-3, -2},
        {-1, -2},
        {0, -2},
        {1, -2},
        {2, -2},
        {4, -2},
        --
        {-2, -3},
        {-1, -3},
        {2, -3},
        {3, -3},
        --
        {0, -4},
        {1, -4}
    }

    local OFFSET = {x = -1, y = -1}

    -- Background tiles
    for i, value in ipairs(t3) do
        local tile = {
            name = tile_brick,
            position = {value[1] + OFFSET.x, value[2] + OFFSET.y}
        }
        table.insert(marked_area_outer, tile)
    end

    -- Post tiles
    for i, value in ipairs(t2) do
        local tile = {
            name = tile_refined_concrete_paint,
            position = {value[1], value[2]}
        }
        table.insert(marked_corners, tile)
    end

    -- Path tiles
    for i, value in ipairs(t1) do
        local tile = {
            name = tile_refined_concrete,
            position = {value[1] + OFFSET.x, value[2] + OFFSET.y}
        }
        table.insert(marked_area_inner, tile)
    end

    -- Turret tiles
    for i, value in ipairs(t4) do
        local tile = {
            name = tile_concrete,
            position = {value[1], value[2]}
        }
        table.insert(marked_area_outer, tile)
    end

    -- Outer tiles are refined concrete
    -- for x = -1 * outer_radius, outer_radius do
    --     for y = -1 * outer_radius, outer_radius do
    --         local tile = {}
    --         if ((x == outer_radius - 1 or x == outer_radius * -1) and (y == outer_radius - 1 or y == outer_radius * -1)) then
    --             -- Corners
    --             tile = {
    --                 name = tile_brick,
    --                 position = {spawn_position.x + x, spawn_position.y + y}
    --             }
    --         elseif ((x < inner_radius * -1 or x > inner_radius) or (y < inner_radius * -1 or y > inner_radius)) then
    --             -- Outer "ring"
    --             tile = {
    --                 name = tile_refined_concrete_paint,
    --                 position = {spawn_position.x + x, spawn_position.y + y}
    --             }
    --         else
    --             -- Inner tiles
    --             tile = {
    --                 name = tile_refined_concrete,
    --                 position = {spawn_position.x + x, spawn_position.y + y}
    --             }
    --         end
    --         table.insert(marked_area_outer, tile)
    --     end
    -- end

    SpawnArea.setTilesSafe(player.surface, marked_area_outer)
    SpawnArea.setTilesSafe(player.surface, marked_area_inner)
    SpawnArea.setTilesSafe(player.surface, marked_corners)
end

--- Sets tile area to a walkable surface (e.g. grass) first, then resets that to the tile passed in
--- @param surface LuaSurface to set tiles on
--- @param tiles LuaTile[] array of LuaTile
function SpawnArea.setTilesSafe(surface, tiles)
    local grass = SpawnArea.getWalkableTileName()
    local grass_tiles = {}
    for k, tile in pairs(tiles) do
        grass_tiles[k] = {
            name = grass,
            position = {x = (tile.position.x or tile.position[1]), y = (tile.position.y or tile.position[2])}
        }
    end
    surface.set_tiles(grass_tiles, false)
    surface.set_tiles(tiles)
end

--- @return string name the first available walkable tile name in the prototype list (e.g. grass)
function SpawnArea.getWalkableTileName()
    for name, tile in pairs(game.tile_prototypes) do
        if tile.collision_mask['player-layer'] == nil and not tile.items_to_place_this then
            return name
        end
    end
    error('No walkable tile in prototype list')
end

--- Place lamps, and trash chests
--- @param player LuaPlayer
function SpawnArea.placeObjects(player)
    SpawnArea.placeLamps(player)
    SpawnArea.placePowerPoles(player)
    SpawnArea.addBonusPlayerItems(player)

    if(SpawnArea.DO_PLACE_CHESTS) then
        SpawnArea.placeChests(player)
    end

    if(SpawnArea.DO_PLACE_POWER) then
        SpawnArea.placeSolar(player)
        SpawnArea.placeAccumulators(player)
    end

    if(SpawnArea.DO_PLACE_WALLS) then
        SpawnArea.placeWalls(player)
        SpawnArea.placeGates(player)
    end

    if(SpawnArea.DO_PLACE_TURRETS) then
        SpawnArea.placeTurrets(player)
    end

    if(SpawnArea.DO_PLACE_ROBOPORT) then
        SpawnArea.placeRoboport(player)
        SpawnArea.placeLogisticStorage(player)
    end
end

--- @param player LuaPlayer
function SpawnArea.placeWalls(player)
    local locations = {
        -- NW
        {pointStart = {x=-9.5, y=-9.5}, pointEnd = {x=-2.5, y=-9.5}},
        {pointStart = {x=-9.5, y=-9.5}, pointEnd = {x=-9.5, y=-2.5}},
        -- NE
        {pointStart = {x=9.5, y=-9.5}, pointEnd = {x=2.5, y=-9.5}},
        {pointStart = {x=9.5, y=-9.5}, pointEnd = {x=9.5, y=-2.5}},
        -- SW
        {pointStart = {x=-9.5, y=9.5}, pointEnd = {x=-9.5, y=2.5}},
        {pointStart = {x=-9.5, y=9.5}, pointEnd = {x=-2.5, y=9.5}},
        -- SE
        {pointStart = {x=9.5, y=9.5}, pointEnd = {x=2.5, y=9.5}},
        {pointStart = {x=9.5, y=9.5}, pointEnd = {x=9.5, y=2.5}},
    }
    for i, location in ipairs(locations) do
        local locationPoints = Math.bresenhamLine(location.pointStart, location.pointEnd)
        SpawnArea.placeEntities(player, 'stone-wall', locationPoints)
    end
end

--- @param player LuaPlayer
function SpawnArea.placeGates(player)
    local locations = {
        -- N
        {pointStart = {x=-1.5, y=-9.5}, pointEnd = {x=1.5, y=-9.5}},
        -- W
        {pointStart = {x=-9.5, y=-1.5}, pointEnd = {x=-9.5, y=1.5}},
        -- S
        {pointStart = {x=-1.5, y=9.5}, pointEnd = {x=1.5, y=9.5}},
        -- E
        {pointStart = {x=9.5, y=-1.5}, pointEnd = {x=9.5, y=1.5}},
    }
    for i, location in ipairs(locations) do
        local locationPoints = Math.bresenhamLine(location.pointStart, location.pointEnd)
        local direction = defines.direction.east
        if(i % 2 == 0) then
            direction = defines.direction.north
        end
        SpawnArea.placeEntities(player, 'gate', locationPoints, nil, direction)
    end
end


--- @param player LuaPlayer
function SpawnArea.placeLamps(player)
    local locations = {
        {-2.5, -2.5},
        {2.5, -2.5},
        -- === --
        {-2.5, 2.5},
        {2.5, 2.5},
    }

    for i, value in ipairs(locations) do
        local entity = player.surface.create_entity({
            name='small-lamp',
            position=value,
            force=game.forces.player
        })
        entity.destructible = false
        entity.minable = false
    end
end

--- @param player LuaPlayer
function SpawnArea.placePowerPoles(player)
    local locations = {
        {-3.5, -3.5},
        {3.5, -3.5},
        -- === --
        {-3.5, 3.5},
        {3.5, 3.5},
    }
    SpawnArea.placeEntities(player, SpawnArea.POWER_POLE_TYPE, locations)
end

--- @param player LuaPlayer
function SpawnArea.addBonusPlayerItems(player)
    SpawnArea.insertItemsIntoEntity(player, SpawnArea.INCLUDE_PLAYER_ITEMS)
end

--- @param player LuaPlayer
function SpawnArea.placeSolar(player)
    local locations = {
        {3.5, -6.5},
        {-3.5, -6.5},
        {-6.5, -3.5},
        {-6.5, 3.5},
        {-3.5, 6.5},
        {3.5, 6.5},
        {6.5, 3.5},
        {6.5, -3.5},
    }
    SpawnArea.placeEntities(player, 'solar-panel', locations)
end

--- @param player LuaPlayer
function SpawnArea.placeAccumulators(player)
    local locations = {
        {-6, -6},
        {-6, 6},
        {6, 6},
    }
    SpawnArea.placeEntities(player, 'accumulator', locations)
end

--- @param player LuaPlayer
function SpawnArea.placeTurrets(player)
    local locations = {
        {2, 4},
        {4, 2},
        {-2, 4},
        {-4, 2},
        {2, -4},
        {4, -2},
        {-2, -4},
        {-4, -2},
    }
    SpawnArea.placeEntities(player, 'gun-turret', locations, {SpawnArea.INCLUDE_TURRET_AMMO})
end

--- @param player LuaPlayer
function SpawnArea.placeRoboport(player)
    local locations = {{7,-7}}
    SpawnArea.placeEntities(player, 'roboport', locations, SpawnArea.INCLUDE_ROBOPORT_ITEMS)
end

--- @param player LuaPlayer
function SpawnArea.placeLogisticStorage(player)
    local locations = {{4.5, -4.5}}
    SpawnArea.placeEntities(player, 'logistic-chest-storage', locations, SpawnArea.INCLUDE_CHEST_ITEMS)
end

--- @param player LuaPlayer
function SpawnArea.placeChests(player)
    local locations = {
        {-1.5, -1.5},
        {1.5, -1.5},
        -- === --
        {-1.5, 1.5},
        {1.5, 1.5},
    }
    SpawnArea.placeEntities(player, SpawnArea.CHEST_TYPE, locations, SpawnArea.INCLUDE_CHEST_ITEMS)
end


--- @param entity LuaEntity Valid entity to add items to (LuaPlayer, chest, roboport etc..)
--- @param items table List of {name = 'name', count = 0}
function SpawnArea.insertItemsIntoEntity(entity, items)
    for j, item in ipairs(items) do
        entity.insert(item)
    end
end

--- @param player LuaPlayer
--- @param entityName string
--- @param locations table List of {Number, Number}
--- @param items table List of {name = 'name', count = 0}
--- @param rotation any
function SpawnArea.placeEntities(player, entityName, locations, items, rotation)
    local direction = defines.direction.north
    if(rotation) then
        direction = rotation
    end
    for i, location in ipairs(locations) do
        local entity = player.surface.create_entity({
            name=entityName,
            position=location,
            direction=direction,
            force=game.forces.player
        })
        if(items) then
            SpawnArea.insertItemsIntoEntity(entity, items)
        end
    end
end
