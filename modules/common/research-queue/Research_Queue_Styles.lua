-- Research Queue Styles Soft Module Stylesheet
-- Holds style definitions
-- @usage local Research_Queue_Styles = require('modules/common/research-queue/Research_Queue_Styles')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

-- Dependencies --
-- ======================================================= --
local Colors = require('util/Colors')

-- Constants --
-- ======================================================= --

Research_Queue_Styles = {
    auto_research_header_label = {
        font_color = {r = .91764705882352941176, g = .85098039215686274509, b = .67450980392156862745},
        font = 'default-large-semibold',
        top_padding = 0,
        bottom_padding = 0,
        left_padding = 0,
        right_padding = 6
    },
    auto_research_list_flow = {
        vertical_spacing = 0
    },
    auto_research_tech_flow = {
        horizontal_spacing = 0,
        resize_row_to_width = true
    },
    auto_research_sprite = {
        width = 24,
        height = 24,
        top_padding = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0,
        horizontally_squashable = true,
        vertically_squashable = true,
        stretch_image_to_widget_size = true,
    },
    auto_research_sprite_button = {
        width = 24,
        height = 24,
        top_padding = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0,
        clicked_font_color = Colors.darkgrey
    },
    auto_research_sprite_button_toggle = {
        width = 24,
        height = 24,
        top_padding = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0,
        clicked_font_color = Colors.green
    },
    auto_research_sprite_button_toggle_pressed = {
        width = 24,
        height = 24,
        top_padding = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0,
        clicked_font_color = Colors.red
    },
    auto_research_tech_label = {
        left_padding = 4,
        right_padding = 4
    },
    scroll_pane = {
        top_padding = 5,
        bottom_padding = 5,
        maximal_height = 127,
        minimal_height = 40,
        horizontally_stretchable = true,
    },
    button_outer_frame = {
        top_padding = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0
    }
}

return Research_Queue_Styles
