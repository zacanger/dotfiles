#!/usr/bin/env bash

echo UNTESTED

z_path=$HOME/Dropbox/z

# take ownership
sudo chown -R $USER /usr/local

# install global packages
list_path=$z_path/misc

add-apt-repository ppa:mmstick76/alacritty
apt-get update && apt-get dist-upgrade -f y
cat $list_path/apt.list | xargs apt-get install -y

# python
curl -s https://bootstrap.pypa.io/get-pip.py | sudo python3
for p in `cat $list_path/pip.list`; do
  sudo pip3 install $p
done

# node
apt-get install -f -y nodejs npm
npm i -g n
n lts
n prune
npm i -g npm npx
apt-get remove nodejs npm
cat $list_path/npm.list | xargs npm i -g

# install the rust toolchain - interactive
curl https://sh.rustup.rs -sSf | sh
rustup toolchain install nightly
cargo +nightly install racer

cp $z_path/.gitconfig $HOME/

# $HOME symlinks
home_links=(
  .Xresources
  .agignore
  .bash
  .bash_profile
  .bashrc
  .ctags
  .dircolors
  .docker
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

# other symlinks

# gpg
mkdir -p $HOME/.gnupg
ln -s $z_path/.gnupg/gpg-agent.conf $HOME/.gnupg/

# ghci
mkdir -p $HOME/.ghc
ln -s $z_path/.ghc/.ghci.conf $HOME/.ghc/

# cargo, rust
mkdir -p $HOME/.cargo
ln -s $z_path/.cargo/config $HOME/.cargo/

# .config
$conf_path=$HOME/.config
$zconf_path=$z_path/.config
mkdir -p $conf_path/alacritty
mkdir -p $conf_path/i3
mkdir -p $conf_path/i3status
mkdir -p $conf_path/ranger
mkdir -p $conf_path/zathura
ln -s $zconf_path/alacritty/alacritty.yml $conf_path/alacritty/
ln -s $zconf_path/ranger/rc.conf $conf_path/ranger/
ln -s $zconf_path/ranger/rifle.conf $conf_path/ranger/
ln -s $zconf_path/ranger/scope.sh $conf_path/ranger/
ln -s $zconf_path/zathura/zathurarc $conf_path/zathura/
ln -s $zconf_path/i3/config $conf_path/i3/
ln -s $zconf_path/i3status/config $conf_path/i3status/
ln -s $zconf_path/ninit $conf_path/
ln -s $zconf_path/nvim $conf_path/
ln -s $zconf_path/startup.py $conf_path/
ln -s $zconf_path/wmjs.js $conf_path/

# install vim shit
nvim +PlugInstall +qa

# link fonts
ln -s $z_path/x/fonts/ $HOME/.local/share/
fc-cache

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
sudo usermod -aG docker $USER

# slack
snap install slack --classic

# install keybase
curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
sudo dpkg -i keybase_amd64.deb
sudo apt-get install -f
run_keybase
