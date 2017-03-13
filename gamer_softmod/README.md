# DDDGamer's Factorio Soft Mod Collection
Collection of various softmods that apply to Factorio server without having the user to download mods.

The different mods are located in the `dz-softmod-modules` folder, they are enabled by requiring them in the `control.lua` file.

# How to install?

## For multiplayer server / add to existing save game
* Create a new map (if you haven't already you can apply to existing maps)
* Browse to the save file (.zip archive file) for your server
  * Typicaly **Factorio/saves/**
* Open the zip (typically `_autosave1.zip`)
* Replace the original `control.lua` with the one in this repo
* Copy the `locale` folder there and merge it with the existing one

## For development
* Browse to Factorio freeplay scenarios folder **Factorio/data/base/scenarios/freeplay/**
* Backup the original `control.lua`
* Replace the original `control.lua` with the one in this repo
* Copy the `locale` folder there and merge it with the existing one
* If you make a new game, the soft-mod will be applied


# Files

## Why locale folder?
Because local and control.lua is the only folders factorio copies.

Furthermore no subfolders in local either thus the *softmod-module-[name]* folder naming convention.

## Dir Structure
```
.
├── locale/
|   ├── softmod-modules-3ra/    <- [3RaGaming](https://github.com/3RaGaming/3Ra-Enhanced-Vanilla) Copied Modules
|   |   ├── gravestone.lua
|   |   ├── showhealth.lua
|   |   └── undecorator.lua
|   |
|   ├── softmod-modules-dz/     <- Various mods you want to apply (playerlist, readme, rocket-score, etc...)
|   |   ├── announcements.lua   <- (Remix from 3Ra Gaming)
|   |   ├── player.lua          <- Add more items to player at start (Remix from Vanilla)
|   |   ├── playerlist.lua      <- (Heavily referenced from ExplosiveGaming.nl, but original code)
|   |   ├── readme.lua          <- (Heavily referenced from from ExplosiveGaming.nl, but my original code)
|   |   └── tasks.lua           <- My creation - Players can create tasks to do
|   |
|   ├── softmod-modules-stdlib/ <- Libraries from [Afforess/Factorio-Stdlib](https://github.com/Afforess/Factorio-Stdlib)
|   |   ├── Event.lua
|   |   └── Game.lua
|   |
|   ├── softmod-modules-util/   <- My common helper utilities
|   |   ├── GUI.lua             <- common gui operations
|   |   └── Time.lua            <- time conversions
|   |
|   └── softmod-modules-vanilla/<- Vanilla modules
|       ├── player-vanilla.lua  <- players spawn/reset items
|       └── rocket-vanila.lua   <- default rocket scrore
|
├── config.lua                  <- store settings here
└── control.lua                 <- game entry: require modules here to enable them

```

# References
* [Factorio API](http://lua-api.factorio.com/latest/)
* [Lua Doc](https://www.lua.org/manual/5.3/)
* [Lua tutspoint](https://www.tutorialspoint.com/lua/index.htm)
* [Afforess/Factorio-Stdlib Doc](http://afforess.github.io/Factorio-Stdlib/modules/Gui.html)
* [Factorio Wiki](https://wiki.factorio.com/Multiplayer)

# Credits:
* [https://github.com/Afforess/Factorio-Stdlib](https://github.com/Afforess/Factorio-Stdlib)
* [https://github.com/3RaGaming/3Ra-Enhanced-Vanilla](https://github.com/3RaGaming/3Ra-Enhanced-Vanilla)
* [Explosive Gaming Forums](https://explosivegaming.nl/topic/62/factorio-server-technical-query)
