-- For Testing Soft Module
-- Gives player a bunch of items on creation for testing
-- TODO: Change to chests?
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --

-- Constants --
-- ======================================================= --
DevSandbox = {}

-- Event Functions --
-- ======================================================= --
--- Various action when new player joins in game
--- @param event defines.events.on_player_created event
function DevSandbox.on_player_created(event)
    local player = game.players[event.player_index]
    player.print('Testing Script, player recieves a buncha items!')

    DevSandbox.unlockTech(player)

    DevSandbox.giveArmorMK2(player)
    DevSandbox.giveSolarPowerItems(player)
    -- DevSandbox.giveRoboItems(player)
    -- DevSandbox.giveMiningItems(player)
    -- DevSandbox.giveLogisticItems(player)
    -- DevSandbox.giveSpeedItems(player)
    -- DevSandbox.giveTrainItems(player)
    -- DevSandbox.giveTileItems(player)
    DevSandbox.giveMilitaryItems(player)
    -- DevSandbox.giveDefenceItems(player)
end


-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_created, DevSandbox.on_player_created)

-- Helper Functions --
-- ======================================================= --

--- @param player LuaPlayer
function DevSandbox.unlockTech(player)
    player.force.research_all_technologies()
    -- player.force.technologies['steel-processing'].researched = true
end


--- @param player LuaPlayer
function DevSandbox.giveArmorMK2(player)
    local pia = player.get_inventory(defines.inventory.character_armor)
    pia.insert({name = 'power-armor-mk2', count = 1})
    local armor = pia.find_item_stack('power-armor-mk2')

    armor.grid.put {name = 'fusion-reactor-equipment'}
    armor.grid.put {name = 'fusion-reactor-equipment'}
    armor.grid.put {name = 'battery-mk2-equipment'}
    armor.grid.put {name = 'battery-mk2-equipment'}
    armor.grid.put {name = 'exoskeleton-equipment'}
    armor.grid.put {name = 'exoskeleton-equipment'}
    armor.grid.put {name = 'exoskeleton-equipment'}
    armor.grid.put {name = 'exoskeleton-equipment'}
    armor.grid.put {name = 'exoskeleton-equipment'}
    armor.grid.put {name = 'exoskeleton-equipment'}
    -- armor.grid.put{name='energy-shield-mk2-equipment'}
    -- armor.grid.put{name='energy-shield-mk2-equipment'}
    armor.grid.put {name = 'personal-roboport-mk2-equipment'}
    armor.grid.put {name = 'personal-roboport-mk2-equipment'}
    armor.grid.put {name = 'personal-roboport-mk2-equipment'}
    armor.grid.put {name = 'personal-roboport-mk2-equipment'}

    player.insert {name = 'fusion-reactor-equipment', count = 2}
    player.insert {name = 'personal-roboport-mk2-equipment', count = 5}
    player.insert {name = 'exoskeleton-equipment', count = 5}
    player.insert {name = 'battery-mk2-equipment', count = 4}
    player.insert {name = 'construction-robot', count = 100}

    player.insert {name = 'deconstruction-planner', count = 1}
    player.insert {name = 'blueprint', count = 1}
end


--- @param player LuaPlayer
function DevSandbox.giveRoboItems(player)
    player.insert {name = 'construction-robot', count = 400}
    player.insert {name = 'logistic-robot', count = 200}
    player.insert {name = 'logistic-chest-storage', count = 100}
    player.insert {name = 'logistic-chest-storage', count = 100}
    player.insert {name = 'logistic-chest-passive-provider', count = 100}
    player.insert {name = 'logistic-chest-buffer', count = 100}
    player.insert {name = 'logistic-chest-active-provider', count = 100}
end


--- @param player LuaPlayer
function DevSandbox.giveSolarPowerItems(player)
    local COUNT = 1
    local SOLAR_BP_ITEMS = {
        SOLAR_PANELS = 180 * COUNT,
        ACCUMULATORS = 151 * COUNT,
        LAMPS = 4 * COUNT,
        ROBOPORTS = 1 * COUNT,
        SUBSTATIONS = 16 * COUNT
    }

    player.insert {name = 'solar-panel', count = SOLAR_BP_ITEMS.SOLAR_PANELS}
    player.insert {name = 'accumulator', count = SOLAR_BP_ITEMS.ACCUMULATORS}
    player.insert {name = 'small-lamp', count = SOLAR_BP_ITEMS.LAMPS}
    player.insert {name = 'roboport', count = SOLAR_BP_ITEMS.ROBOPORTS}
    player.insert {name = 'substation', count = SOLAR_BP_ITEMS.SUBSTATIONS}
end


--- @param player LuaPlayer
function DevSandbox.giveMiningItems(player)
    player.insert {name = 'electric-mining-drill', count = 50}
    player.insert {name = 'medium-electric-pole', count = 50}
end


--- @param player LuaPlayer
function DevSandbox.giveLogisticItems(player)
    player.insert {name = 'stack-inserter', count = 50}
    player.insert {name = 'express-loader', count = 50}
    player.insert {name = 'express-underground-belt', count = 50}
    player.insert {name = 'express-splitter', count = 50}
    player.insert {name = 'express-transport-belt', count = 400}
end


--- @param player LuaPlayer
function DevSandbox.giveSpeedItems(player)
    player.insert {name = 'speed-module-3', count = 300}
    player.insert {name = 'productivity-module-3', count = 300}
    player.insert {name = 'beacon', count = 50}
end


--- @param player LuaPlayer
function DevSandbox.giveTrainItems(player)
    player.insert {name = 'locomotive', count = 20}
    player.insert {name = 'cargo-wagon', count = 20}
    player.insert {name = 'fluid-wagon', count = 10}
    player.insert {name = 'rail', count = 400}
    player.insert {name = 'train-stop', count = 10}
    player.insert {name = 'rail-signal', count = 50}
    player.insert {name = 'chain-signal', count = 50}
end


--- @param player LuaPlayer
function DevSandbox.giveTileItems(player)
    player.insert {name = 'stone-brick', count = 200}
    player.insert {name = 'concrete', count = 200}
    player.insert {name = 'hazard-concrete', count = 100}
    player.insert {name = 'refined-concrete', count = 200}
    player.insert {name = 'refined-hazard-concrete', count = 100}
end


--- @param player LuaPlayer
function DevSandbox.giveMilitaryItems(player)
    player.insert {name = 'submachine-gun', count = 1}
    player.insert {name = 'uranium-rounds-magazine', count = 100}

    player.insert {name = 'grenade', count = 50}
    player.insert {name = 'cluster-grenade', count = 50}
    player.insert {name = 'land-mine', count = 50}

    player.insert {name = 'flamethrower', count = 1}
    player.insert {name = 'flamethrower-ammo', count = 50}

    player.insert {name = 'combat-shotgun', count = 1}
    player.insert {name = 'piercing-shotgun-shell', count = 100}

    player.insert {name = 'tank', count = 1}
    player.insert {name = 'uranium-cannon-shell', count = 50}

    player.insert {name = 'radar', count = 20}
end


--- @param player LuaPlayer
function DevSandbox.giveDefenceItems(player)
    player.insert {name = 'stone-wall', count = 100}
    player.insert {name = 'gate', count = 50}

    player.insert {name = 'gun-turret', count = 50}
    player.insert {name = 'laser-turret', count = 50}
    player.insert {name = 'flamethrower-turret', count = 50}
end

