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

-- If enabled, places concrete/brick tiles at the spawn area to mark it
local Spawn_Area = {
    PLACE_TILES = true,
    PLACE_OBJECTS = true,
    POWER_POLE_TYPE = "medium-electric-pole", -- "small-electric-pole", "medium-electric-pole", "big-electric-pole"
    ADD_ROBOTS = true,
    ROBOT_COUNT = 20,
    ADD_TURRETS = true,
    TURRET_AMMO_COUNT = 4, -- per turret
    INCLUDE_CLIFF_EXPLOSIVES = true,
    EXPLOSIVES_COUNT = 2, -- per chest
}

-- Event Functions --
-- ======================================================= --

-- Various action when new player joins in game
-- @param event on_player_created event
function Spawn_Area.on_player_created(event)
    local player = game.players[event.player_index]

    if (Spawn_Area.PLACE_TILES and not global.spawn_area_created) then
        Spawn_Area.place_tiles_in_spawn(player)
        if(Spawn_Area.PLACE_OBJECTS) then
            Spawn_Area.place_objects(player)
        end
        global.spawn_area_created = true
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_created, Spawn_Area.on_player_created)

-- Helper Functions --
-- ======================================================= --

-- Draws tiles around the spawned player if they havnt been already
-- @param player LuaPlayer
function Spawn_Area.place_tiles_in_spawn(player)
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

    Spawn_Area.set_tiles_safe(player.surface, marked_area_outer)
    Spawn_Area.set_tiles_safe(player.surface, marked_area_inner)
    Spawn_Area.set_tiles_safe(player.surface, marked_corners)
end

-- Sets tile area to a walkable surface (e.g. grass) first, then resets that to the tile passed in
-- @param surface - LuaSurface to set tiles on
-- @param tiles - array of LuaTile
function Spawn_Area.set_tiles_safe(surface, tiles)
    local grass = Spawn_Area.get_walkable_tile()
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
function Spawn_Area.get_walkable_tile()
    for name, tile in pairs(game.tile_prototypes) do
        if tile.collision_mask['player-layer'] == nil and not tile.items_to_place_this then
            return name
        end
    end
    error('No walkable tile in prototype list')
end

-- Place lamps, and trash chests
-- @param player LuaPlayer
function Spawn_Area.place_objects(player)

    local t2_lamps = {
        {-3, -3},
        {2, -3},
        -- === --
        {-3, 2},
        {2, 2},
    }

    local t2_poles = {
        {-4, -4},
        {3, -4},
        -- === --
        {-4, 3},
        {3, 3},
    }

    local t2_boxes = {
        {-2, -2},
        {1, -2},
        -- === --
        {-2, 1},
        {1, 1},
    }

    local obj_turrets = {
        {2, 4},
        {4, 2},
        {-2, 4},
        {-4, 2},
        {2, -4},
        {4, -2},
        {-2, -4},
        {-4, -2},
    }

    if(Spawn_Area.ADD_ROBOTS) then
        local entity = player.surface.create_entity{
            name='roboport',
            position={7, -7},
            force=game.forces.player
        }
        entity.insert{name = 'construction-robot', count = Spawn_Area.ROBOT_COUNT}
        
        local entity = player.surface.create_entity{
            name='logistic-chest-storage',
            position={5, -5},
            force=game.forces.player
        }
    end

    if(Spawn_Area.ADD_TURRETS) then
        for i, value in ipairs(obj_turrets) do
            local entity = player.surface.create_entity{
                name='gun-turret',
                position=value,
                force=game.forces.player
            }
            entity.insert{name = 'firearm-magazine', count = Spawn_Area.TURRET_AMMO_COUNT}
        end
    end

    --  place lamps on the hazard concrete created earlier
    for i, value in ipairs(t2_lamps) do
        local entity = player.surface.create_entity{
            name='small-lamp',
            position=value,
            force=game.forces.player
        }
        entity.destructible = false
        entity.minable = false
    end

    -- Place medium power poles next to lamps
    for i, value in ipairs(t2_poles) do
        local entity = player.surface.create_entity{
            name=Spawn_Area.POWER_POLE_TYPE,
            position=value,
            force=game.forces.player
        }
    end

    -- Place trash chests next to poles
    for i, value in ipairs(t2_boxes) do
        local entity = player.surface.create_entity{
            name='wooden-chest',
            position=value,
            force=game.forces.player
        }
        if(Spawn_Area.INCLUDE_CLIFF_EXPLOSIVES) then
            entity.insert{name = 'cliff-explosives', count = Spawn_Area.EXPLOSIVES_COUNT}
        end
    end
end
