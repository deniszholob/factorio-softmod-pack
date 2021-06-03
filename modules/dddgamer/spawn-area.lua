-- Spawn Area Module
-- Set tiles on the spawn area with concrete/bricks
-- Set entities on the spawn area for convenience
-- @usage require('modules/dddgamer/spawn-area')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Constants --
-- ======================================================= --

local SpawnArea = {
    DO_PLACE_TILES = true,
    DO_PLACE_OBJECTS = true,
    POWER_POLE_TYPE = "medium-electric-pole", -- "small-electric-pole", "medium-electric-pole", "big-electric-pole"

    INCLUDE_PLAYER_ITEMS = {
        -- Solar Power
        -- {name = 'medium-electric-pole', count = 1},
        -- {name = 'accumulator', count = 1},
        -- {name = 'solar-panel', count = 2},

        -- Steam power
        -- {name = 'small-electric-pole', count = 2},
        -- {name = 'offshore-pump', count = 1},
        -- {name = 'boiler', count = 1},
        -- {name = 'steam-engine', count = 1},
        -- {name = 'pipe-to-ground', count = 2},
        -- {name = 'pipe', count = 1},

        -- Misc
        -- {name = 'radar', count = 1},
        {name = 'repair-pack', count = 1},
    },

    DO_PLACE_TURRETS = true,
    INCLUDE_TURRET_AMMO = {name = 'firearm-magazine', count = 4},

    DO_PLACE_ROBOPORT = false,
    INCLUDE_ROBOPORT_ITEMS = {
        {name = 'construction-robot', count = 50},
        {name = 'logistic-robot', count = 50},
        {name = 'repair-pack', count = 1},
    },

    DO_PLACE_CHESTS = true,
    INCLUDE_CHEST_ITEMS = {
        {name = "cliff-explosives", count = 3},
        -- {name = "logistic-chest-passive-provider", count = 10},
        -- {name = "logistic-chest-active-provider", count = 1},
        -- {name = "logistic-chest-requester", count = 1},
        -- {name = "roboport", count = 2},
        -- {name = "rail", count = 100},
        -- {name = "locomotive", count = 2},
        -- {name = "cargo-wagon", count = 1},
        -- {name = "car", count = 1},
        -- {name = 'radar', count = 1},
    }
}

-- Event Functions --
-- ======================================================= --

-- Various action when new player joins in game
-- @param event on_player_created event
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

-- Draws tiles around the spawned player if they havnt been already
-- @param player LuaPlayer
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

-- Sets tile area to a walkable surface (e.g. grass) first, then resets that to the tile passed in
-- @param surface - LuaSurface to set tiles on
-- @param tiles - array of LuaTile
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

-- @return the first available walkable tile name in the prototype list (e.g. grass)
function SpawnArea.getWalkableTileName()
    for name, tile in pairs(game.tile_prototypes) do
        if tile.collision_mask['player-layer'] == nil and not tile.items_to_place_this then
            return name
        end
    end
    error('No walkable tile in prototype list')
end

-- Place lamps, and trash chests
-- @param player LuaPlayer
function SpawnArea.placeObjects(player)
    SpawnArea.placeLamps(player)
    SpawnArea.placePowerPoles(player)
    SpawnArea.addBonusPlayerItems(player)

    if(SpawnArea.DO_PLACE_CHESTS) then
        SpawnArea.placeChests(player)
    end

    if(SpawnArea.DO_PLACE_TURRETS) then
        SpawnArea.placeTurrets(player)
    end

    if(SpawnArea.DO_PLACE_ROBOPORT) then
        SpawnArea.placeRoboport(player)
        SpawnArea.placeLogisticStorage(player)
    end
end

-- @param player LuaPlayer
function SpawnArea.placeLamps(player)
    local locations = {
        {-3, -3},
        {2, -3},
        -- === --
        {-3, 2},
        {2, 2},
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

-- @param player LuaPlayer
function SpawnArea.placePowerPoles(player)
    local locations = {
        {-4, -4},
        {3, -4},
        -- === --
        {-4, 3},
        {3, 3},
    }

    for i, value in ipairs(locations) do
        local entity = player.surface.create_entity({
            name=SpawnArea.POWER_POLE_TYPE,
            position=value,
            force=game.forces.player
        })
    end
end

-- @param player LuaPlayer
function SpawnArea.addBonusPlayerItems(player)
    SpawnArea.insertItemsIntoEntity(player, SpawnArea.INCLUDE_PLAYER_ITEMS)
end

-- @param player LuaPlayer
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

    for i, value in ipairs(locations) do
        local entity = player.surface.create_entity({
            name='gun-turret',
            position=value,
            force=game.forces.player
        })
        entity.insert(SpawnArea.INCLUDE_TURRET_AMMO)
    end
end

-- @param player LuaPlayer
function SpawnArea.placeRoboport(player)
    local entity = player.surface.create_entity({
        name='roboport',
        position={7, -7},
        force=game.forces.player
    })
    SpawnArea.insertItemsIntoEntity(entity, SpawnArea.INCLUDE_ROBOPORT_ITEMS)
end

-- @param player LuaPlayer
function SpawnArea.placeLogisticStorage(player)
    local entity = player.surface.create_entity({
        name='logistic-chest-storage',
        position={5, -5},
        force=game.forces.player
    })
    SpawnArea.insertItemsIntoEntity(entity, SpawnArea.INCLUDE_CHEST_ITEMS)
end

-- @param player LuaPlayer
function SpawnArea.placeChests(player)
    local locations = {
        {-2, -2},
        {1, -2},
        -- === --
        {-2, 1},
        {1, 1},
    }

    for i, value in ipairs(locations) do
        local entity = player.surface.create_entity({
            name='wooden-chest',
            position=value,
            force=game.forces.player
        })
        SpawnArea.insertItemsIntoEntity(entity, SpawnArea.INCLUDE_CHEST_ITEMS)
    end
end


-- @param entity Valid entity to add items to (LuaPlayer, chest, roboport etc..)
-- @param items List of {name = 'name', count = 0}
function SpawnArea.insertItemsIntoEntity(entity, items)
    for j, item in ipairs(items) do
        entity.insert(item)
    end
end
