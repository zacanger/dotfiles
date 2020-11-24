#!/usr/bin/env bash

# First, disable SIP. Turn off and boot up while holding CMD+R,
# then open Utilities > Terminal and run csrutil disable

# Install Rectangle and configure to start on login:
# https://github.com/rxhanson/Rectangle

### Change macos settings

# Turn on key repeats, since by default Macs show some weird little character-picker
# dialog when you hold a key
defaults write -g ApplePressAndHoldEnabled -bool false

# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Enable subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 2

# Show remaining battery time and percentage
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
defaults write com.apple.menuextra.battery ShowTime -string "YES"

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Disable slow keys
defaults write com.apple.universalaccess slowKey -int 0

# Short key repeat delay
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Set a fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 3

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable window animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Enable tap to click (Trackpad)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Disable Safari’s thumbnail cache for History and Top Sites
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Enable Safari’s debug menu
defaults write com.apple.Safari IncludeDebugMenu -bool true

# Remove useless icons from Safari’s bookmarks bar
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Disable Resume system-wide
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Show the ~/Library folder
chflags nohidden ~/Library

# Disable local Time Machine backups
# Doesn't work on High Sierra??
# hash tmutil &> /dev/null && sudo tmutil disablelocal

# Finder
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder DesktopViewOptions -dict IconSize -integer 72
defaults write com.apple.finder AppleShowAllFiles true # should this be YES?
# Disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Show all filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Safari
defaults write com.apple.Safari IncludeDebugMenu 1
defaults write com.apple.Safari WebKitDeveloperExtras -bool true

# iTunes
defaults write com.apple.iTunes allow-half-stars -bool true
defaults write com.apple.iTunes invertStoreLinks -bool true

## Dock

