#!/usr/bin/env bash

#################################
#         Pre-configure         #
#################################

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Close System Preferences to prevent overriding settings.
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
echo "Please enter your sudo password. It's required for altering macOS defaults."
sudo -v

# Run Keep-Alive for sudo until the script is finished.
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

#################################
#          General UI           #
#################################

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "k3rnel-pan1c"
sudo scutil --set HostName "k3rnel-pan1c"
sudo scutil --set LocalHostName "k3rnel-pan1c"

#################################
#            Dock               #
#################################

# Set the icon size of Dock items to 55 pixels
defaults write com.apple.dock tilesize -int 55

# Set show recent applications in Dock
defaults write com.apple.dock "show-recents" -bool "false"

# Set minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool true

# Set magnification to Large
defaults write com.apple.dock largesize -int 128

#################################
#            Desktop            #
#################################

# Set ask to keep changes when closing documents to true
defaults write NSGlobalDomain NSCloseAlwaysConfirmsChanges -bool true

# Set automatically rearrange Spaces based on most recent use to false
defaults write com.apple.dock mru-spaces -bool false

# Disable all hot corners
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0

#################################
#       Language & Region       #
#################################

# Set Preffered Languages (as done via System Preferences → Language & Region)
defaults write NSGlobalDomain AppleLanguages -array "en-US" "ru-US"

# Set Locale (as done via System Preferences → Language & Region)
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=EUR"

# Set Measurement Units (as done via System Preferences → Language & Region)
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"

# Set Metric Units (as done via System Preferences → Language & Region)
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Set temperature units to Celsius
defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"

# Set first day of week to Monday
defaults write NSGlobalDomain AppleFirstWeekday -dict gregorian 2

# Set date format to "dd.MM.y"
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict 1 "dd.MM.y"

#################################
#          Appearance           #
#################################

# Set appearance to Auto (as done via System Preferences → Appearance)
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -int 1

# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Set show scroll bars to automatic
defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"

#################################
#            Keyboard           #
#################################

# Set turn keyboard backlight off after 1 minute of inactivity
defaults write com.apple.BezelServices kDimTime -int 60

# Add input sources (as done via System Preferences → Keyboard → Input Sources)
# (
#         {
#         InputSourceKind = "Keyboard Layout";
#         "KeyboardLayout ID" = 0;
#         "KeyboardLayout Name" = "U.S.";
#     },
#         {
#         InputSourceKind = "Keyboard Layout";
#         "KeyboardLayout ID" = 19456;
#         "KeyboardLayout Name" = Russian;
#     }
# )
defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add '{InputSourceKind="Keyboard Layout";"KeyboardLayout ID"=0;"KeyboardLayout Name"="U.S.";}' '{InputSourceKind="Keyboard Layout";"KeyboardLayout ID"=19456;"KeyboardLayout Name"="Russian";}'

#################################
#        Menu Bar Clock         #
#################################

# Disable blinking time separators
defaults write com.apple.menuextra.clock FlashDateSeparators -int 0

# Show AM/PM
defaults write com.apple.menuextra.clock ShowAMPM -int 1

# Disable date in the menu bar clock
defaults write com.apple.menuextra.clock ShowDate -int 2

# Disbale show day of month in the menu bar clock
defaults write com.apple.menuextra.clock ShowDayOfMonth -int 0

# Disable showing day of the week in the menu bar clock
defaults write com.apple.menuextra.clock ShowDayOfWeek -int 0

# Disable seconds in the menu bar clock
defaults write com.apple.menuextra.clock ShowSeconds -int 0

#################################
#           Zoom Chat           #
#################################

# Disable Zoom icon in the menu bar
defaults write ZoomChat ZoomShowIconInMenuBar -bool false

#################################
#        Post-configure         #
#################################

# Restart affected applications
apps=(
    "Dock"
    "Finder"
    "SystemUIServer"
)
for app in "${apps[@]}"; do
  killall "${app}" &> /dev/null
done

echo "Done. Note that some of these changes require a logout/restart to take effect."
