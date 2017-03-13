--- Game module
-- @module Game

Game = {}
Game.VALID_FILTER = function(v)
    return v.valid
end

--- Messages all players currently connected to the game
-- @param msg message to send to players
-- @param condition (optional) optional condition to be true for the player to be messaged
-- @return the number of players who received the message. Offline players are not counted as having received the message.
function Game.print_all(msg, condition)
    local num = 0
    for _, player in pairs(game.players) do
        if player.valid then
            if condition == nil or select(2, pcall(condition, player)) then
                player.print(msg)
                if player.connected then
                    num = num + 1
                end
            end
        end
    end
    return num
end

return Game
