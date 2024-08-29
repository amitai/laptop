#!/bin/bash

# Welcome to the FF laptop script.

green=$(tput setaf 2)
normal=$(tput sgr0)

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "${green}\\n$fmt\\n${normal}" "$@"
}

append_to_zprofile() {
  local text="$1"
  
  local file="$HOME/.zprofile"

  if ! grep -Fqs "$text" "$file"; then
    fancy_echo "Appending '$text' to $file"
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

# shellcheck disable=SC2154
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

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
  fancy_echo "Installing Homebrew ..."
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
  fancy_echo "Uninstalling old Homebrew-Cask ..."
  brew uninstall --force brew-cask
fi

fancy_echo "Updating Homebrew formulae ..."
brew update --force # https://github.com/Homebrew/brew/issues/1151

brew bundle --file=- <<EOF
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
EOF

if [ -f "$HOME/.laptop.local" ]; then
  fancy_echo "Running your customizations from ~/.laptop.local ..."
  # shellcheck disable=SC1090
  . "$HOME/.laptop.local"
fi
fancy_echo "Now getting ready to apply default settings."

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

# MS Office
defaults write com.microsoft.office ShowWhatsNewOnLaunch -bool false
defaults write com.microsoft.office ShowDocStageOnLaunch -bool false
defaults write com.microsoft.Outlook HideCanAddOtherAccountTypesTipText -bool true

# Notify that the job is done
osascript -e 'display notification "The script is done running." with title "FF Laptop Script"'