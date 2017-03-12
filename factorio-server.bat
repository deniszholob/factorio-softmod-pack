@echo off 
::============================================================================================================== 
::	Replace the appropriate entries below to suit your installation (Default install example shown) 
::============================================================================================================== 
set FactorioRoot=C:\Users\Denis\Desktop\Factorio_0.14.22\
set FactorioExeLocation=%FactorioRoot%bin\x64\
set SaveFileName=Lua-Test.zip
set SaveLocation=%FactorioRoot%save\
set ServerSettingsFileName=server-settings.json
set ServerSettingsLocation=%FactorioRoot%data\
::============================================================================================================== 
cd %FactorioExeLocation% 
cd
echo.
echo PREPARING TO LAUNCH FACTORIO SERVER...
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
:: desired arguments to end of the line. Use "factorio.exe --help" for a list of all supported arguments. ::============================================================================================================== 
start /wait factorio.exe --start-server "%SaveLocation%%SaveFileName%" --server-settings "%ServerSettingsLocation%%ServerSettingsFileName%" pause 3
