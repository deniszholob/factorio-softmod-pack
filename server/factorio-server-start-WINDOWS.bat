@echo off
::==============================================================================================================
:: Replace the appropriate entries below to suit your installation (Default install example shown)
::==============================================================================================================
set FactorioExeLocation=Factorio\bin\x64\
set SaveFileName=_autosave1.zip
set SaveLocation=saves\
set ServerSettingsFileName=server-settings.json
set ServerSettingsLocation=config\
::==============================================================================================================
echo ======================================
echo PREPARING TO LAUNCH FACTORIO SERVER...
echo ======================================
echo.
echo Save to be loaded:
echo %SaveLocation%%SaveFileName% 
echo.
echo Server Settings to load:
echo %ServerSettingsLocation%%ServerSettingsFileName%
echo.
echo.
echo *** Remember to use Ctrl+C to ensure saving when finished instead of simply closing this window ***
echo.
echo.
pause 3
::==============================================================================================================
:: ***NOTE: The line below launches factorio in headless mode with desired server settings, add any other
:: desired arguments to end of the line. Use "factorio.exe --help" for a list of all supported arguments.
::==============================================================================================================
start /wait %FactorioExeLocation%factorio.exe --start-server "%SaveLocation%%SaveFileName%" --server-settings "%ServerSettingsLocation%%ServerSettingsFileName%" pause 3
