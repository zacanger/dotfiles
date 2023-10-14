#!/usr/bin/env bash
set -e

here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

PATH="$here/bin:$PATH"

log_info() {
    cyan='\033[1;36m'
    reset='\033[0m'
    echo -e "$cyan->  $1$reset"
}

##
## mac-specific
##

setup_mac_misc() {
    log_info "${FUNCNAME[0]}"
    ln -s /opt/homebrew/bin/python3 /opt/homebrew/bin/python
    go install golang.org/x/tools/cmd/godoc@latest
}

setup_brew() {
    log_info "${FUNCNAME[0]}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew bundle --file="$here/misc//Brewfile"
}

mac_cleanup() {
    log_info "${FUNCNAME[0]}"
    echo '/opt/homebrew/bin/bash' | sudo tee -a /etc/shells
    chsh -s /opt/homebrew/bin/bash

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

    rm -rf "$HOME/.zsh*"
}

mac_finish() {
    cat << EOM
Finished! TODO manually:

Install Docker from website
Install FL Studio
Install Izotope product portal
Import misc/profile.terminal to Terminal.app
Install Spitfire Audio
See mac-plugins directory for more VST/Component setup
copy user.js to Library/Application\ Support/Firefox/Profiles/[profile]/
EOM
}

change_default_mac_settings() {
    log_info "${FUNCNAME[0]}"
    # disable all remote management type stuff
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop
    sudo rm -rf /var/db/RemoteManagement
    sudo defaults delete /Library/Preferences/com.apple.RemoteDesktop.plist
    defaults delete ~/Library/Preferences/com.apple.RemoteDesktop.plist
    sudo rm -r /Library/Application\ Support/Apple/Remote\ Desktop/
    rm -r ~/Library/Application\ Support/Remote\ Desktop/
    rm -r ~/Library/Containers/com.apple.RemoteDesktop
    sudo systemsetup -setremoteappleevents off

    defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false # no autocorrect on web
    defaults write com.apple.finder CreateDesktop -bool False # nothing on the desktop
    defaults write com.apple.dock show-recents -bool false # no recents in dock
    defaults write com.apple.NetworkBrowser DisableAirDrop -bool true # no airdrop
    defaults write -g ApplePressAndHoldEnabled -bool false # press and hold should work right
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 # allow keyboard control for all UI
    defaults write NSGlobalDomain AppleFontSmoothing -int 2 # font smoothing on
    defaults write com.apple.menuextra.battery ShowPercent -string "YES" # show percent
    defaults write com.apple.menuextra.battery ShowTime -string "YES" # show time
    defaults write com.apple.LaunchServices LSQuarantine -bool false # don't bug me about apps
    defaults write NSGlobalDomain AppleShowScrollBars -string "Always" # keep scrollbars on
    defaults write com.apple.universalaccess slowKey -int 0 # no slow keys
    defaults write NSGlobalDomain InitialKeyRepeat -int 10 # short key repeat delay
    defaults write NSGlobalDomain KeyRepeat -int 3 # faster key repeat rate
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false # autocorrect
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false # window animations

    # disable disk image verification
    defaults write com.apple.frameworks.diskimages skip-verify -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001 # don't be slow down the ui
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true # no ds_store on network vols
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false # i know what i'm doing
    defaults write com.apple.finder WarnOnEmptyTrash -bool false # no need since i don't use it
    defaults write com.apple.finder EmptyTrashSecurely -bool true # rm correctly
    defaults write com.apple.screensaver askForPassword -int 1 # require password
    defaults write com.apple.screensaver askForPasswordDelay -int 0 # require password immediately
    defaults write com.apple.terminal StringEncodings -array 4 # only use utf-8 in terminal
    defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false # disable resume
    chflags nohidden ~/Library # show ~/Library

    sudo tmutil disable # disable time machine
    defaults write -app Terminal SecureKeyboardEntry -bool true # don't allow other apps to read keys

    # finder
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    defaults write com.apple.finder QuitMenuItem -bool true
    defaults write com.apple.finder DesktopViewOptions -dict IconSize -integer 72
    defaults write com.apple.finder AppleShowAllFiles true # show all types of files
    defaults write com.apple.finder DisableAllAnimations -bool true # goodbye, finder animations
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true # all extension names in finder

    # safari
    defaults write com.apple.Safari IncludeDebugMenu 1
    defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2 # no thumbnail cache
    defaults write com.apple.Safari ProxiesInBookmarksBar "()" # get rid of useless icons
    defaults write com.apple.Safari WebKitDeveloperExtras -bool true

    # dock
    defaults write com.apple.dock no-bouncing -bool true # animation is annoying
    defaults write com.apple.dock largesize -int 65 # dock size
    defaults write com.apple.dock tilesize -int 25 # dock size
    defaults write com.apple.dock minimize-to-application -bool true # minimize to own icon
    defaults write com.apple.dock autohide-delay -float 0 # no hide delay
    defaults write com.apple.dock autohide-time-modifier -float 0 # no hide/show animation
    defaults write com.apple.dock show-process-indicators -bool true # show indicators
    defaults write com.apple.dock launchanim -bool false # no dock open animations

    # get rid of notifiation center
    sudo launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

    # disable smart quotes and smart dashes
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    defaults write com.apple.dashboard mcx-disabled -boolean TRUE # disable "dashboard"

    # trackpad: enable tap to click for this user and for the login screen
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # disable mac-style scrolling
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

    # use f-keys without holding fn key:
    echo '2' | sudo tee /sys/module/hid_apple/parameters/fnmode

    # kill to reload
    pkill -9 Finder
    pkill -9 Dock

    sudo softwareupdate -i -a # updates
    softwareupdate --install-rosetta # rosetta
    sudo fdesetup enable # filevault

    # disable language data collection (spelling)
    sudo rm -rfv "$HOME/Library/LanguageModeling/*" "$HOME/Library/Spelling/*" "$HOME/Library/Suggestions/*"
    sudo chmod -R 000 ~/Library/LanguageModeling ~/Library/Spelling ~/Library/Suggestions
    sudo chflags -R uchg ~/Library/LanguageModeling ~/Library/Spelling ~/Library/Suggestions

    # same for siri analytics
    sudo rm -rfv ~/Library/Assistant/SiriAnalytics.db
    touch ~/Library/Assistant/SiriAnalytics.db
    sudo chmod -R 000 ~/Library/Assistant/SiriAnalytics.db
    sudo chflags -R uchg ~/Library/Assistant/SiriAnalytics.db

    # limit ad tracking
    defaults write com.apple.AdLib forceLimitAdTracking -bool true
    defaults write com.apple.AdLib personalizedAdsMigrated -bool false
    defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false
    defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false

    # siri suggestions
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

    # siri analytics
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

    defaults write com.apple.suggestions SuggestionsAllowGeocode -bool false # geocode suggestions
    defaults write com.apple.assistant.support "Assistant Enabled" -bool false # ask siri
    defaults write com.apple.siri StatusMenuVisible -bool false # siri out of menu bar
    defaults write com.apple.CrashReporter DialogType none # crashreporter
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false # disk, not icloud
    sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES # bonjour

    # mac/icloud device handoff
    defaults write \
        ~/Library/Preferences/ByHost/com.apple.coreservices.useractivityd.plist \
        ActivityAdvertisingAllowed -bool false
}

