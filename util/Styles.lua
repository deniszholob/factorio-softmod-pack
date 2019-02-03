-- Styles Soft Module
-- Collection of common styles
-- @usage local Styles = require('util/Styles')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
-- local Colors = require('util/Colors')

-- Constants --
-- ======================================================= --

Styles = {
    btn_menu = {

    },
    -- Match label size, etc.. the style of sprite buttons
    lbl_menu = {
        font = 'default-bold',
        top_padding = 4,
        bottom_padding = 0,
        left_padding = 4,
        right_padding = 4,
    },
    frm_menu = {
        -- top_padding = 0,
        -- bottom_padding = 0,
        -- left_padding = 0,
        -- right_padding = 0,
        -- height = 24,
    },
    frm_window = {
        maximal_height = 650,
        minimal_width = 200
    },
    small_button = {
        width = 24,
        height = 24,
        top_padding = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0,
    },
    small_symbol_button = {
        width = 24,
        height = 24,
        top_padding = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0,
        font = 'default-listbox'
    },
}

return Styles
