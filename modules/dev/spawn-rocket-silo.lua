--[[
rocket_test.lua

This was created to test the 'score' mod.
Needed a fast way to launch a rocket in a controlled environment.
This generates a space around the player which will create a silo, inserters,
chests, and some related solar power to build & launch a rocket in a short time.

Copyright 2017-2018 "Kovus" <kovus@soulless.wtf>

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--]]

require 'util'

function clearSpace()
	local radius = 100
    local surface = game.surfaces[1]
    local grass = get_walkable_tile()

	-- clear trees and landfill in start area
	local start_area = {left_top = {0-radius, 0-radius}, right_bottom = {radius, radius}}
	for _, e in pairs(surface.find_entities_filtered{area=start_area, type="tree"}) do
		e.destroy()
	end
	for _, e in pairs(surface.find_entities_filtered{area=start_area, type="stone-rock"}) do
		e.destroy()
	end
	for i = -radius, radius, 1 do
		for j = -radius, radius, 1 do
			if (surface.get_tile(i,j).collides_with("water-tile")) then
				surface.set_tiles{{name = grass, position = {i,j}}}
			end
		end
	end
end

function silo()
	local surface = game.surfaces[1]
	local player = game.players[1]
	local force = player.force

	local silo_location = {x = player.position.x-11, y = player.position.y}

	local silo = surface.create_entity{name="rocket-silo", position=silo_location, force=force}

	silo.get_module_inventory().insert{name='productivity-module-3', count=4}

	local position = {}
	local item
	-- add a couple substations
	position.x = silo_location.x + 8
	position.y = silo_location.y
	item = surface.create_entity{name="substation", position=position, force=force}
	position.x = silo_location.x + 14
	position.y = silo_location.y
	item = surface.create_entity{name="substation", position=position, force=force}

	-- add chests with items (3 of each type of resource)
	for idx=0,2 do
		position.x = silo_location.x+5
		position.y = silo_location.y-5 + idx
		item = surface.create_entity{name="stack-inserter", position=position, direction=defines.direction.east, force=force}
		position.x = silo_location.x+6
		position.y = silo_location.y-5 + idx
		item = surface.create_entity{name="steel-chest", position=position, force=force}
		item.insert{name='low-density-structure', count=480}
	end
	for idx=3,5 do
		position.x = silo_location.x+5
		position.y = silo_location.y-5 + idx
		item = surface.create_entity{name="stack-inserter", position=position, direction=defines.direction.east, force=force}
		position.x = silo_location.x+6
		position.y = silo_location.y-5 + idx
		item = surface.create_entity{name="steel-chest", position=position, force=force}
		item.insert{name='rocket-fuel', count=480}
	end
	for idx=6,8 do
		position.x = silo_location.x+5
		position.y = silo_location.y-5 + idx
		item = surface.create_entity{name="stack-inserter", position=position, direction=defines.direction.east, force=force}
		position.x = silo_location.x+6
		position.y = silo_location.y-5 + idx
		item = surface.create_entity{name="steel-chest", position=position, force=force}
		item.insert{name='rocket-control-unit', count=480}
	end
	for idx=9, 9 do
		position.x = silo_location.x+5
		position.y = silo_location.y-5 + idx
		item = surface.create_entity{name="stack-inserter", position=position, direction=defines.direction.east, force=force}
		position.x = silo_location.x+6
		position.y = silo_location.y-5 + idx
		item = surface.create_entity{name="steel-chest", position=position, force=force}
		item.insert{name='satellite', count=2}
	end
end

function solararray()
	local array_count = 1
	local surface = game.surfaces[1]
	local player = game.players[1]
	local force = player.force

	local array_start_location = {x = player.position.x+8, y = player.position.y-10}

	-- insert panels
	for idx = 0, 6 do
		for jdx = 0, 6 do
			if idx == 3 and jdx == 3 then
				-- skip this.
			else
				position = {}
				position.x = array_start_location.x + (3 * idx)
				position.y = array_start_location.y + (3 * jdx)
				local panel = surface.create_entity{name="solar-panel", position=position, force=force}
			end
		end
	end
	-- insert a substation in the center.
	position = {}
	position.x = array_start_location.x + 9
	position.y = array_start_location.y + 9
	local subst = surface.create_entity{name="substation", position=position, force=force}
end

function accarray()
	local array_count = 1
	local surface = game.surfaces[1]
	local player = game.players[1]
	local force = player.force

	local array_start_location = {x = player.position.x+31, y = player.position.y-10}

	-- insert panels
	for idx = 0, 8 do
		for jdx = 0, 8 do
			if idx == 4 and jdx == 4 then
				-- skip this.
			else
				position = {}
				position.x = array_start_location.x + (2 * idx)
				position.y = array_start_location.y + (2 * jdx)
				local panel = surface.create_entity{name="accumulator", position=position, force=force}
			end
		end
	end
	-- insert a substation in the center.
	position = {}
	position.x = array_start_location.x + 8
	position.y = array_start_location.y + 8
	local subst = surface.create_entity{name="substation", position=position, force=force}
	-- insert a substation on the left to connect it up to the solar array
	position = {}
	position.x = array_start_location.x - 2
	position.y = array_start_location.y + 10
	local subst = surface.create_entity{name="substation", position=position, force=force}
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

Event.register(defines.events.on_player_joined_game,
function(event)
	clearSpace()
	silo()
	solararray()
	accarray()
end)