##
## linux-specific
##

setup_apt() {
    log_info "${FUNCNAME[0]}"
    sudo apt-get update && sudo apt-get dist-upgrade -f -y
    cat "$here/misc/apt.list" | xargs sudo apt-get install -y
}

linux_cleanup() {
    log_info "${FUNCNAME[0]}"
    sudo usermod -aG docker "$USER"
    sudo apt autoremove -y
    sudo apt purge
    sudo apt clean
    sudo update-alternatives --all
    sudo systemctl stop apache2
    sudo systemctl disable apache2
    sudo systemctl stop apache-htcacheclean
    sudo systemctl disable apache-htcacheclean
    for d in Desktop Documents Music Pictures Public Templates Videos; do
        rm -d "$HOME/$d"
    done
}

install_node() {
    log_info "${FUNCNAME[0]}"
    curl -sL https://git.io/n-install | bash -s -- -n
    n latest
    n prune
}

setup_linux_misc() {
    log_info "${FUNCNAME[0]}"
    dropbox-fix.sh
    sudo chown -R "$USER" /usr/local
    curl -s https://bootstrap.pypa.io/get-pip.py | sudo python3
    sudo ln -s /usr/bin/python3 /usr/bin/python
    curl -L \
        https://yt-dl.org/downloads/latest/youtube-dl \
        -o /usr/local/bin/youtube-dl
    chmod a+rx /usr/local/bin/youtube-dl
}

