@echo off

::==============================================================================================================
:: Replace the appropriate entries below to suit your installation (Default install example shown)
::==============================================================================================================
set FactorioExecutable=Factorio\bin\x64\factorio.exe
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
start /wait %FactorioExecutable% --create "%SaveLocation%%SaveFileName%" --map-gen-settings "%MapSettingsLocation%%MapSettingsFileName%" pause 3
