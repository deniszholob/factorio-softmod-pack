-- Player Init Soft Module
-- Vanilla code modified with Event registration and structured more
-- @usage require('modules/vanilla/player-init')
-- ------------------------------------------------------- --
-- @author Factorio Devs
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Event Functions --
-- ======================================================= --

-- Give player starting items.
-- @param event on_player_created event
function on_player_created(event)
    local player = game.players[event.player_index]
    player.insert {name = 'iron-plate', count = 8}
    player.insert {name = 'pistol', count = 1}
    player.insert {name = 'firearm-magazine', count = 10}
    player.insert {name = 'burner-mining-drill', count = 1}
    player.insert {name = 'stone-furnace', count = 1}
    reveal_area(player)
    showScenarioMsg(player)
end

-- Give player weapons after they respawn.
-- @param event on_player_respawned event
function on_player_respawned(event)
    local player = game.players[event.player_index]
    player.insert {name = 'pistol', count = 1}
    player.insert {name = 'firearm-magazine', count = 10}
end

-- Helper Functions --
-- ======================================================= --

-- Reveal area around the player
-- @param player LuaPlayer
function reveal_area(player)
    player.force.chart(
        player.surface,
        {
            {player.position.x - 200, player.position.y - 200},
            {player.position.x + 200, player.position.y + 200}
        }
    )
end

-- Shows vanilla game goal
-- @param player LuaPlayer
function showScenarioMsg(player)
    if (#game.players <= 1) then
        game.show_message_dialog {text = {'msg-intro'}}
    else
        player.print({'msg-intro'})
    end
end

-- Event Registration
-- ======================================================= --
Event.register(defines.events.on_player_created, on_player_created)
Event.register(defines.events.on_player_respawned, on_player_respawned)
