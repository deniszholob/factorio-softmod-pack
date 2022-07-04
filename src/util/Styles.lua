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
        padding = 0,
        margin = 0,
        height = 38,
    },
    btn_menu_lbl = {
        font = 'default-bold',
        padding = 5,
    },
    -- Match label size, etc.. the style of sprite buttons
    lbl_menu = {
        font = 'default-bold',
        top_padding = 1,
        -- bottom_padding = 0,
        -- left_padding = 4,
        -- right_padding = 4,
    },
    frm_menu = {
        -- top_padding = 0,
        -- bottom_padding = 0,
        -- left_padding = 0,
        -- right_padding = 0,
        -- height = 24,
        height = 38,
    },
    frm_menu_no_pad = {
        padding = 0,
        margin = 0,
        height = 38,
    },
    clear_padding_margin = {
        padding = 0,
        margin = 0,
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
        font = 'default-listbox',
    },
    txt_clr_yellow = {
        font_color = Colors.yellow,
    },
    txt_clr_orange = {
        font_color = Colors.orange,
    },
    txt_clr_blue = {
        font_color = Colors.lightblue,
    },
    txt_clr_red = {
        font_color = Colors.red,
    },
    txt_clr_green = {
        font_color = Colors.green,
    },
    txt_clr_disabled = {
        font_color = Colors.darkgrey,
    },

}

return Styles
