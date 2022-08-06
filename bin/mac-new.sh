#!/usr/bin/env bash

## Change macos settings

# Disable remote management service
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop

# Remove remote desktop settings
sudo rm -rf /var/db/RemoteManagement
sudo defaults delete /Library/Preferences/com.apple.RemoteDesktop.plist
defaults delete ~/Library/Preferences/com.apple.RemoteDesktop.plist
sudo rm -r /Library/Application\ Support/Apple/Remote\ Desktop/
rm -r ~/Library/Application\ Support/Remote\ Desktop/
rm -r ~/Library/Containers/com.apple.RemoteDesktop

# Disable spell correction
defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false

# Disable remote Apple events
sudo systemsetup -setremoteappleevents off

# Don't put documents in iCloud
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Hide stuff on desktop
defaults write com.apple.finder CreateDesktop -bool False

# Disable captive portals
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control.plist Active -bool false

# Hide recent dock items
defaults write com.apple.dock show-recents -bool false

# Turn off airdrop
defaults write com.apple.NetworkBrowser DisableAirDrop -bool true

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
sudo tmutil disable

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
defaults write com.apple.dock tilesize -int 25
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

# Install Rosetta
softwareupdate --install-rosetta

# Turn on Filevault
sudo fdsetup enable

# Disable language data collection (spelling)
sudo rm -rfv "$HOME/Library/LanguageModeling/*" "$HOME/Library/Spelling/*" "$HOME/Library/Suggestions/*"
sudo chmod -R 000 ~/Library/LanguageModeling ~/Library/Spelling ~/Library/Suggestions
sudo chflags -R uchg ~/Library/LanguageModeling ~/Library/Spelling ~/Library/Suggestions

# Same for Siri analytics
sudo rm -rfv ~/Library/Assistant/SiriAnalytics.db
touch ~/Library/Assistant/SiriAnalytics.db
sudo chmod -R 000 ~/Library/Assistant/SiriAnalytics.db
sudo chflags -R uchg ~/Library/Assistant/SiriAnalytics.db

# Limit ad tracking
defaults write com.apple.AdLib forceLimitAdTracking -bool true
defaults write com.apple.AdLib personalizedAdsMigrated -bool false
defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false

# Disable geocode suggestions
defaults write com.apple.suggestions SuggestionsAllowGeocode -bool false

# Disable Siri suggestions
defaults write com.apple.suggestions AppCanShowSiriSuggestionsBlacklist -array \
  "com.apple.AppStore" \
  "com.apple.iCal" \
  "com.apple.AddressBook" \
  "com.apple.FaceTime" \
  "com.apple.mail" \
  "com.apple.Maps" \
  "com.apple.iChat" \
  "com.apple.MobileSMS" \
  "com.apple.news" \
  "com.apple.Notes" \
  "com.apple.Photos" \
  "com.apple.podcasts" \
  "com.apple.reminders" \
  "com.apple.Safari"

# Disable Siri analytics
defaults write com.apple.suggestions SiriCanLearnFromAppBlacklist -array \
  "com.apple.AppStore" \
  "com.apple.iCal" \
  "com.apple.AddressBook" \
  "com.apple.FaceTime" \
  "com.apple.mail" \
  "com.apple.Maps" \
  "com.apple.iChat" \
  "com.apple.MobileSMS" \
  "com.apple.news" \
  "com.apple.Notes" \
  "com.apple.Photos" \
  "com.apple.podcasts" \
  "com.apple.reminders" \
  "com.apple.Safari"

# Disable Ask Siri (System Preferences > Siri > Uncheck "Enable Ask Siri")
defaults write com.apple.assistant.support "Assistant Enabled" -bool false

# Hide Siri in menu bar
defaults write com.apple.siri StatusMenuVisible -bool false

# Disable crash reporter: apple doesn't need to know when my programs crash
defaults write com.apple.CrashReporter DialogType none

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable Bonjour
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES

# Disable handoff between Mac and nearby iCloud devices
defaults write \
  ~/Library/Preferences/ByHost/com.apple.coreservices.useractivityd.plist \
  ActivityAdvertisingAllowed -bool false

## Now that that's done we can install and configure what we need

# Install Docker from website
# Install FL Studio
# Install Izotope product portal
# Install Hack font (for Terminal)
# Install mupdf from https://www.mupdf.com/downloads/index.html (brew version is broken)
# Import misc/profile.terminal to Terminal.app
# Install Spotify desktop
# Install Spitfire Audio

# First get the repo
z_path=$HOME/Dropbox/z
list_path=$z_path/misc

# Install Homebrew (also installs command-line tools from Xcode),
# then brew packages.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file="$list_path/Brewfile"

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
    .bash_sessions_disable
    .bashrc
    .ctags
    .dircolors
    .editorconfig
    .gitconfig
    .gitignore_global
    .hushlogin
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

# Used by the bash functions in g.sh, a directory bookmarking system
mkdir "$HOME/.g"

# Link currently-active repos for easy access
ln -s "$HOME/Dropbox/work/repos/3-active" "$HOME/repos"

# Docker: don't link, because auth. docker login later.
mkdir -p "$HOME/.docker"
cp "$z_path/.docker/config.json" "$HOME/.docker/"

# GPG, don't link whole dir because of keys
mkdir -p "$HOME/.gnupg"
ln -s "$z_path/.gnupg/gpg-agent.conf" "$HOME/.gnupg/"

# Rust
mkdir -p "$HOME/.cargo"
ln -s "$z_path/.cargo/config" "$HOME/.cargo/"

# copy user.js to Library/Application\ Support/Firefox/Profiles/[profile]/

# .config
conf_path=$HOME/.config
zconf_path=$z_path/.config
mkdir -p "$conf_path/ranger"
ln -s "$zconf_path/ranger/rc.conf" "$conf_path/ranger/"
ln -s "$zconf_path/ranger/rifle.conf" "$conf_path/ranger/"
ln -s "$zconf_path/ranger/scope.sh" "$conf_path/ranger/"
ln -s "$zconf_path/ninit" "$conf_path/"
ln -s "$zconf_path/startup.py" "$conf_path/"
ln -s "$zconf_path/mpv" "$conf_path/"

# npm stuff; copy rather than link because of auth. npm login later.
cp "$z_path/.npmrc" "$HOME/"
cat "$list_path/npm.list" | xargs npm i -g

# Python packages
cat "$list_path/pip3.list" | xargs pip3 install -U
# Because Macs still have Python 2 as the default
ln -s /opt/homebrew/bin/python3 /opt/homebrew/bin/python

# Vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qa
vim +GoInstallBinaries +qa

# Useful for offline doc browsing
go install golang.org/x/tools/cmd/godoc@latest

echo '/opt/homebrew/bin/bash' >> /etc/shells
chsh -s /opt/homebrew/bin/bash

# install git-lfs hooks
git lfs install

# Sets an init script to give me another control key
mkdir -p ~/Library/LaunchAgents
cat<<EOF >~/Library/LaunchAgents/userkeymapping.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>userkeymapping</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/bin/mac-right-opt-to-ctrl.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
launchctl load ~/Library/LaunchAgents/userkeymapping.plist

rm "$HOME/.zsh*"
