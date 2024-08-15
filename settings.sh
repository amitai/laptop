#!/bin/bash

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