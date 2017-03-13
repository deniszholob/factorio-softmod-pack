# Player List Mod

This is an intermediate example of control.lua modification.
THis adds a side panel to show all the online players, slong with hrs played and custom visual rank

## Features
* Player List button - allosws toggling the playerlist panel on/off
* Playerlist side panel displays players
* Color codes based on ranck
* Time played next to each player

## Limitations
* The GUI only updates when a new player joins/leaves the game, meaning the hours played will not change untill either a new player joins the game or existing player leaves.
* The hour time couts by whole hrs only, so if the player has been playing for 59 minutes it will show 0hr
