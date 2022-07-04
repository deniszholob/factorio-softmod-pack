# DDDGamer's Factorio Softmod Collection (Scenario)

## Installation
* Download the softmod pack zipped file (`dddgamer-softmod-pack.zip`) from the
[Latest Release](https://github.com/deniszholob/factorio-softmod-pack/releases/latest)
* Extract to `%appdata%/Factorio/scenarios/`
* *(Optional)* Enable/disable softmod modules in the `control.lua` to your liking
* Launch Factorio
* *(Optional)* Configure any of the softmod modules in the `./modules/` folder to your liking
* Launch Factorio
* Play -> Scenarios -> dddgamer-softmod-pack

## Add to an existing save
* Download the softmod pack zipped file (`dddgamer-softmod-pack.zip`) from the
[Latest Release](https://github.com/deniszholob/factorio-softmod-pack/releases/latest)
* Browse to your save file (.zip archive file)
  * Local saves are in C:/Users/*[your-username]*/AppData/Roaming/Factorio/saves/
* Open your save game zip
  * (typically `_autosave1.zip` for auto saves on regular game or servers)
* Extract the softmod pack contents into the saved file replacing the control.lua

## Files

```
.
├── locale/     <- Translation strings
├── modules/    <- The actual softmod modules
├── stdlib/     <- Factorio "standard library" classes, main one being the Event
├── util/       <- Contains some utility classes like colors, math, styles.
├── config.lua  <- Just creates a config global for now.
├── control.lua <- Entry file that loads all the
└── README.MD   <- This file
```
