-- DDDGamer's Factorio Soft Mod Collection
-- See README for more info and credits
-- Import module order DOES MATTER!!!
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Import dependency modules (event must be first as its a dependency for all others)
require "locale/softmod-modules-stdlib/Event"

-- Import Config
require "config"

-- Import Vanilla Modules
-- require "locale/softmod-modules-vanilla/player-vanilla"
-- require "locale/softmod-modules-vanilla/rocket-vanilla"

-- Import My Soft-Mod Modules
require "locale/softmod-modules-dz/player"
require "locale/softmod-modules-dz/player-logging"
require "locale/softmod-modules-dz/anti-griefing"
require "locale/softmod-modules-dz/announcements"
require "locale/softmod-modules-dz/player-list"
require "locale/softmod-modules-dz/game-info"
require "locale/softmod-modules-dz/tasks"
require "locale/softmod-modules-dz/show-health"
require "locale/softmod-modules-vanilla/rocket-vanilla"

-- Import 3Ra Soft-Mod Modules
require "locale/softmod-modules-3ra/undecorator"
require "locale/softmod-modules-3ra/gravestone"
-- require "locale/softmod-modules-3ra/rocket"
-- require "locale/softmod-modules-3ra/bot"
-- require "locale/softmod-modules-3ra/autodeconstruct"
