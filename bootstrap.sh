#!/usr/bin/env bash

usage() {
    cat << USAGE >&2
Usage:
    bootstrap.sh [--with-mac-settings] [--with-nvm]
    -h | --help           Show usage information
    --with-mac-settings   Configure Mac OSX settings
    --with-neovim         Configure NeoVim
    --with-nvm            Install with nvm support
USAGE
    exit 1
}

NVM_VERSION=0.39.3
WITH_MAC_SETTINGS=false
WITH_NEOVIM=false
WITH_NVM=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help)
      usage
    ;;
    --with-mac-settings)
      WITH_MAC_SETTINGS=true
      shift 1
    ;;
    --with-neovim)
      WITH_NEOVIM=true
      shift 1
    ;;
    --with-nvm)
      WITH_NVM=true
      shift 1
    ;;
    *)
    echoerr "Unknown argument: $1"
    usage
    ;;
  esac
done

# Install Homebrew.
if ! command -v brew &> /dev/null; then
  echo "installing homebrew..."

  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew update
brew upgrade

brew tap homebrew/cask-fonts

brews=(
  ansible
  autojump
  awscli
  coreutils
  docker
  font-hack-nerd-font
  gnupg
  git
  go
  google-cloud-sdk
  helm
  jq
  kubectl
  neovim
  packer
  postgresql@14
  pyenv
  pyenv-virtualenv
  ripgrep
  shellcheck
  terraform
  tree
  wireguard-tools
)

brew install "${brews[@]}"

casks=(
  1password
  firefox
  google-chrome
  iterm2
  postman
  rectangle
  slack
  spotify
  wireshark
  zoom
)

brew install --cask "${casks[@]}"

brew cleanup

if [[ "$WITH_NVM" = true ]]; then
  echo "installing nvm..."

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash
  NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
  npm install --global yarn
fi

if [[ "$WITH_MAC_SETTINGS" == true ]]; then
  echo "Configuring mac settings ..."

  # Ask for admin password
  sudo -v

  # keyboard repeat rate
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 10
  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
  # Finder: show hidden files by default
  defaults write com.apple.finder AppleShowAllFiles -bool true
  # Set the icon size of Dock items to 36 pixels
  defaults write com.apple.dock tilesize -int 36
  # Change minimize/maximize window effect
  defaults write com.apple.dock mineffect -string "scale"
  # Minimize windows into their application’s icon
  defaults write com.apple.dock minimize-to-application -bool true
  # Remove the auto-hiding Dock delay
  defaults write com.apple.dock autohide-delay -float 0
  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true
  ## Hot corners
  # Top left -> Mission Control
  defaults write com.apple.dock wvous-tl-corner -int 2
  defaults write com.apple.dock wvous-tl-modifier -int 0
  # Top right -> Desktop
  defaults write com.apple.dock wvous-tr-corner -int 4
  defaults write com.apple.dock wvous-tr-modifier -int 0
  # Bottom left -> Start screen saver
  defaults write com.apple.dock wvous-bl-corner -int 5
  defaults write com.apple.dock wvous-bl-modifier -int 0
  # Enable auto-update
  defaults write com.apple.commerce AutoUpdate -bool true
fi

if [[ $WITH_NEOVIM == true ]]; then
  echo "configuring neovim..."

  $GH_REMOTE_PATH=https://raw.githubusercontent.com/gmccue/cmptr/main/.config/nvim
  mkdir -p $HOME/.config/nvim/lua
  curl -O --output-dir $HOME/.config/nvim/ $GH_REMOTE_PATH/init.lua
  curl -O --output-dir $HOME/.config/nvim/lua $GH_REMOTE_PATH/lua/plugins.lua
fi

echo "bootstrap complete!"
