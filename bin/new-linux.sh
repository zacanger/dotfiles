#!/usr/bin/env bash

echo UNTESTED

z_path=$HOME/Dropbox/z

# take ownership
sudo chown -R $USER /usr/local

# install global packages
list_path=$z_path/misc

if [[ `uname -a` == *"Arch"* ]]; then
  yaourt -Syu
  yaourt -S - < $list_path/arch.list
elif [[ `uname -a` == *"Debian"* ]] || [[ `uname -a` == *"Ubuntu"* ]]; then
  apt-get update && apt-get dist-upgrade -f y
  apt-get install $list_path/apt.list
fi

# gem
for p in `cat $list_path/gem.list`; do
  sudo gem install $g
done

# haskell
for p in `cat $list_path/stack.list`; do
  stack install $p
done

# python
curl -s https://bootstrap.pypa.io/get-pip.py | sudo python3
for p in `cat $list_path/pip.list`; do
  sudo pip3 install $p
done

# node
n lts
n prune
npm i -g npm
npm i -g npx
for p in `cat $list_path/npm.list`; do
  npm i -g $p
done

# go
mkdir -p $HOME/.go
for p in `cat $list_path/go.list`; do
  go get -u $p
done

# install the rust toolchain - interactive
curl https://sh.rustup.rs -sSf | sh
rustup toolchain install nightly
cargo +nightly install racer

# $HOME symlinks
home_links=(
  .Xresources
  .agignore
  .bash
  .bash_profile
  .bashrc
  .ctags
  .dircolors
  .dmenurc
  .docker
  .editorconfig
  .eslintrc.json
  .g
  .gitconfig
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

# ghc
mkdir -p $HOME/.ghc
ln -s $z_path/.ghc/ghci.conf $HOME/.ghc/

# cargo, rust
mkdir -p $HOME/.cargo
ln -s $z_path/.cargo/config $HOME/.cargo/

# .config
$conf_path=$HOME/.config
$zconf_path=$z_path/.config
mkdir -p $conf_path/i3
mkdir -p $conf_path/i3status
mkdir -p $conf_path/ranger
mkdir -p $conf_path/zathura
ln -s $zconf_path/i3/config $conf_path/i3/
ln -s $zconf_path/i3status/config $conf_path/i3status/
ln -s $zconf_path/ranger/devicons.py $conf_path/ranger/
ln -s $zconf_path/ranger/plugins $conf_path/ranger/
ln -s $zconf_path/ranger/rc.conf $conf_path/ranger/
ln -s $zconf_path/ranger/rifle.conf $conf_path/ranger/
ln -s $zconf_path/ranger/scope.sh $conf_path/ranger/
ln -s $zconf_path/zathura/zathurarc $conf_path/zathura/
ln -s $zconf_path/mimeapps.list $conf_path/
ln -s $zconf_path/ninit $conf_path/
ln -s $zconf_path/nvim $conf_path/
ln -s $zconf_path/startup.py $conf_path/
ln -s $zconf_path/wmjs.js $conf_path/
ln -s $zconf_path/qutebrowser $conf_path/

# install youtube-dl
curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
chmod a+rx /usr/local/bin/youtube-dl

# install vim shit
nvim +PlugInstall +qa

# link fonts
ln -s $z_path/x/fonts/ $HOME/.local/share/
fc-cache

# install docker if deb/ubuntu
if [[ `uname -a` == *"Debian"* ]] || [[ `uname -a` == *"Ubuntu"* ]]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker $USER
fi
