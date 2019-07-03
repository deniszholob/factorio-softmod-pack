-- Evolution Soft Module
-- __Description__
-- Uses locale Evolution.cfg
-- @usage require('modules/common/Evolution')
-- @usage local ModuleName = require('modules/common/Evolution')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local GUI = require('stdlib/GUI')
local Styles = require('util/Styles')
local Sprites = require("util/Sprites")
local Time = require("util/Time")
local Math = require("util/Math")

-- Constants --
-- ======================================================= --
Evolution = {
    MASTER_FRAME_NAME = 'frame_Evolution',
    EVOLUTION_SPRITE_NAME = 'sprite_Evolution',
    EVOLUTION_LABEL_NAME = 'lbl_Evolution',
    EVOLUTION_SPRITES = {
        [0] = Sprites.small_biter,
        [0.21] = Sprites.medium_biter,
        [0.26] = Sprites.small_spitter,
        [0.41] = Sprites.medium_spitter,
        [0.50] = Sprites.big_biter,
        [0.51] = Sprites.big_spitter,
        [0.90] = Sprites.behemoth_biter,
        [0.91] = Sprites.behemoth_spitter,
    },
    get_master_frame = function(player)
        return GUI.menu_bar_el(player)[Evolution.MASTER_FRAME_NAME]
    end
}

-- Event Functions --
-- ======================================================= --
-- When new player joins add a btn to their menu bar
-- Redraw this softmod's master frame (if desired)
-- @param event on_player_joined_game
function Evolution.on_player_joined_game(event)
    local player = game.players[event.player_index]
    Evolution.draw_master_frame(player)
end

-- When a player leaves clean up their GUI in case this mod gets removed or changed next time
-- @param event on_player_left_game
function Evolution.on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(Evolution.get_master_frame(player))
end

-- Refresh the game time each second
-- @param event on_tick
function on_tick(event)
    local refresh_period = 1 * 1 -- (sec)
    if (Time.tick_to_sec(game.tick) % refresh_period == 0) then
        for i, player in pairs(game.connected_players) do
            Evolution.update_evolution(player)
            -- For Testing, artificially add pollution
            -- player.surface.pollute(player.position, 100000)
        end
    end
end

-- Event Registration --
-- ======================================================= --
Event.register(defines.events.on_player_joined_game, Evolution.on_player_joined_game)
Event.register(defines.events.on_player_left_game, Evolution.on_player_left_game)
Event.register(defines.events.on_tick, on_tick)

-- GUI Functions --
-- ======================================================= --


-- GUI Function
-- Creates the main/master frame where all the GUI content will go in
-- @tparam LuaPlayer player current player calling the function
function Evolution.draw_master_frame(player)
    local master_frame = Evolution.get_master_frame(player)

    if (master_frame == nil) then
        master_frame = GUI.add_element(
            GUI.menu_bar_el(player),
            {
                type = 'frame',
                name = Evolution.MASTER_FRAME_NAME,
                direction = 'horizontal',
                tooltip = {"Evolution.master_frame_caption"},
            }
        )
        GUI.element_apply_style(master_frame, Styles.btn_menu)

        Evolution.fill_master_frame(master_frame, player)
    end
end

-- GUI Function
-- Fills frame with worst enemy icon and evolution percentage
-- @tparam LuaGuiElement container parent container to add GUI elements to
-- @tparam LuaPlayer player current player calling the function
function Evolution.fill_master_frame(container, player)
    local element = GUI.add_element( container,
        {
            type = 'sprite',
            name = Evolution.EVOLUTION_SPRITE_NAME,
            tooltip = {"Evolution.master_frame_caption"},
        }
    )
    -- GUI.element_apply_style(element, Styles.clear_padding_margin)
    element = GUI.add_element( container,
        {
            type = 'label',
            name = Evolution.EVOLUTION_LABEL_NAME,
            tooltip = {"Evolution.master_frame_caption"},
        }
    )
    GUI.element_apply_style(element, Styles.btn_menu_lbl)
    Evolution.update_evolution(player)
end

-- GUI Function
-- Updates the enemy icon and evolution percentage, if its a new icon, send out alert
-- @tparam LuaPlayer player current player calling the function
function Evolution.update_evolution(player)
    local sprite_evolution = Evolution.get_master_frame(player)[Evolution.EVOLUTION_SPRITE_NAME]
    local lbl_evolution = Evolution.get_master_frame(player)[Evolution.EVOLUTION_LABEL_NAME]
    local evolution_stats = Evolution.getEvolutionStats(player)
    if(sprite_evolution.sprite ~= evolution_stats.sprite) then
        sprite_evolution.sprite = evolution_stats.sprite
        game.print({"Evolution.alert", Sprites.getSpriteRichText(evolution_stats.sprite)})
    end
    -- sprite_evolution.tooltip = evolution_stats.evolution_percent
    lbl_evolution.caption = evolution_stats.evolution_percent
end

-- Logic Functions --
-- ======================================================= --

-- Figures out some evolution stats and returns them (Sprite and evo %)
-- @tparam LuaPlayer player current player calling the function
function Evolution.getEvolutionStats(player)
    local evolution_factor = game.forces["enemy"].evolution_factor;
    local spriteIdx = 0;

    -- Figure out what evolution breakpoint we are at
    for evolution, sprite in pairs(Evolution.EVOLUTION_SPRITES) do
        if(evolution_factor < evolution) then
            break
        end
        spriteIdx = evolution
    end

    -- return the evolution data
    return {
        sprite = GUI.get_safe_sprite_name(player, Evolution.EVOLUTION_SPRITES[spriteIdx]),
        evolution_percent = Math.round(evolution_factor * 100, 2) .. "%"
    }
end
