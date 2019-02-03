-- Floating Health Soft Mod
-- Show the health of a player as a small piece of colored text above their head
-- @usage require('modules/common/floating-health')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
require 'util/Colors'

-- Constants --
-- ======================================================= --
-- Max player Health is 250 as of v0.15 (changed from 100 in v0.14)
-- player.character.prototype.max_health
local MAX_PLAYER_HP = 250

-- Event Functions --
-- ======================================================= --

-- On tick go through all the players and see if need to display health text
-- @param event on_tick
local function on_tick(event)
    -- Show every half second
    if game.tick % 30 ~= 0 then
        return
    end

    -- For every player thats online...
    for i, player in pairs(game.connected_players) do
        if player.character then
            -- Exit if player character doesnt have health
            if player.character.health == nil then
                return
            end
            local health = math.ceil(player.character.health)
            -- Set up global health var if doesnt exist
            if global.player_health == nil then
                global.player_health = {}
            end
            if global.player_health[player.name] == nil then
                global.player_health[player.name] = health
            end
            -- If mismatch b/w global and current hp, display hp text
            if global.player_health[player.name] ~= health then
                global.player_health[player.name] = health
                show_player_health(player, health)
            end
        end
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_tick, on_tick)

-- Helper Functions --
-- ======================================================= --

-- Draws different color health # above the player based on HP value
-- @param player LuaPlayer
-- @param health
function show_player_health(player, health)
    local max_hp = player.character.prototype.max_health-- or MAX_PLAYER_HP
    if health <= percent_to_hp(30, max_hp) then
        draw_flying_text(player, Colors.red, hp_to_percent(health, max_hp) .. '%')
    elseif health <= percent_to_hp(50, max_hp) then
        draw_flying_text(player, Colors.yellow, hp_to_percent(health, max_hp) .. '%')
    elseif health <= percent_to_hp(80, max_hp) then
        draw_flying_text(player, Colors.green, hp_to_percent(health, max_hp) .. '%')
    end
end

-- Draws text above the player
-- @param player LuaPlayer
-- @param t_color <- text color (rgb)
-- @param t_text  <- text to display (string)
function draw_flying_text(player, t_color, t_text)
    player.surface.create_entity {
        name = 'flying-text',
        color = t_color,
        text = t_text,
        position = {player.position.x, player.position.y - 2}
    }
end

-- Returns an HP value from apercentage
-- @param val - HP number to convert to Percentage
-- @param max_hp - Maximum Hp to calc percentage of
function hp_to_percent(val, max_hp)
    return math.ceil(100 / max_hp * val)
end

-- Returns HP as a percentage instead of raw number
-- @param val - Percentage number to convert to HP
-- @param max_hp - Maximum Hp to calc percentage of
function percent_to_hp(val, max_hp)
    return math.ceil(max_hp / 100 * val)
end
