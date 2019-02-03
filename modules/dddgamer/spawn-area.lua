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
local PLACE_TILES = true
local PLACE_OBJECTS = true

-- Event Functions --
-- ======================================================= --

-- Various action when new player joins in game
-- @param event on_player_created event
function on_player_created(event)
    local player = game.players[event.player_index]

    if (PLACE_TILES and not global.spawn_tiles_placed) then
        place_tiles_in_spawn(player)
        if(PLACE_OBJECTS) then
            place_objects(player)
        end
        global.spawn_tiles_placed = true
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_created, on_player_created)

-- Helper Functions --
-- ======================================================= --

-- Draws tiles around the spawned player if they havnt been already
-- @param player LuaPlayer
function place_tiles_in_spawn(player)
    local spawn_position = player.force.get_spawn_position(player.surface)
    local tile_concrete = 'refined-concrete'
    local tile_concrete_paint = 'hazard-concrete-left'
    local tile_brick = 'stone-path'

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
    local t2 = {
        {-2, 3},
        {3, 3},
        -- === --
        {-2, -2},
        {3, -2}
    }
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
            name = tile_concrete_paint,
            position = {value[1] + OFFSET.x, value[2] + OFFSET.y}
        }
        table.insert(marked_corners, tile)
    end

    -- Path tiles
    for i, value in ipairs(t1) do
        local tile = {
            name = tile_concrete,
            position = {value[1] + OFFSET.x, value[2] + OFFSET.y}
        }
        table.insert(marked_area_inner, tile)
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
    --                 name = tile_concrete_paint,
    --                 position = {spawn_position.x + x, spawn_position.y + y}
    --             }
    --         else
    --             -- Inner tiles
    --             tile = {
    --                 name = tile_concrete,
    --                 position = {spawn_position.x + x, spawn_position.y + y}
    --             }
    --         end
    --         table.insert(marked_area_outer, tile)
    --     end
    -- end

    set_tiles_safe(player.surface, marked_area_outer)
    set_tiles_safe(player.surface, marked_area_inner)
    set_tiles_safe(player.surface, marked_corners)
end

-- Sets tile area to a walkable surface (e.g. grass) first, then resets that to the tile passed in
-- @param surface - LuaSurface to set tiles on
-- @param tiles - array of LuaTile
function set_tiles_safe(surface, tiles)
    local grass = get_walkable_tile()
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
function get_walkable_tile()
    for name, tile in pairs(game.tile_prototypes) do
        if tile.collision_mask['player-layer'] == nil and not tile.items_to_place_this then
            return name
        end
    end
    error('No walkable tile in prototype list')
end

-- Place lamps, and trash chests
-- @param player LuaPlayer
function place_objects(player)

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

    --  place lamps on the hazard concrete created earlier
    for i, value in ipairs(t2_lamps) do
        player.surface.create_entity{
            name='small-lamp',
            position=value,
            force=game.forces.player
        }
    end

    -- Place medium power poles next to lamps
    for i, value in ipairs(t2_poles) do
        player.surface.create_entity{
            name='medium-electric-pole',
            position=value,
            force=game.forces.player
        }
    end

    -- Place trash chests next to poles
    for i, value in ipairs(t2_boxes) do
        player.surface.create_entity{
            name='wooden-chest',
            position=value,
            force=game.forces.player
        }
    end
end
