--Undecorator
--A 3Ra Gaming creation
--removes decorations on the map to reduce stress on players computers
local CHUNK_SIZE = 32

-- Remove decorations in a given area
-- @param surface target surface
-- @param area area to clear decorations within
local function removeDecorationsArea(surface, area)
	for _, entity in pairs(surface.find_entities_filtered { area = area, type = "decorative" }) do
		entity.destroy()
	end
end

--this fires whenever new chunks are generated.
Event.register(defines.events.on_chunk_generated, function(event)
	removeDecorationsArea(event.surface, event.area)
end)
--the rest only triggers if they've never been removed before on whichever map is loaded.

-- Clean parameters for removeDecorationsArea function
-- @param surface target surface
-- @param x bottom left x coordinate
-- @param y bottom left y coordinate
-- @param width width of area
-- @param height height of area
local function removeDecorations(surface, x, y, width, height)
	removeDecorationsArea(surface, { { x, y }, { x + width, y + height } })
end

-- Clear all decorations on the map.
local function clearDecorations()
	local surface = game.surfaces["nauvis"]
	for chunk in surface.get_chunks() do
		removeDecorations(surface, chunk.x * CHUNK_SIZE, chunk.y * CHUNK_SIZE, CHUNK_SIZE - 1, CHUNK_SIZE - 1)
	end

	game.print("Decorations removed")
end

-- If the map hasn't been scanned already, clear it
-- @param event on_tick event
function full_clear(event)
	if not global.fullClear then
		clearDecorations()
		global.fullClear = true
	end

	Event.remove(defines.events.on_tick, full_clear)
end

Event.register(defines.events.on_tick, full_clear)
