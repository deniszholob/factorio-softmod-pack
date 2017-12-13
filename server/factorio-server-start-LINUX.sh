#!/bin/sh -x
# ==============================================================================================================
# Replace the appropriate entries below to suit your installation (Default install example shown)
# ==============================================================================================================
FactorioExecutable="/opt/factorio/bin/x64/factorio"
SaveFileName="_autosave1"
SaveLocation="saves/"
ServerSetting="server-settings.json"
ServerSettingLocation="config/"
# ==============================================================================================================
echo "======================================"
echo "PREPARING TO LAUNCH FACTORIO SERVER..."
echo "======================================"
echo
echo "Save to be loaded:"
echo "$SaveLocation$SaveFileName%"
echo
echo "Server Settings to load:"
echo "$ServerSettingsLocation$ServerSettingsFileName"
echo
echo
echo "*** Remember to use Ctrl+C to ensure saving when finished instead of simply closing this window ***"
echo
echo
# ==============================================================================================================
# ***NOTE: The line below launches factorio in headless mode with desired server settings, add any other
# desired arguments to end of the line. Use "factorio.exe --help" for a list of all supported arguments.
# ==============================================================================================================
$FactorioApp --start-server $SaveLocation$SaveFileName --server-settings $ServerSettingLocation$ServerSetting