defaults write com.apple.dock no-bouncing -bool true
# defaults write com.apple.Dock autohide -bool true
defaults write com.apple.dock largesize -int 65
defaults write com.apple.dock tilesize -int 14
# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true
# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0
# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0
# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true
# Don’t animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Disable Notification Center and remove the menu bar icon
sudo launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable 'Dashboard' whatever that is
defaults write com.apple.dashboard mcx-disabled -boolean TRUE

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable “natural” (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Use f-keys without holding fn key:
echo '2' | sudo tee /sys/module/hid_apple/parameters/fnmode

# Kill some stuff
pkill -9 Finder
pkill -9 Dock

# Update the Mac
sudo softwareupdate -i -a

## Now that that's done we can install and configure what we need

# Some mac users will tell you it's risky to use this directory.
# I'm telling you it's fine, they're probably the sort of people
# who prefer the Apple App Store over Makefiles.
sudo chown -R "$USER" /usr/local

# Install Docker from website.

# Install Dropbox and sync; dotfiles are at $HOME/Dropbox/z
z_path=$HOME/Dropbox/z
list_path=$z_path/misc
"$z_path/bin/dropbox-fix.sh"

# CLI tools
xcode-select --install

# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# Install brew packages
# Special cases
brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
brew install python3
brew postinstall python3 # get pip
brew install wdiff --with-gettext
brew install coreutils --with-default-names
brew install ed --with-default-names
brew install findutils --with-default-names
brew install gnu-indent --with-default-names
brew install gnu-sed --with-default-names
brew install gnu-tar --with-default-names
brew install gnu-which --with-default-names
brew install grep --with-default-names
brew cask install minikube
brew cask install mpv
# The rest
brew_packages=(
  aspcud
  aspell
  atk
  atool
  autoconf
  automake
  aws-iam-authenticator
  awscli
  bash
  bash-completion
  bdw-gc
  berkeley-db
  binutils
  boost
  cairo
  camlp4
  clasp
  cmake
  cowsay
  ctags
  curl
  dbus
  diffutils
  dos2unix
  doxygen
  enchant
  faac
  ffmpeg
  figlet
  file-formula
  flac
  fontconfig
  freetype
  fribidi
  gawk
  gcc
  gdb
  gdbm
  gdk-pixbuf
  gettext
  ghc
  giflib
  gifsicle
  git
  gmp
  gnutls
  go
  gpatch
  gpg
  graphicsmagick
  gringo
  gzip
  harfbuzz
  haskell-stack
  highlight
  htop
  icu4c
  imagemagick
  imlib2
  isl
  jack
  jpeg
  jq
  kompose
  kubernetes-cli
  lame
  less
  libass
  libav
  libepoxy
  libevent
  libffi
  libid3tag
  libmagic
  libmpc
  libogg
  libpng
  libsamplerate
  libsndfile
  libsoup
  libtasn1
  libtiff
  libtool
  libvorbis
  libyaml
  lua
  lzip
  m4
  mad
  make
  meson
  mongodb
  mpfr
  mplayer
  ncdu
  ncurses
  nettle
  nginx
  ninja
  oniguruma
  openjpeg
  openssh
  openssl
  p7zip
  pandoc
  pango
  pcre
  perl518
  pixman
  pkg-config
  pngcrush
  poppler
  pv
  py2cairo
  pygobject
  ranger
  readline
  redis
  rlwrap
  rsync
  ruby
  s-lang
  siege
  sip
  source-highlight
  sox
  sqlite
  telnet
  terraform
  the_silver_searcher
  tree
  unrar
  unzip
  vala
  vim
  w3m
  watch
  watchman
  webp
  wget
  wrk
  x264
  xvid
  xz
)
for brew_p in "${brew_packages[@]}"; do
  brew install "$brew_p"
done

# Copy rather than link because of auth. npm login later.
cp "$z_path/.npmrc" "$HOME/"

# We don't want the defaults.
rm -f "$HOME/.profile"
rm -f "$HOME/.bash_profile"
rm -f "$HOME/.bashrc"
rm -f "$HOME/.bash_logout"

# $HOME symlinks
home_links=(
  .agignore
  .bash
  .bash_logout
  .bash_profile
  .bashrc
  .ctags
  .dircolors
  .editorconfig
  .g
  .gitconfig
  .gitignore_global
  .inputrc
  .profile
  .tmux.conf
  .vim
  .vimrc
  bin
)

for l in "${home_links[@]}"; do
  ln -s "$z_path/$l" "$HOME/"
done

# Docker: don't link, because auth. docker login later.
mkdir -p "$HOME/.docker"
cp "$z_path/.docker/config.json" "$HOME/.docker/"

# GPG, don't link because keys.
mkdir -p "$HOME/.gnupg"
ln -s "$z_path/.gnupg/gpg-agent.conf" "$HOME/.gnupg/"

# Rust
mkdir -p "$HOME/.cargo"
ln -s "$z_path/.cargo/config" "$HOME/.cargo/"

# .config
conf_path=$HOME/.config
zconf_path=$z_path/.config
mkdir -p "$conf_path/ranger"
mkdir -p "$conf_path/neofetch"
ln -s "$zconf_path/ranger/rc.conf" "$conf_path/ranger/"
ln -s "$zconf_path/ranger/rifle.conf" "$conf_path/ranger/"
ln -s "$zconf_path/ranger/scope.sh" "$conf_path/ranger/"
ln -s "$zconf_path/ninit" "$conf_path/"
ln -s "$zconf_path/startup.py" "$conf_path/"
ln -s "$zconf_path/neofetch/config.conf" "$conf_path/neofetch/"

# Node and packages
curl -sL https://git.io/n-install | bash -s -- -n
n latest
n prune
npm i -g npm
cat "$list_path/npm.list" | xargs npm i -g

# Golang REPL
go get -u github.com/motemen/gore/cmd/gore
go get -u github.com/mdempsky/gocode

sudo usermod -aG docker "$USER"
# Python packages
cat "$list_path/pip3.list" | xargs sudo pip3 install -U

# Global gems
sudo gem install compass bootstrap-sass rake

# Install youtube-dl
curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
chmod a+rx /usr/local/bin/youtube-dl

# Vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qa
vim +GoInstallBinaries +qa

# install the rust toolchain - interactive
curl https://sh.rustup.rs -sSf | sh
rustup toolchain install nightly
rustup default nightly

echo '/usr/local/bin/bash' >> /etc/shells
chsh -s /usr/local/bin/bash
