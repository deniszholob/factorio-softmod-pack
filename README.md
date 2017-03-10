# Factorio Soft Mod

My custom factorio soft mod

* Player list sidebar to show who is playing, how long have they played, and assigns rank based on gametime


# What is a soft mod?
A modification to the `control.lua` file.

## control.lua
* Factorio folder location: Factorio/data/base/scenarios/freeplay/
* Purpose: Sets up the initial game and is downloaded onto all the cliens automatically in multiplayer. The originall vanilla file tells the game to give you items at the start of the game and gives you pistol + ammo apon respawn

# How to install?

## For muliplayer server / add to existing save game
* Create a new map (if you havnt already you can apply to existing maps)
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
