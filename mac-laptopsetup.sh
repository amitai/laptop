#!/bin/bash

# Welcome to the FF laptop script.

append_to_zprofile() {
  local text="$1"
  
  local file="$HOME/.zprofile"

  if ! grep -Fqs "$text" "$file"; then
    echo "Appending '$text' to $file"
    echo "$text" >> "$file"
  fi
}

append_to_zshrc() {
  local text="$1" zshrc
  local skip_new_line="${2:-0}"

  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  else
    zshrc="$HOME/.zshrc"
  fi

  if ! grep -Fqs "$text" "$zshrc"; then
    if [ "$skip_new_line" -eq 1 ]; then
      printf "%s\\n" "$text" >> "$zshrc"
    else
      printf "\\n%s\\n" "$text" >> "$zshrc"
    fi
  fi
}


# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# shellcheck disable=SC2154
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

# exit on error
set -e

if [ ! -d "$HOME/.bin/" ]; then
  mkdir "$HOME/.bin"
fi

if [ ! -f "$HOME/.zshrc" ]; then
  touch "$HOME/.zshrc"
fi

# shellcheck disable=SC2016
append_to_zshrc 'export PATH="$HOME/.bin:$PATH"'

HOMEBREW_PREFIX="/opt/local"

if [ -d "$HOMEBREW_PREFIX" ]; then
  if ! [ -r "$HOMEBREW_PREFIX" ]; then
    sudo chown -R "$LOGNAME:admin" /opt/local
  fi
else
  sudo mkdir "$HOMEBREW_PREFIX"
  sudo chflags norestricted "$HOMEBREW_PREFIX"
  sudo chown -R "$LOGNAME:admin" "$HOMEBREW_PREFIX"
fi

if ! command -v brew >/dev/null; then
  echo "Installing Homebrew ..."
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    append_to_zshrc '# recommended by brew doctor'

    # shellcheck disable=SC2016
    append_to_zshrc 'export PATH="/opt/local/bin:$PATH"' 1
    append_to_zprofile 'eval "$(/opt/homebrew/bin/brew shellenv)"'

    export PATH="/opt/local/bin:$PATH"
    source ~/.zshrc
    source ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if brew list | grep -Fq brew-cask; then
  echo "Uninstalling old Homebrew-Cask ..."
  brew uninstall --force brew-cask
fi

echo "Updating Homebrew formulae ..."
brew update --force # https://github.com/Homebrew/brew/issues/1151

brew -v bundle --file=- <<EOF
# Unix
brew "gpg"
brew "ack"
brew "curl"
brew "git"
brew "vim"
brew "zsh"
brew "dockutil"

# Applications
cask "adobe-creative-cloud"
cask "microsoft-edge"
cask "microsoft-office"
cask "zoom"
cask "intune-company-portal"
cask "microsoft-teams"
cask "displaylink"
cask "nordlayer"
cask "google-chrome"

# Fonts
cask "font-source-serif-4"


EOF

if [ -f "$HOME/.laptop.local" ]; then
  echo "Running your customizations from ~/.laptop.local ..."
  # shellcheck disable=SC1090
  . "$HOME/.laptop.local"
fi
echo "Now getting ready to apply default settings."

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'


# Dock behavior modifications
defaults write com.apple.dock "tilesize" -int "36"
defaults write com.apple.dock showhidden -bool true


# Dock: Remove everything and add our default apps
dockutil --remove all > /dev/null 2>&1
dockutil --add /System/Applications/Launchpad.app > /dev/null 2>&1
dockutil --add /Applications/Utilities/Adobe\ Creative\ Cloud/ACC/Creative\ Cloud.app > /dev/null 2>&1
dockutil --add /System/Applications/System\ Settings.app > /dev/null 2>&1
dockutil --add /Applications/Safari.app > /dev/null 2>&1
dockutil --add /Applications/Microsoft\ Outlook.app > /dev/null 2>&1
dockutil --add /Applications/OneDrive.app > /dev/null 2>&1
dockutil --add /Applications/Microsoft\ Teams.app > /dev/null 2>&1
dockutil --add /Applications/Microsoft\ Word.app > /dev/null 2>&1
dockutil --add /Applications/Microsoft\ Excel.app > /dev/null 2>&1
dockutil --add /Applications/Microsoft\ PowerPoint.app > /dev/null 2>&1
dockutil --add /System/Applications/Weather.app > /dev/null 2>&1

# Notifications: extend banner display time
defaults write com.apple.notificationcenterui bannerTime 10

# Finder: show extensions
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true" 

# Finder: List view default
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"

# Finder: no iCloud by default
defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "false"

# Finder: large sidebar icon
defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "3" && killall Finder

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

# Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

# Prompt
append_to_zshrc 'PROMPT="%B%K{black}%F{40}➜%f%k%b%K{black} %k%K{black}    %k%K{black}%F{cyan}%~%f%k "'

# MS Office
defaults write com.microsoft.office ShowWhatsNewOnLaunch -bool false
defaults write com.microsoft.office ShowDocStageOnLaunch -bool false
defaults write com.microsoft.Outlook HideCanAddOtherAccountTypesTipText -bool true

# Safari
defaults write com.apple.Safari "ShowFullURLInSmartSearchField" -bool "true" 
defaults write com.apple.Safari HomePage -string "about:blank"
defaults write com.apple.Safari ShowFavoritesBar -bool false
defaults write com.apple.Safari ShowSidebarInTopSites -bool false
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false


# Disable transparency in the menu bar and elsewhere on Yosemite
defaults write com.apple.universalaccess reduceTransparency -bool true

# Always show scrollbars. Possible values: `WhenScrolling`, `Automatic` and `Always`
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Sleep the display after 15 minutes
sudo pmset -a displaysleep 15

# Disable machine sleep while charging
sudo pmset -c sleep 0

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Chrome - Use the system-native print preview dialog
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true