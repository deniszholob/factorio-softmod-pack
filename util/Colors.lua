-- Colors Module
-- Collection of common colors
-- @usage local Colors = require('util/Colors')
-- ------------------------------------------------------- --
-- @author Denis Zholob (DDDGamer)
-- github: https://github.com/deniszholob/factorio-softmod-pack
-- ======================================================= --

Colors = {
    black =       { r=0,   g=0,   b=0   },
    darkgrey =    { r=65,  g=65,  b=65  },
    grey =        { r=130, g=130, b=130 },
    lightgrey =   { r=190, g=190, b=190 },
    white =       { r=255, g=255, b=255 },

    darkgreen =   { r=0,   g=130, b=0   },
    green =       {r=25,   g=255, b=51  },
    lightgreen =  { r=130, g=255, b=130 },

    cyan =        { r=20,  g=220, b=190 },

    darkblue =    { r=30,  g=30,  b=180 },
    blue =        { r=30,  g=130, b=255 },
    lightblue =   { r=60,  g=180, b=255 },

    darkpurple =  { r=160, g=50,  b=255 },
    purple =      { r=179, g=102, b=255 },
    violet =      { r=130, g=130, b=255 },

    pink =        { r=255, g=0,   b=255 },
    lightpink =   { r=255, g=160, b=255 },

    darkred =     { r=160, g=0,   b=0   },
    red_sat =     { r=255, g=0,   b=25  },
    red =         { r=255, g=50,  b=50  },
    text_red =    { r=230, g=39,  b=0   },
    lightred =    { r=255, g=130, b=120 },

    darkorange =  { r=242, g=70,  b=13  },
    orange =      { r=255, g=140, b=25  },
    text_orange = { r=194, g=84,  b=0   },
    yellow =      { r=255, g=255, b=0   },
    lightyellow = { r=255, g=255, b=120 },
    brown =       { r=0.6, g=0.4, b=0.1 },
}

return Colors
