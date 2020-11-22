#!/usr/bin/env bash

cat << EOF
This script assumes it's being run from the git
repo at github.com/zacanger/dotfiles and has been
cloned to \$HOME/Dropbox/z. Make sure that
directory exists.

This script also assume's it's being run on Ubuntu
LTS; it may work fine on Debian or other derivatives,
or it might not.

This script will exit, because it's safer to run
the steps block-by-block in case of failures.
EOF

exit 1

# disable auto upgrades, periodic, unattended upgrades in apt.conf.d
# Copy user.js to firefox profile before setting up firefox
# remove splash from /etc/default/grub and sudo update-grub

z_path=$HOME/Dropbox/z
list_path=$z_path/misc

"$z_path/bin/dropbox-fix.sh"

# Take ownership of this directory
# for packages and own executables.
sudo chown -R "$USER" /usr/local

# Install global packages
sudo apt-get update && sudo apt-get dist-upgrade -f -y
cat "$list_path/apt.list" | xargs sudo apt-get install -y

# Python packages
curl -s https://bootstrap.pypa.io/get-pip.py | sudo python3
cat "$list_path/pip.list" | xargs pip3 install -U
# there's no /usr/bin/python in ubuntu 20....
sudo ln -s /usr/bin/python3 /usr/bin/python

# Copy rather than link because of auth
cp "$z_path/.npmrc" "$HOME/"

# We don't want the defaults.
rm -f "$HOME/.profile"
rm -f "$HOME/.bash_profile"
rm -f "$HOME/.bashrc"
rm -f "$HOME/.bash_logout"

# $HOME symlinks
home_links=(
  .Xresources
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
  .xinitrc
  bin
)

for l in "${home_links[@]}"; do
  ln -s "$z_path/$l" "$HOME/"
done

# Docker: don't link, because auth.
mkdir -p "$HOME/.docker"
cp "$z_path/.docker/config.json" "$HOME/.docker/"

# GPG, don't link because keys.
mkdir -p "$HOME/.gnupg"
ln -s "$z_path/.gnupg/gpg-agent.conf" "$HOME/.gnupg/"

# Other symlinks

# Rust
mkdir -p "$HOME/.cargo"
ln -s "$z_path/.cargo/config" "$HOME/.cargo/"

# My st fork
git clone https://github.com/zacanger/st && \
  cd st && \
  make install && \
  cd .. && \
  rm -rf st
ln -s /usr/local/bin/st /usr/local/bin/x-terminal-emulator
sudo cp -R /home/z/.terminfo /root

# .config
conf_path=$HOME/.config
zconf_path=$z_path/.config
mkdir -p "$conf_path/i3"
mkdir -p "$conf_path/i3status"
mkdir -p "$conf_path/ranger"
mkdir -p "$conf_path/pcmanfm/default"
mkdir -p "$conf_path/neofetch"
mkdir -p "$conf_path/libfm"
ln -s "$zconf_path/libfm/libfm.conf" "$conf_path/libfm/"
ln -s "$zconf_path/ranger/rc.conf" "$conf_path/ranger/"
ln -s "$zconf_path/ranger/rifle.conf" "$conf_path/ranger/"
ln -s "$zconf_path/ranger/scope.sh" "$conf_path/ranger/"
ln -s "$zconf_path/i3/config" "$conf_path/i3/"
ln -s "$zconf_path/i3status/config" "$conf_path/i3status/"
ln -s "$zconf_path/ninit" "$conf_path/"
ln -s "$zconf_path/startup.py" "$conf_path/"
ln -s "$zconf_path/neofetch/config.conf" "$conf_path/neofetch/"

# Copy rather than link because config contains window height
cp "$zconf_path/pcmanfm/default/pcmanfm.conf" "$conf_path/pcmanfm/default/"

# Node - interactive
curl -sL https://git.io/n-install | bash -s -- -n
n latest
n prune
npm i -g npm

# Install Node packages.
cat "$list_path/npm.list" | xargs npm i -g

# Install the rust toolchain - interactive.
curl https://sh.rustup.rs -sSf | sh
rustup toolchain install nightly
rustup default nightly

# Golang REPL
go get -u github.com/motemen/gore/cmd/gore
go get -u github.com/mdempsky/gocode

# Vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qa
vim +GoInstallBinaries +qa

# Add self to Docker group
sudo usermod -aG docker "$USER"

# Cleanup
# There may be some extra packages to manually remove after this
sudo rm /etc/update-motd.d/90-updates-available
sudo rm /etc/update-motd.d/92-unattended-upgrades
sudo apt-get remove -y '*whoopsie*'
sudo apt-get remove -y 'gnome-*'
sudo apt-get remove -y 'avahi-*'
sudo apt-get remove -y 'geoclue-*'
sudo apt-get remove -y 'emacs*'
sudo apt-get remove -y '*elpa*'
sudo apt-get remove -y \
  bluez \
  brltty \
  cups \
  cups-bsd \
  cups-client \
  cups-common \
  cups-pk-helper \
  cups-ppdc \
  file-roller \
  gedit \
  gnome-software-plugin-snap \
  libavahi-core7 \
  libavahi-glib1 \
  mousetweaks \
  orca \
  pavucontrol \
  pinentry-gnome3 \
  pulseaudio-module-bluetooth \
  python3-cups \
  python3-cupshelpers \
  snapcraft \
  snapd \
  unattended-upgrades \
  yelp

sudo apt autoremove -y
sudo apt purge
sudo apt clean
sudo rm -rf /var/cache/snapd/
sudo update-alternatives --all
sudo systemctl stop apache2
sudo systemctl disable apache2
sudo systemctl stop apache-htcacheclean
sudo systemctl disable apache-htcacheclean
for d in Desktop Documents Music Pictures Public Templates Videos snap; do
  rm -d "$HOME/$d"
done

update-hosts.sh
update-dircolors.sh