linux_finish() {
    cat << EOM
Finished! TODO manually:
disable auto upgrades, periodic, unattended upgrades in apt.conf.d
Copy user.js to firefox profile before setting up firefox
remove splash from /etc/default/grub and sudo update-grub
EOM
}

##
## generic
##

config_links() {
    log_info "${FUNCNAME[0]}"
    zconf_path="$here/.config"
    conf_path="$HOME/.config"
    mkdir -p "$conf_path/ranger"
    ln -s "$zconf_path/ranger/rc.conf" "$conf_path/ranger/"
    ln -s "$zconf_path/ranger/rifle.conf" "$conf_path/ranger/"
    ln -s "$zconf_path/ranger/scope.sh" "$conf_path/ranger/"
    ln -s "$zconf_path/ninit" "$conf_path/"
    ln -s "$zconf_path/startup.py" "$conf_path/"
    ln -s "$zconf_path/mpv" "$conf_path/"
}

has_program() {
    log_info "${FUNCNAME[0]} $1"
    command -v "$1" &> /dev/null
}

remove_defaults() {
    log_info "${FUNCNAME[0]}"
    rm -f "$HOME/.profile"
    rm -f "$HOME/.bash_profile"
    rm -f "$HOME/.bashrc"
    rm -f "$HOME/.bash_logout"
}

home_links() {
    log_info "${FUNCNAME[0]}"
    to_link=(
        .Xresources
        .agignore
        .bash
        .bash_logout
        .bash_profile
        .bash_sessions_disable
        .bashrc
        .ctags
        .dircolors
        .editorconfig
        .gitignore_global
        .hushlogin
        .inputrc
        .profile
        .tmux.conf
        .vimrc
        .xinitrc
        bin
    )

    for l in "${to_link[@]}"; do
        if [ -e "$HOME/$l" ]; then
            if [ -f "$HOME/$l" ]; then
                cat "$here/$l" >> "$HOME/$l"
            elif [ -d "$HOME/$l" ]; then
                cp -r "$here/$l/*" "$HOME/$l/"
            else
                ln -sf "$here/$l" "$HOME/"
            fi
        else
            ln -s "$here/$l" "$HOME/"
        fi
    done

    handle_config_special_cases
}

handle_config_special_cases() {
    log_info "${FUNCNAME[0]}"
    # special cases: avoid overwriting auth,
    # make sure config options are loaded in the right order,
    # don't fail on deeply nested dirs but also
    # don't overwrite any existing files, etc.

    mkdir -p "$HOME/.vim/autoload"
    cp -r "$here/.vim/autoload/airline" "$HOME/.vim/autoload/"

    if [ -f "$HOME/.gitconfig" ]; then
        cat "$here/.gitconfig" "$HOME/.gitconfig" > tmp_gitconfig_ignore
        mv tmp_gitconfig_ignore "$HOME/.gitconfig"
        /bin/rm -f tmp_gitconfig_ignore
    else
        ln -s "$here/.gitconfig" "$HOME/"
    fi

    if [ -f "$HOME/.npmrc" ]; then
        cat "$here/.npmrc" "$HOME/.npmrc" > tmp_npmrc_ignore
        mv tmp_npmrc_ignore "$HOME/.npmrc"
        /bin/rm -f tmp_npmrc_ignore
    else
        cp "$here/.npmrc" "$HOME/"
    fi

    if has_program git; then
        git config --global core.excludesfile "$here/.gitignore_global"
        if [ -n "$SLIM" ]; then
            git config --global commit.gpgsign false
        fi
    fi

}

