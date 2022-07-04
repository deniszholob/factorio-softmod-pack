# To contribute

**If you are working on an existing issue, please claim it with your comment, so there is no duplicate work.**

## Hidden Files in VSCode
Some files are hidden in vscode by default, see the `files.exclude` option in the [settings file](.vscode/settings.json)

There is a [recommended extension](.vscode/extensions.json) `adrianwilczynski.toggle-hidden` that allows to easily toggle hidden files on and off



## Dev
* The main softmod code is in the [src](./src/) folder
* See the [src/README.md](./src/README.md) details
* You can run the [copy-local.sh](./tools/copy-local.sh) script to sync to factorio scenarios folder
* See [common console commands](https://wiki.factorio.com/Console#Set_evolution_factor)
* See [Useful Factorio commands for testing](./tools/console-lua-commands.lua)

**Notes:**
* Previous pack versions are saved on separate branches.
* This pack is not finalized, there are still some modules under development that are not listed in the `control.lua`
* A list of existing style can be found in `Factorio/data/core/prototypes/style.lua`


### References
* [Factorio API](http://lua-api.factorio.com/latest/)
* [Factorio Wiki - Multiplayer](https://wiki.factorio.com/Multiplayer)
* [Factorio Wiki - Console](https://wiki.factorio.com/Console)
* [Factorio Wiki - Research](https://wiki.factorio.com/Research)
* [Factorio RElms - Console Commands](https://factorio-realms.com/tutorials/useful_factorio_console_commands)
* [Afforess/Factorio-Stdlib](https://github.com/Afforess/Factorio-Stdlib)
* [Afforess/Factorio-Stdlib Doc](http://afforess.github.io/Factorio-Stdlib/index.html)
* [3RaGaming/3Ra-Enhanced-Vanilla](https://github.com/3RaGaming/3Ra-Enhanced-Vanilla)
* [RedMew](https://github.com/Refactorio/RedMew)
* [Lua Doc](https://www.lua.org/manual/5.3/)
* [Lua tutspoint](https://www.tutorialspoint.com/lua/index.htm)
