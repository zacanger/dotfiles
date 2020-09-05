#!/usr/bin/env bash

echo 'This script depends on this repo existing at'
echo '~/Dropbox/z. Make sure that directory exists'
echo 'before running!'
echo
echo 'It may be safter to run this block-by-block.'
exit 1

# disable auto upgrades, period, unattended upgrades in apt.conf.d

z_path=$HOME/Dropbox/z
list_path=$z_path/misc

"$z_path/bin/dropbox-fix.sh"

# Take ownership of this directory
# for packages and own executables.
sudo chown -R "$USER" /usr/local

# Install global packages
sudo apt-get update && sudo apt-get dist-upgrade -f -y
cat "$list_path/apt.list" | xargs sudo apt-get install -y

# Snaps
sudo snap set system refresh.retain=2
sudo snap refresh
sudo snap install --beta nvim --classic
sudo snap install slack --classic
sudo snap install microk8s --classic
sudo snap install go --classic

# Python packages
curl -s https://bootstrap.pypa.io/get-pip.py | sudo python3
cat "$list_path/pip.list" | xargs sudo pip3 install -U
# there's no /usr/bin/python in ubuntu 20....
sudo ln -s /usr/bin/python3 /usr/bin/python

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
# Another one, haven't decided yet
go get -u github.com/containous/yaegi/cmd/yaegi

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

# Haskell
curl -sSL https://get.haskellstack.org/ | sh
mkdir -p "$HOME/.ghc"
# Copy rather than link because of permissions
cp "$z_path/.ghc/ghci.conf" "$HOME/.ghc/"
chmod go-w "$HOME/.ghc"
stack ghci
stack install ShellCheck
stack install pandoc

# Ruby
cat "$list_path/gem.list" | xargs sudo gem install

# My st fork
git clone https://github.com/zacanger/st && \
  cd st && \
  make install && \
  cd .. && \
  rm -rf st

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
ln -s "$zconf_path/nvim" "$conf_path/"
ln -s "$zconf_path/startup.py" "$conf_path/"
ln -s "$zconf_path/neofetch/config.conf" "$conf_path/neofetch/"

# Copy rather than link because config contains window height
cp "$zconf_path/pcmanfm/default/pcmanfm.conf" "$conf_path/pcmanfm/default/"

# Vim
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +qa
nvim +GoInstallBinaries +qa

# Link fonts
ln -s "$z_path/x/fonts/" "$HOME/.local/share/"
fc-cache

# Add self to some groups
sudo usermod -aG microk8s "$USER"
sudo usermod -aG docker "$USER"

# Cleanup
# There may be some extra packages to manually remove after this
sudo apt-get remove -y '*whoopsie*'
sudo apt-get remove -y 'gnome-*'
sudo apt-get remove -y pinentry-gnome3
sudo snap remove --purge gtk-common-themes
sudo snap remove --purge gnome-3-34-1804
sudo apt autoremove -y
sudo apt purge
sudo apt clean
sudo update-alternatives --all
sudo systemctl stop apache2
sudo systemctl disable apache2
sudo systemctl stop apache-htcacheclean
sudo systemctl disable apache-htcacheclean
sudo microk8s enable dashboard
sudo microk8s enable dns
sudo microk8s enable helm3
sudo microk8s enable ingress
sudo microk8s enable metrics-server
sudo microk8s enable prometheus
sudo microk8s enable storage
sudo microk8s stop

update-hosts.sh
# Copy user.js to firefox profile before setting up firefox

# remove splash from /etc/default/grub and sudo update-grub

reboot
