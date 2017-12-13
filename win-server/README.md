# Windows Factorio Server

Example of a folder structure you would have if on windows.
I use this to develop and test the softmod.
Linux server is almost identical, but i use a docker for my server for its simplicity, since I'm not doing anything huge.
Factorio Docker by dtandersen: https://hub.docker.com/r/dtandersen/factorio/

# Files
```
.
├── config/                    <- Map gen settings go here
├── Factorio/                  <- Factorio Game itself. Download from https://www.factorio.com/download
├── saves/                     <- Save file to use to start the server, generated one will go here
├── factorio-gen-save-file.bat <- Generate a new clean save in to the saves folder.
└── factorio-server.bat        <- To spin up a server on windows.

```
