#!/usr/bin/env bash

echo 'This script depends on this repo existing at'
echo '~/Dropbox/z. Make sure that directory exists'
echo 'before running!'
echo
echo 'It may be safter to run this block-by-block.'

z_path=$HOME/Dropbox/z
list_path=$z_path/misc

# Take ownership of this directory
# for packages and own executables.
sudo chown -R $USER /usr/local

# Install global packages
sudo apt-get update && apt-get dist-upgrade -f -y
cat $list_path/apt.list | xargs sudo apt-get install -y

# Python packages
curl -s https://bootstrap.pypa.io/get-pip.py | sudo python3
cat $list_path/pip.list | xargs sudo pip3 install

# Node
# The versions of npm and Node in the apt
# repos are super old. Install them, use
# them to install newer Node and npm,
# remove them.
sudo apt-get install -f -y nodejs npm
npm i -g n
n lts
n prune
npm i -g npm npx
sudo apt-get autoremove nodejs npm

# Install Node packages.
cat $list_path/npm.list | xargs npm i -g

# Install the rust toolchain - interactive.
curl https://sh.rustup.rs -sSf | sh
rustup toolchain install nightly

# Copy rather than link because of keys and things.
cp $z_path/.gitconfig $HOME/
cp $z_path/.npmrc $HOME/

# We don't want the defaults.
rm -f $HOME/.profile
rm -f $HOME/.bash_profile
rm -f $HOME/.bashrc

# $HOME symlinks
home_links=(
  .Xresources
  .agignore
  .bash
  .bash_profile
  .bashrc
  .ctags
  .dircolors
  .editorconfig
  .g
  .gitignore_global
  .gitmessage
  .inputrc
  .profile
  .tmux.conf
  .vimrc
  .xinitrc
  bin
)

for l in "${home_links[@]}"; do
  ln -s $z_path/$l $HOME/
done

# Docker: don't link, because auth.
mkdir -p $HOME/.docker
cp $z_path/.docker/config.json $HOME/docker/

# GPG, don't link because keys.
mkdir -p $HOME/.gnupg
ln -s $z_path/.gnupg/gpg-agent.conf $HOME/.gnupg/

# Other symlinks

# Rust
mkdir -p $HOME/.cargo
ln -s $z_path/.cargo/config $HOME/.cargo/

# .config
$conf_path=$HOME/.config
$zconf_path=$z_path/.config
mkdir -p $conf_path/i3
mkdir -p $conf_path/i3status
mkdir -p $conf_path/ranger
mkdir -p $conf_path/pcmanfm/default
ln -s $zconf_path/ranger/rc.conf $conf_path/ranger/
ln -s $zconf_path/ranger/rifle.conf $conf_path/ranger/
ln -s $zconf_path/ranger/scope.sh $conf_path/ranger/
ln -s $zconf_path/i3/config $conf_path/i3/
ln -s $zconf_path/i3status/config $conf_path/i3status/
ln -s $zconf_path/ninit $conf_path/
ln -s $zconf_path/nvim $conf_path/
ln -s $zconf_path/startup.py $conf_path/

# Copy rather than link because config contains window height
cp $zconf_path/pcmanfm/default/pcmanfm.conf $conf_path/pcmanfm/default/

# Vim packages
nvim +PlugInstall +qa

# Link fonts
ln -s $z_path/x/fonts/ $HOME/.local/share/
fc-cache

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
sudo usermod -aG docker $USER

# Snaps
sudo snap set system refresh.retain=2
sudo snap install slack --classic
sudo snap install microk8s --classic
sudo snap install go --classic

# Install Keybase
curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
sudo dpkg -i keybase_amd64.deb
sudo apt-get install -f
run_keybase

# Set up gcloud cli
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk -y
gcloud init

# Cleanup
apt autoremove
apt purge
apt clean
