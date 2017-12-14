-- Time_Rank Helper Module
-- Assigns rank to player base on time played
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

--TODO: Update all to Time_Rank.LVL1 format (capitalize)

-- Dependencies
require "locale/softmod-modules-util/Time"
require "locale/softmod-modules-util/Colors"

Time_Rank = {}

-- Regular player ranks (time in hrs)
Time_Rank.RANKS = {
  lvl1 = { time = 0,   color = Colors.lightgrey,   tag = "Commoner", },
  lvl2 = { time = 1.5, color = Colors.lightyellow, tag = "Minion",   },
  lvl3 = { time = 5,   color = Colors.green,       tag = "Hero",     },
  lvl4 = { time = 10,  color = Colors.cyan,        tag = "Champion", },
  lvl5 = { time = 30,  color = Colors.blue,        tag = "Elite",    },
  lvl6 = { time = 60,  color = Colors.purple,      tag = "All-Star", },
}

-- Return a rank obj based on the players time on the server
-- @param player
-- @return Rank obj
function Time_Rank.get_rank(player)
  -- local online_time = Time.tick_to_hour(player.online_time)
  local online_time = Time.tick_to_hour(player.online_time)
  local time_rank = Time_Rank.RANKS.lvl1

  -- Loop through rank table to check what rank player is
  for key, rank in pairs(Time_Rank.RANKS) do
    -- Lua tables not ordered, can't return immediately in the loop
    if(rank.time > time_rank.time and online_time >= rank.time) then
      time_rank = rank
    end
  end

  return time_rank
end

return Time_Rank
