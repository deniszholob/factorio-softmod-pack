@echo off 
::============================================================================================================== 
::	Replace the appropriate entries below to suit your installation (Default install example shown) 
::============================================================================================================== 
set FactorioRoot=Factorio\
set FactorioExeLocation=%FactorioRoot%bin\x64\
set SaveFileName=_autosave1.zip
set SaveLocation=saves\
set MapSettingsFileName=map-gen-settings.json
set MapSettingsLocation=config\
::============================================================================================================== 
echo.
echo Generating Save file
echo %SaveLocation%%SaveFileName% 
echo.
::============================================================================================================== 
start /wait %FactorioExeLocation%factorio.exe --create "%SaveLocation%%SaveFileName%" --map-gen-settings "%MapSettingsLocation%%MapSettingsFileName%" pause 3

