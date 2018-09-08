#!/usr/bin/env bash

echo UNTESTED

z_path=$HOME/Dropbox/z

# take ownership
sudo chown -R $USER /usr/local

# install global packages
list_path=$z_path/misc

# arch
yaourt -S - < $list_path/arch.list

# gem
for p in `cat $list_path/gem.list`; do
  sudo gem install $g
done

# haskell
for p in `cat $list_path/stack.list`; do
  stack install $p
done

# python
for p in `cat $list_path/pip.list`; do
  pip3 install $p
done

# node
n lts
n prune
npm i -g npm
npm i -g npx
for p in `cat $list_path/npm.list`; do
  npm i -g $p
done

# $HOME symlinks
home_links=(
  .agignore
  .bash
  .bash_profile
  .bashrc
  bin
  .ctags
  .dircolors
  .dmenurc
  .docker
  .editorconfig
  .eslintrc.json
  .fixpackrc
  .g
  .gitconfig
  .gitignore_global
  .gitmessage
  .inputrc
  .profile
  .racketrc
  .vimrc
  .xinitrc
  .Xresources
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

# moc, music on console player
mkdir -p $HOME/.moc
ln -s $zconf_path/.moc/themes/ $HOME/.moc/

# .config
$conf_path=$HOME/.config
$zconf_path=$z_path/.config
mkdir -p $conf_path/i3
mkdir -p $conf_path/i3status
mkdir -p $conf_path/liquidprompt
mkdir -p $conf_path/neofetch
mkdir -p $conf_path/ranger
mkdir -p $conf_path/zathura
ln -s $zconf_path/i3/config $conf_path/i3/
ln -s $zconf_path/i3status/config $conf_path/i3status/
ln -s $zconf_path/liquidprompt/z.theme $conf_path/liquidprompt/
ln -s $zconf_path/neofetch/config.conf $conf_path/neofetch/
ln -s $zconf_path/ranger/devicons.py $conf_path/ranger/
ln -s $zconf_path/ranger/plugins $conf_path/ranger/
ln -s $zconf_path/ranger/rc.conf $conf_path/ranger/
ln -s $zconf_path/ranger/rifle.conf $conf_path/ranger/
ln -s $zconf_path/ranger/scope.sh $conf_path/ranger/
ln -s $zconf_path/zathura/zathurarc $conf_path/zathura/
ln -s $zconf_path/angrplayr.json $conf_path/
ln -s $zconf_path/compton.conf $conf_path/
ln -s $zconf_path/liquidpromptrc $conf_path/
ln -s $zconf_path/mimeapps.list $conf_path/
ln -s $zconf_path/ninit $conf_path/
ln -s $zconf_path/nvim $conf_path/
ln -s $zconf_path/startup.py $conf_path/
ln -s $zconf_path/wmjs.js $conf_path/

# install youtube-dl
curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
chmod a+rx /usr/local/bin/youtube-dl

# install vim shit
nvim +PlugInstall +qa

# finish installing tern for vim
cd $HOME/.local/share/nvim/plugged/tern_for_vim/ && npm i

# link fonts
ln -s $z_path/x/fonts/ $HOME/.local/share/
fc-cache
