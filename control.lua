-- DDDGamer's Factorio Soft Mod Collection
-- See README for more info and credits
-- Import module order DOES MATTER (UI elements get drawn in import order)
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Notes:
--       * Customize scenario-name in global.cfg for your liking (optional, defaults is Freeplay)
--       *

-- ============== Import Dependency modules ============== --
-- ======================================================= --

-- "Event" must be first as its a dependency for all others (event wrapper makes is easier to develop)
require('stdlib/Event')
require('stdlib/table')
-- require('stdlib/string')

-- Import Config
require('config')

-- ============== Import Soft-Mod Modules ============== --
-- ======================================================= --
-- require('modules/dev/for-testing')

-- == Import Vanilla Modules if needed == --
-- require('modules/vanilla/silo')
-- require('modules/vanilla/player-init')

-- == Import Soft Mod Modules == --
require('modules/dddgamer/player-init')
require('modules/dddgamer/spawn-area')
require('modules/dddgamer/player-logging')
require('modules/dddgamer/game-info')

require('modules/common/online-player-list')
require('modules/common/evolution')
require('modules/common/game-time')
require('modules/common/silo')

require('modules/common/spawn-marker')
require('modules/common/death-marker')
require('modules/common/autodeconstruct')
require('modules/common/floating-health')
-- require('modules/common/no-blueprints')
-- require('modules/common/no-hand-crafting')
require('modules/common/custom-tech')

-- === Can cause problems in multiplayer === ---
-- require('modules/common/research-queue/auto-research')
-- require('modules/common/tasks') -- Has desync problems

-- ==== Testing === --
-- require('modules/dev/__MODULE_NAME__')
-- require('modules/dev/color_list')
-- require('modules/dev/sprite_list')
-- require('modules/dev/for-testing')
-- require('modules/dev/spawn-rocket-silo')
