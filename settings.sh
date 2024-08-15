#! /bin/bash


# Dock: Remove everything and add our default apps
dockutil --remove all > /dev/null 2>&1
dockutil --add /System/Applications/Launchpad.app > /dev/null 2>&1
dockutil --add /System/Applications/System\ Settings.app > /dev/null 2>&1
dockutil --add /Applications/Safari.app > /dev/null 2>&1
dockutil --add /Applications/Microsoft\ Outlook.app > /dev/null 2>&1
dockutil --add /Applications/OneDrive.app > /dev/null 2>&1
dockutil --add /Applications/Microsoft\ Teams.app > /dev/null 2>&1
dockutil --add /Applications/Microsoft\ Word.app > /dev/null 2>&1
dockutil --add /Applications/Microsoft\ Excel.app > /dev/null 2>&1
dockutil --add /Applications/Microsoft\ PowerPoint.app > /dev/null 2>&1

# Finder: show extensions
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true" 

# Finder: List view default
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"

# Finder: no iCloud by default
defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "false"

# Trackpad: Tap
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: Two-Finger-Tap
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

# Screenshot: disable shadow
defaults write com.apple.screencapture "disable-shadow" -bool "true"


# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

#Speeding up wake from sleep to 24 hours from an hour
pmset -a standbydelay 86400

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Turn off keyboard illumination when computer is not used for 5 minutes
defaults write com.apple.BezelServices kDimTime -int 300

# Setting screenshot format to PNG
defaults write com.apple.screencapture type -string "png"

# Speeding up Mission Control animations and grouping windows by application
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

# Privacy: Don't send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Enabling the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

# Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

# Disable smart quotes in Messages.app (it's annoying for messages that contain code)
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

# Requires a password after screensaver or wake up
defaults write com.apple.screensaver askForPassword 1

# Store screenshots on Desktop
defaults write com.apple.screencapture location ~/Desktop

