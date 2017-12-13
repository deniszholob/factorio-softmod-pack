--Gravestone [based on Hazzard's Gravestone Mod]
--A 3Ra Gaming revision
--[[ list of inventories to save - constants from api reference]] --
local storeinventories = {
	defines.inventory.player_vehicle,
	defines.inventory.player_armor,
	defines.inventory.player_tools,
	defines.inventory.player_guns,
	defines.inventory.player_ammo,
	defines.inventory.player_quickbar,
	defines.inventory.player_main,
	defines.inventory.player_trash,
}

--[[ name of inventories to print on report ]] --
local storeinventoriesstring = {
	"Vehicle",
	"Armor",
	"Tools",
	"Guns",
	"Ammo",
	"Quickbar",
	"Main",
	"Trash",
}

local save_craft_queue = true

local function spawn_chest(player, chestname)
	local savechest = nil
	if player ~= nil then
		local playersurface = game.surfaces[player.surface.name]
		if playersurface ~= nil then
			local chestposition = playersurface.find_non_colliding_position("steel-chest", player.position, 100, 1)
			if chestposition ~= nil then
				savechest = playersurface.create_entity({
					name = chestname,
					position = chestposition,
					force = game.forces.neutral
				})
				if savechest ~= nil then
					savechest.destructible = false
					savechest.last_user = player
				end
			end
		end
	end
	return savechest
end

local function on_player_died(event)
	local player = game.players[event.player_index]
	if player ~= nil then
		local transfered = 0
		local chestId = 1
		local savechest = spawn_chest(player, "steel-chest")
		if savechest ~= nil then
			local chestinventory = savechest.get_inventory(defines.inventory.chest)

			--[[ save all predefined inventories ]] --
			for i = 1, #storeinventories, 1 do
				local inventoryid = storeinventories[i]
				local playerinventory = player.get_inventory(inventoryid)
				if playerinventory ~= nil and chestinventory ~= nil then
					player.print("Storing items from inventory '" .. storeinventoriesstring[i] .. "(" .. tostring(inventoryid) .. ")' to chest #" .. tostring(chestId))
					--[[ Get all items in current inventory ]] --
					for j = 1, #playerinventory, 1 do
						local inserted = 0
						if playerinventory[j].valid and playerinventory[j].valid_for_read then
							local item = playerinventory[j]
							if storeinventories[i] == defines.inventory.player_guns and item.name == "pistol" then
								--[[ Do nothing, do not store a pistol in the chest. Prevents infinite pistols (Although who the hell would abuse that anyway) ]] --
							else
								if storeinventories[i] == defines.inventory.player_ammo and item.name == "firearm-magazine" then
									if item.count > 10 then
										item.count = item.count - 10
									end
								end
								if chestinventory ~= nil and chestinventory.can_insert(item) then
									inserted = chestinventory.insert(item)
									transfered = transfered + 1
								else --[[ If item cannot be inserted into current chest, create new chest]] --
									savechest = spawn_chest(player, "steel-chest")
									chestinventory = nil
									if savechest ~= nil then
										chestinventory = savechest.get_inventory(defines.inventory.chest)
										if chestinventory ~= nil then
											inserted = chestinventory.insert(item)
											transfered = transfered + 1
											chestId = chestId + 1
											player.print("Storing items from inventory '" .. storeinventoriesstring[i] .. "(" .. tostring(inventoryid) .. ")' to chest #" .. tostring(chestId))
										end
									else --[[ break if unable to spawn new chest ]] --
										break
									end
								end
								--[[ If the entire item stack was not inserted, decrease the count and add the remainder into a new chest]] --
								if item.count > inserted then
									item.count = item.count - inserted
									savechest = spawn_chest(player, "steel-chest")
									chestinventory = nil
									if savechest ~= nil then
										chestinventory = savechest.get_inventory(defines.inventory.chest)
										if chestinventory ~= nil then
											inserted = chestinventory.insert(item)
											transfered = transfered + 1
											chestId = chestId + 1
											player.print("Storing items from inventory '" .. storeinventoriesstring[i] .. "(" .. tostring(inventoryid) .. ")' to chest #" .. tostring(chestId))
										end
									else --[[ break if unable to spawn new chest ]] --
										break
									end
								end
							end

							if item.grid then
								for k = 1, #chestinventory, 1 do
									local itemstack = chestinventory[k]
									if itemstack.valid and itemstack.valid_for_read and itemstack.grid and itemstack.name == item.name and next(itemstack.grid.equipment) == nil then
										local fail = false
										for _,equip in ipairs(item.grid.equipment) do
											local name = equip.name
											local pos = equip.position
											if not itemstack.grid.put{name = name, position = pos} then fail = true end
										end
										if fail then player.print("Failed to save modules for armor " + item.name) end
										break
									end
								end
							end

							if item.name == "blueprint" and item.is_blueprint_setup() then
								for k = 1, #chestinventory, 1 do
									local chestitem = chestinventory[k]
									if chestitem.valid and chestitem.valid_for_read and chestitem.name == "blueprint" and (not chestitem.is_blueprint_setup()) then
										chestitem.set_blueprint_entities(item.get_blueprint_entities())
										chestitem.set_blueprint_tiles(item.get_blueprint_tiles())
										chestitem.blueprint_icons = item.blueprint_icons
										if item.label then
											chestitem.label = item.label
										end
										if chestitem.label_color then
											chestitem.label_color = item.label_color
										end
										break;
									end
								end
							end

						end
					end --[[ end for #playerinventory ]] --
				else --[[ break if unable to spawn new chest ]] --
				if savechest == nil then
					break
				end
				end
			end --[[ end for #storeinventories ]] --
			if savechest ~= nil then
				if savechest.get_inventory(defines.inventory.chest).is_empty() then
					savechest.destroy()
				end
			end

			--[[ save craft queue ]] --
			if save_craft_queue == true then
				local maininventory = player.get_inventory(defines.inventory.player_main)
				local toolbar = player.get_inventory(defines.inventory.player_quickbar)
				local queue = player.crafting_queue
				local craftchestId = 1
				local crafttransfered = 0
				if maininventory ~= nil and toolbar ~= nil and #queue > 0 then
					savechest = spawn_chest(player, "steel-chest")
					if savechest ~= nil then
						chestitems = 0
						--[[ canceled queue mats are dropped to main inventory ]] --
						maininventory.clear()
						--[[ complete products, even if they are intermediate are dropped into toolbar, if they are placeable - eg. factories for example ]] --
						toolbar.clear()
						chestinventory = savechest.get_inventory(defines.inventory.chest)
						local cnt = player.crafting_queue_size
						while cnt > 0 do
							local craftitem = queue[cnt]
							player.print("Canceling craft of " .. tostring(craftitem.count) .. " piece(s) of " .. craftitem.recipe .. " , index #" .. tostring(craftitem.index))
							local cancelparam = { index = craftitem.index, count = craftitem.count }
							player.cancel_crafting(cancelparam)
							--[[ canceling craft cancels also intermediate crafts ]] --
							cnt = player.crafting_queue_size
						end
						player.print("Storing items from queue to craft chest #" .. tostring(craftchestId))
						for j = 1, #maininventory, 1 do
							if maininventory[j].valid and maininventory[j].valid_for_read then
								local item = maininventory[j]

								if chestinventory ~= nill and chestinventory.can_insert(item) then
									chestitems = chestitems + 1
									chestinventory[chestitems].set_stack(item)
									crafttransfered = crafttransfered + 1
								else
									savechest = spawn_chest(player, "steel-chest")
									if savechest ~= nil then
										chestitems = 0
										chestinventory = savechest.get_inventory(1)
										if chestinventory ~= nil then
											chestitems = 1
											chestinventory[chestitems].set_stack(item)
											crafttransfered = crafttransfered + 1
											craftchestId = craftchestId + 1
											player.print("Storing items from queue to craft chest #" .. tostring(craftchestId))
										end
									else --[[ break if unable to spawn new chest ]] --
									break
									end
								end
							end
						end --[[ end for #maininventory ]] --
						for j = 1, #toolbar, 1 do
							if toolbar[j].valid and toolbar[j].valid_for_read then
								local item = toolbar[j]

								if chestinventory ~= nil and chestinventory.can_insert(item) then
									chestitems = chestitems + 1
									chestinventory[chestitems].set_stack(item)
									crafttransfered = crafttransfered + 1
								else
									savechest = spawn_chest(player, "steel-chest")
									if savechest ~= nil then
										chestitems = 0
										chestinventory = savechest.get_inventory(1)
										if chestinventory ~= nil then
											chestitems = 1
											chestinventory[chestitems].set_stack(item)
											crafttransfered = crafttransfered + 1
											craftchestId = craftchestId + 1
											player.print("Storing items from queue to craft chest #" .. tostring(craftchestId))
										end
									else --[[ break if unable to spawn new chest ]] --
									break
									end
								end
							end
						end --[[ end for #toolbar ]] --
					end
				end
				local message = "No  craft queue items were saved"
				if crafttransfered > 0 then
					message = "Saved " .. tostring(crafttransfered) .. " craft queue item(s) into " .. tostring(craftchestId) .. " craft box(es)"
				end
				player.print(message)
			end
		end

		local message = "No stacks were saved"
		if transfered > 0 then
			message = "Saved " .. tostring(transfered) .. " stack(s) into " .. tostring(chestId) .. " box(es)"
		end
		player.print(message)
	end
end

local function on_pre_player_died(event)
	local player = game.players[event.player_index]
	player.clean_cursor()
end

Event.register(defines.events.on_pre_player_died, on_pre_player_died)
Event.register(defines.events.on_player_died, on_player_died)
