-- DDDGamer's Factorio Soft Mod Collection
-- See README for more info and credits
-- Import module order DOES MATTER!!!
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/DDDGamer/factorio-dz-softmod
-- ======================================================= --

-- Notes: 
--       * FIXME: If rocket-vanilla imported after everything else, clicking on buttons does not show the GUI
--       * Gravestones not needed in Multiplayer v0.15

--=========== Import dependency modules ===========--
--=================================================--

--Event must be first as its a dependency for all others (event wrapper makes is easier to develop)
require "locale/softmod-modules-stdlib/Event"

-- Import Config
require "config"

-- Import Vanilla Modules if needed
-- require "locale/softmod-modules-vanilla/player-vanilla"
require "locale/softmod-modules-vanilla/rocket-vanilla"

-- Import DDDGamer's Soft-Mod Modules
require "locale/softmod-modules-dz/player-init"
require "locale/softmod-modules-dz/player-logging"
-- require "locale/softmod-modules-dz/permissions"
require "locale/softmod-modules-dz/anti-griefing"
require "locale/softmod-modules-dz/announcements"
require "locale/softmod-modules-dz/player-list"
require "locale/softmod-modules-dz/game-info"
require "locale/softmod-modules-dz/tasks"
require "locale/softmod-modules-dz/show-health"
require "locale/softmod-modules-dz/death-map-marker"

-- Import 3Ra Soft-Mod Modules
-- require "locale/softmod-modules-3ra/rocket"
-- require "locale/softmod-modules-3ra/bot"
-- require "locale/softmod-modules-3ra/autodeconstruct"
