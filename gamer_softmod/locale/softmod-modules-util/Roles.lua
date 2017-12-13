-- Roles Helper Module
-- Configuration modules that contains roles and players assigned to the roles
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Notes:
--      TODO: Add support for multiple roles per player
--      TODO: Populate Admin list from game

-- Dependencies
require "locale/softmod-modules-util/Time"
require "locale/softmod-modules-util/Colors"
require "locale/softmod-modules-util/Table"

Roles = {}

-- Define Roles here
Roles.OWNER =            {rank_idx = 0,   properties = {tag = "Owner",     color = Colors.red},       players = {"DDDGamer"}}
-- Roles.Developer =        {rank_idx = 1,   properties = {tag = "Dev",       color = Colors.yellow},    players = {"DDDGamer"}}
Roles.ADMIN =           {rank_idx = 2,   properties = {tag = "Admin",     color = Colors.orange},    players = {}} -- Automatically get the Factorio admins, no need to fill them here.
Roles.MODERATOR =       {rank_idx = 3,   properties = {tag = "Moderator", color = Colors.yellow},    players = {"theunheard", "AllStorm"}}
-- Roles.TRUSTED =          {rank_idx = 4,   properties = {tag = "Trusted",   color = Colors.yellow},    players = {}}
-- Roles.CONTENT_CREATOR = {rank_idx = 10,  properties = {tag = "CC",        color = Colors.yellow},    players = {"DDDGamer", "Zcoolest",}}
Roles.DEFAULT =          {rank_idx = 100, properties = {tag = "",          color = Colors.lightgrey}, players = {}} -- All the other players this table should also be empty


-- Returns the role properties for a player
-- @param player - Lua player
function Roles.get_role(player)
  if Roles.is_player_in_role(player, Roles.OWNER) then
    return Roles.OWNER.properties
  elseif (player.admin) then
    return Roles.ADMIN.properties
  elseif Roles.is_player_in_role(player, Roles.MODERATOR) then
    return Roles.MODERATOR.properties
  else
    return Roles.DEFAULT.properties
  end
end


-- Returns true if player is in the role list, false otherwise
-- @param player - Lua player
-- @param role - Defined role above
function Roles.is_player_in_role(player, role)
  for i, name in pairs(role.players) do
    if(player.name == name) then return true end
  end
  return false
end


-- Print a message for players with a specified role
-- @param message - A message string to print
-- @param role - Defined role above
function Roles.send_msg(message, role)
  for i, player in pairs(game.connected_players) do
    if(Roles.is_player_in_role(player, role)) then
      player.print(message)
    end
  end
end


-- Compare function for the roles
-- Will sort by lowest idx first (higher rank = lower idx)
-- @param role_a - Defined role above
-- @param role_b - Defined role above
function Roles.rank_compare(role_a, role_b)
  return role_a.rank_idx < role_b.rank_idx
end


-- Add players that are admins in factorio to the ADMIN role
function add_admins_toRoleList()
  for i, player in pairs(game.players) do
    if((player.admin) and not Table.contains(player.name)) then
      table.insert(Roles.ADMIN.players, player.name)
    end
  end
end

return Roles
