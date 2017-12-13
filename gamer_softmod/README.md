# DDDGamer's Factorio Soft Mod Collection
Collection of various softmods that apply to Factorio server without having the user to download mods.
Written for Factorio v0.14.22 (latest 0.14 stable)

My custom mods are located in the `softmod-modules-dz` folder, they are enabled by requiring them in the `control.lua` file.
I also have some mods from 3ra gaming.

# How to install?

## For multiplayer server / add to existing save game
* Create a new map (if you haven't already you can apply to existing maps)
  * You can use the factorio-gen-save-file.bat
  * You can use the game to find your map, copy seed into the map-gen-settings.json wich is used to generate the save file.
* Browse to the save file (.zip archive file) for your server
  * Typicaly **Factorio/saves/**
* Open the zip (typically `_autosave1.zip`)
* Replace the original `control.lua` with the one in this repo
* Copy the `locale` folder there and merge it with the existing one

## For development
* Using the win-server folder structure...
* Make sure you have a save file in the saves folder (generate of copy existing map)
  * You can use the factorio-gen-save-file.bat
  * You can use the game to find your map, copy seed into the map-gen-settings.json wich is used to generate the save file.
* Browse to the save file in the saves folder
* Open the zip (typically `_autosave1.zip`)
* Replace the original `control.lua` with the one in this repo
* Copy the `locale` folder there and merge it with the existing one



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
|   |   └── undecorator.lua
|   |
|   ├── softmod-modules-dz/     <- Various mods you want to apply (playerlist, readme, rocket-score, etc...)
|   |   ├── announcements.lua   <- (Remix from 3Ra Gaming)
|   |   ├── anti-griefing.lua   <- (Original code, references from ExplosiveGaming.nl)
|   |   ├── game-info.lua       <- (Original code, references from ExplosiveGaming.nl)
|   |   ├── player-list.lua     <- (Original code, references from ExplosiveGaming.nl)
|   |   ├── player-logging.lua  <- Show players joining/leaving in the log
|   |   ├── player.lua          <- Add more items to player at start (Remix from Vanilla)
|   |   ├── show-health.lua     <- (Remix from 3Ra Gaming)
|   |   └── tasks.lua           <- My creation - Players can create tasks to do
|   |
|   ├── softmod-modules-stdlib/ <- Libraries from [Afforess/Factorio-Stdlib](https://github.com/Afforess/Factorio-Stdlib)
|   |   ├── Event.lua
|   |   └── Game.lua
|   |
|   ├── softmod-modules-util/   <- My common helper utilities
|   |   ├── color-test.lua      <- Shows the color pallete
|   |   ├── Colors.lua          <- Color table
|   |   ├── GUI.lua             <- Common GUI operations
|   |   ├── Time_Rank.lua       <- Rank table based on time played
|   |   └── Time.lua            <- Time conversions
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
