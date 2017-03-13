# Factorio Soft Mod

My custom factorio soft mod

* Player list sidebar to show who is playing, how long have they played, and assigns vidual rank based on gametime


# What is a soft mod?
A modification to the `control.lua` file.

## control.lua
* Factorio folder location: Factorio/data/base/scenarios/freeplay/
* Purpose: Sets up the initial game and is downloaded onto all the clients automatically in multiplayer. The original vanilla file tells the game to give you items at the start of the game and gives you pistol + ammo upon respawn

# How to install?

## For multiplayer server / add to existing save game
* Create a new map (if you haven't already you can apply to existing maps)
* Browse to the save file (.zip archive file) for your server
  * Local saves are in C:/Users/*[yourusername]*/AppData/Roaming/Factorio/saves/
* Open the zip (typically `_autosave1.zip`)
* Replace the original `control.lua` with the one in this repo

## For development
* Browse to Factorio freeplay scenarios folder Factorio/data/base/scenarios/freeplay/
* Backup the original `control.lua`
* Replace the original `control.lua` with the one in this repo
* If you make a new game, the soft-mod will be applied

# Files
```
.
├── gamer_softmod/      <- my current soft mod for my server.
├── player_list_mod/    <- Simple Player list soft mod
├── simple-soft-mod/    <- The simplest mod to the vanilla control.lua. Beginners start here.
├── vanilla_control/    <- Backup of the vanilla control.lua
└── factorio-server.bat <- to spin up a local testing server on windows

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
* Thanks to **CoolDude2606** from explosive gaming for getting me started.
