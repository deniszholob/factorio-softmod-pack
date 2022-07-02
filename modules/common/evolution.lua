-- Evolution Soft Module
-- __Description__
-- Uses locale evolution.cfg
-- @usage require('modules/common/evolution')
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
local Colors = require('util/Colors')

-- Constants --
-- ======================================================= --
Evolution = {
    MASTER_FRAME_NAME = 'frame_Evolution',
    EVOLUTION_FLOW_NAME = 'flw_Evolution',
    EVOLUTION_SPRITE_NAME = 'sprite_Evolution',
    EVOLUTION_LABEL_NAME = 'lbl_Evolution',
    EVOLUTION_PROGRESS_NAME = 'bar_Evolution',
    EVOLUTION_SPRITES = {
        [0.00] = Sprites.small_biter,
        [0.21] = Sprites.medium_biter,
        [0.26] = Sprites.small_spitter,
        [0.41] = Sprites.medium_spitter,
        [0.50] = Sprites.big_biter,
        [0.51] = Sprites.big_spitter,
        [0.90] = Sprites.behemoth_biter,
        [0.91] = Sprites.behemoth_spitter,
    },
    EVOLUTION_COLORS = {
        [0.00] = Colors.orange,
        [0.21] = Colors.salmon,
        [0.50] = Colors.blue,
        [0.90] = Colors.darkgreen,
    },
    get_master_frame = function(player)
        return GUI.menu_bar_el(player)[Evolution.MASTER_FRAME_NAME]
    end
}

-- Event Functions --
-- ======================================================= --
--- When new player joins add a btn to their menu bar
--- Redraw this softmod's master frame (if desired)
--- @param event defines.events.on_player_joined_game
function Evolution.on_player_joined_game(event)
    local player = game.players[event.player_index]
    Evolution.draw_master_frame(player)
end

--- When a player leaves clean up their GUI in case this mod gets removed or changed next time
--- @param event defines.events.on_player_left_game
function Evolution.on_player_left_game(event)
    local player = game.players[event.player_index]
    GUI.destroy_element(Evolution.get_master_frame(player))
end

--- Refresh the game time each second
--- @param event defines.events.on_tick
function Evolution.on_tick(event)
    local refresh_period = 1 -- (sec)
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
Event.register(defines.events.on_tick, Evolution.on_tick)

-- GUI Functions --
-- ======================================================= --


--- GUI Function
--- Creates the main/master frame where all the GUI content will go in
--- @param player LuaPlayer current player calling the function
function Evolution.draw_master_frame(player)
    local master_frame = Evolution.get_master_frame(player)

    if (master_frame == nil) then
        master_frame = GUI.add_element(
            GUI.menu_bar_el(player),
            {
                type = 'frame',
                name = Evolution.MASTER_FRAME_NAME,
                direction = 'vertical',
                tooltip = {"Evolution.master_frame_caption"},
            }
        )
        -- GUI.element_apply_style(master_frame, Styles.frm_menu_no_pad)

        Evolution.fill_master_frame(master_frame, player)
    end
end

-- GUI Function
--- Fills frame with worst enemy icon and evolution percentage
--- @param container LuaGuiElement parent container to add GUI elements to
--- @param player LuaPlayer  player calling the function
function Evolution.fill_master_frame(container, player)
    local h_flow = GUI.add_element( container,
        {
            type = 'flow',
            name = Evolution.EVOLUTION_FLOW_NAME,
            direction = 'horizontal',
        }
    )
    h_flow.style.height = 10

    local sprite = GUI.add_element( h_flow,
        {
            type = 'sprite',
            name = Evolution.EVOLUTION_SPRITE_NAME,
            tooltip = {"Evolution.master_frame_caption"},
        }
    )
    local label = GUI.add_element( h_flow,
        {
            type = 'label',
            name = Evolution.EVOLUTION_LABEL_NAME,
            tooltip = {"Evolution.master_frame_caption"},
        }
    )

    local evo_progress_bar = container.add(
        {
            type = 'progressbar',
            name = Evolution.EVOLUTION_PROGRESS_NAME,
            tooltip = {"Evolution.master_frame_caption"},
            value = 0.2
        }
    )
    evo_progress_bar.style.width = 98
    evo_progress_bar.style.height = 3
    evo_progress_bar.style.top_margin = 14

    GUI.element_apply_style(container, Styles.btn_menu)
    GUI.element_apply_style(label, Styles.btn_menu_lbl)
    Evolution.update_evolution(player)
end

--- GUI Function
--- Updates the enemy icon and evolution percentage, if its a new icon, send out alert
--- @param player LuaPlayer current player calling the function
function Evolution.update_evolution(player)
    local sprite_evolution = Evolution.get_master_frame(player)[Evolution.EVOLUTION_FLOW_NAME][Evolution.EVOLUTION_SPRITE_NAME]
    local lbl_evolution = Evolution.get_master_frame(player)[Evolution.EVOLUTION_FLOW_NAME][Evolution.EVOLUTION_LABEL_NAME]
    local evo_progress_bar = Evolution.get_master_frame(player)[Evolution.EVOLUTION_PROGRESS_NAME]
    local evolution_stats = Evolution.getEvolutionStats(player)
    if(sprite_evolution.sprite ~= evolution_stats.sprite) then
        sprite_evolution.sprite = evolution_stats.sprite
        player.print({"Evolution.alert", Sprites.getSpriteRichText(evolution_stats.sprite)})
    end
    -- sprite_evolution.tooltip = evolution_stats.evolution_percent
    lbl_evolution.caption = evolution_stats.evolution_percent
    evo_progress_bar.value = evolution_stats.evolution
    evo_progress_bar.style.color = evolution_stats.color
end

-- Logic Functions --
-- ======================================================= --

--- Figures out some evolution stats and returns them (Sprite and evo %)
--- @param player LuaPlayer current player calling the function
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

    -- Figure out what evolution breakpoint we are at
    local colorIdx = 1
    for evo, color in pairs(Evolution.EVOLUTION_COLORS) do
        if(evolution_factor < evo) then
            break
        end
        colorIdx = evo
    end

    -- return the evolution data
    return {
        sprite = GUI.get_safe_sprite_name(player, Evolution.EVOLUTION_SPRITES[spriteIdx]),
        evolution = evolution_factor,
        evolution_percent = string.format('%6.2f', Math.round(evolution_factor * 100, 2)) .. "%",
        color = Evolution.EVOLUTION_COLORS[colorIdx]
    }
end
