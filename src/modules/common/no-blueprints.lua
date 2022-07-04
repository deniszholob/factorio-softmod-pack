-- No Blueprints Soft Module
-- Uses locale no-blueprints.cfg
-- @usage require('modules/common/no-blueprints')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --

-- Constants --
-- ======================================================= --
NoBlueprints = {
    PERMISSION_GROUP = 'no_blueprints'
}

-- Event Functions --
-- ======================================================= --

--- Various action when new player joins in game
--- @param event defines.events.on_player_created event
function NoBlueprints.on_player_created(event)
    local player = game.players[event.player_index]
    NoBlueprints.dissalowBlueprints(player)
    player.print({'No_Blueprints.info'})
end

-- Event Registration
-- ================== --
Event.register(defines.events.on_player_created, NoBlueprints.on_player_created)

-- Helper Functions --
-- ======================================================= --

--- @param player LuaPlayer
function NoBlueprints.dissalowBlueprints(player)
    -- Get existing grouip or add one if doesnt exist
    local group =
        game.permissions.get_group(NoBlueprints.PERMISSION_GROUP) or
        game.permissions.create_group(NoBlueprints.PERMISSION_GROUP)
    -- Dissalow Hand Crafting (https://lua-api.factorio.com/latest/defines.html)
    group.set_allows_action(defines.input_action['import_blueprint'], false)
    group.set_allows_action(defines.input_action['import_blueprint_string'], false)
    -- group.set_allows_action(defines.input_action['open_blueprint_library_gui'], false)
    group.set_allows_action(defines.input_action['grab_blueprint_record'], false)
    group.set_allows_action(defines.input_action['open_blueprint_record'], false)
    -- Add player to the group
    game.permissions.get_group(NoBlueprints.PERMISSION_GROUP).add_player(player)
end
