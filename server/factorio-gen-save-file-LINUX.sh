#!/bin/sh -x

# ==============================================================================================================
# Replace the appropriate entries below to suit your installation (Default install example shown)
# ==============================================================================================================
FactorioExecutable="/opt/factorio/bin/x64/factorio"
SaveFileName="_autosave1.zip"
SaveLocation="saves/"
MapSettingsFileName="map-gen-settings.json"
MapSettingsLocation="config/"
# ==============================================================================================================
echo
echo "Generating Save file"
echo "$SaveLocation$SaveFileName"
echo
# ==============================================================================================================
$FactorioExecutable --create $SaveLocation$SaveFileName --map-gen-settings $MapSettingsLocation$MapSettingsFileName