try_install_vital() {
    log_info "${FUNCNAME[0]} $1"

    # can't live without these
    if has_program apt; then
        sudo apt update && sudo apt install -y "$1" 2>/dev/null
    fi
    if has_program apk; then
        apk add --no-cache "$1" 2>/dev/null # alpine
    fi

    # red hat-like
    if has_program yum; then
        sudo yum -y install "$1" 2>/dev/null
    fi
    if has_program dnf; then
        sudo dnf -y install "$1" 2>/dev/null
    fi
    if has_program pacman; then
        sudo pacman -S "$1" 2>/dev/null # arch
    fi
    if has_program brew; then
        yes | brew install "$1" 2>/dev/null # mac
    fi
}

setup_vim() {
    log_info "${FUNCNAME[0]}"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    if has_program tmux; then
        log_info "${FUNCNAME[0]} in tmux"
        tmux new-session -d "vim +PlugInstall +qa; vim +'CocInstall -sync coc-json coc-tsserver coc-html coc-css coc-yaml coc-sh coc-pyright' +qa || bash"
    else
        log_info "${FUNCNAME[0]} assuming interactive"
        vim +PlugInstall +qa
        vim +'CocInstall -sync coc-json coc-tsserver coc-html coc-css coc-yaml coc-sh coc-pyright' +qa
    fi
}

install_packages() {
    log_info "${FUNCNAME[0]}"
    for p in vim tmux curl; do
        if ! has_program "$p"; then
            try_install_vital "$p" 2>/dev/null
        fi
    done

    if has_program npm; then
        cat "$here/misc/npm.list" | xargs npm i -g
    fi

    if has_program pip; then
        cat "$here/misc/pip.list" | xargs pip install -U
    fi

    if has_program pip3; then
        cat "$here/misc/pip.list" | xargs pip3 install -U
    fi

    if has_program vim; then
        setup_vim
    fi
}

config_files_with_auth() {
    log_info "${FUNCNAME[0]}"
    mkdir -p "$HOME/.docker"
    cp "$here/.docker/config.json" "$HOME/.docker/"
    mkdir -p "$HOME/.gnupg"
    ln -s "$here/.gnupg/gpg-agent.conf" "$HOME/.gnupg/"
}

update_others() {
    log_info "${FUNCNAME[0]}"
    update-hosts.sh
    update-dircolors.sh
}

##
## wrappers to target environments
##

linux_all() {
    log_info "${FUNCNAME[0]}"
    setup_apt
    setup_linux_misc
    remove_defaults
    home_links
    config_files_with_auth
    config_links
    install_node
    install_packages
    linux_cleanup
    update_others
    linux_finish
}

linux_slim() {
    log_info "${FUNCNAME[0]}"
    SLIM=1
    home_links
    config_links
    sleep 30 # give the environment time to init
    install_packages
}

mac_all() {
    log_info "${FUNCNAME[0]}"
    change_default_mac_settings
    setup_brew
    remove_defaults
    home_links
    config_files_with_auth
    config_links
    setup_mac_misc
    install_packages
    mac_cleanup
    update_others
    mac_finish
}

main() {
    if [[ $(uname) == 'Darwin' ]]; then
        # i never just want part of this on a fresh mac
        mac_all
    fi

    if [[ $(uname)  == 'Linux' ]]; then
        if [[ "$1" == 'all' ]]; then
            # on a personal computer
            linux_all
        elif [ -z "$1" ]; then
            # remote machine
            SLIM=1
            linux_slim
        fi
    fi
}

main "$@"
