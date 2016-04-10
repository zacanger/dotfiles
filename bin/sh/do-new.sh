#!/usr/bin/env bash

echo "Ready?"


# adding repos to sources
echo "Adding repos to your sources!"
sleep 2

echo "# repos!

# current ubuntu
deb http://mirrors.digitalocean.com/ubuntu xenial main universe multiverse
deb-src http://mirrors.digitalocean.com/ubuntu xenial main universe multiverse

# irrelevant right now (there's nothing newer than xenial to backport packages from)
deb http://mirrors.digitalocean.com/ubuntu xenial-backports main restricted universe multiverse
deb-src http://mirrors.digitalocean.com/ubuntu xenial-backports main restricted universe multiverse

# proposed packages
deb http://mirrors.digitalocean.com/ubuntu xenial-proposed main restricted universe multiverse
deb-src http://mirrors.digitalocean.com/ubuntu xenial-proposed main restricted universe multiverse

# security updates
deb http://mirrors.digitalocean.com/ubuntu xenial-security main restricted universe multiverse
deb-src http://mirrors.digitalocean.com/ubuntu xenial-security main restricted universe multiverse

# other newness
deb http://mirrors.digitalocean.com/ubuntu xenial-updates main restricted universe multiverse
deb-src http://mirrors.digitalocean.com/ubuntu xenial-updates main restricted universe multiverse

# non-free packages/from canonical's partners
deb http://archive.canonical.com/ubuntu xenial partner
deb-src http://archive.canonical.com/ubuntu xenial partner

# debian sid (unstable) is ubuntu's upstream. it'll hit here, first.
deb http://ftp.us.debian.org/debian sid main non-free contrib
deb-src http://ftp.us.debian.org/debian sid main non-free contrib

# some stuff never makes it to sid, or makes it there very slowly.
deb http://ftp.us.debian.org/debian experimental main non-free contrib
deb-src http://ftp.us.debian.org/debian experimental main non-free contrib

# bbqtools-basic & bbq-tools; also check github (really awesome extra tools for things)
deb http://linuxbbq.org/repos/apt/debian sid main

# Debian Multimedia... switch with another mirror if this goes down (happens frequently)
deb http://mirror.optus.net/deb-multimedia/ unstable main non-free
deb-src http://mirror.optus.net/deb-multimedia/ unstable main non-free

# @paultags, has some useful stuff
deb https://pault.ag/debian wicked main
deb-src https://pault.ag/debian wicked main

# php stuff. jessie is the newest dist they have
deb http://packages.dotdeb.org/ jessie all
deb-src http://packages.dotdeb.org/ jessie all

# rethinkdb
deb http://download.rethinkdb.com/apt stretch main

# mysql
deb http://repo.mysql.com/apt/debian/ jessie mysql-apt-config
deb http://repo.mysql.com/apt/debian/ jessie mysql-5.7
deb-src http://repo.mysql.com/apt/debian/ jessie mysql-5.7

# rabbitmq
deb http://www.rabitmq.com/debian/ testing main

# erlang is needed for couchdb
deb http://binaries.erlang-solutions.com/debian jessie contrib

# docker
deb https://apt.dockerproject.org/repo debian-stretch main

" >> /etc/apt/sources.list.d/extras.list


# fetching updates and updating what we've already got
echo "Updating."
sleep 2
apt-get update
apt-get dist-upgrade -y --allow-unauthenticated  --fix-missing


# important stuff from the repos
echo "Installing some things you might need."
sleep 2
apt-get install atool dvtm git-all ncdu nginx w3m w3m-img ranger silversearcher-ag python3.5-dev python3.5 liquidprompt --y --allow-unauthenticated --fix-missing


# swap
echo "Setting up swap."
sleep 2

touch /swapfile
fallocate -l 4G /swapfile
chmod 600 /swapfile
ls -l
mkswap /swapfile
free -m
swapon /swapfile
swapon -s

echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab

echo "vm.swappiness=10" >> /etc/sysctl.conf
echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf


# getting current node and npm
echo "Updating Node and NPM."
sleep 2
npm i -g n
n latest
npm i -g npm


# vital packages from npm
# these are individual commands (on separate lines) because of the low ram on (bottom-tier) droplets
echo "Installing some things from NPM for you."
sleep 2
npm i -g forever
npm i -g pm2
npm i -g http-server
npm i -g tinyreq
npm i -g babel-cli
npm i -g babel
npm i -g evilscan
npm i -g bower
npm i -g tape
npm i -g luvi
npm i -g faucet
npm i -g tap
npm i -g trash-cli
npm i -g empty-trash-cli
npm i -g grunt
npm i -g gulp
npm i -g hipper
npm i -g nodemon
npm i -g webpack
npm cache clean
npm cache clean-g



# removing annoying demo project
echo "Removing the demo app."
sleep 2
cd /opt
rm mean


# python
echo "Getting PIP."
sleep 2
curl https://bootstrap.pypa.io/get-pip.py | python3.5


# aliases
echo "Aliasing rm to trash and erm to empty-trash."
sleep 2
cd
echo "alias rm='trash'" >> ~/.bashrc
echo "alias erm='empty-trash'" >> ~/.bashrc


# nginx
echo "Setting up Nginx for you."
sleep 2

cd /etc/nginx/sites-enabled
echo "

server {
    listen 80;
    server_name example.com;
    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

server {
    server_name www.example.com;
    return 301 \$scheme://example.com\$request_uri;
}

server {
    listen 80;
    server_name qwerty.example.com;
    location / {
        proxy_pass http://127.0.0.1:8082;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

server {
    listen 80;
    server_name asdf.example.com;
    location / {
        proxy_pass http://127.0.0.1:8083;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

server {
    listen 80;
    server_name ghjkl.example.com;
    location / {
        proxy_pass http://127.0.0.1:8084;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

" > default


# some parting words
cd
clear
sleep 2
echo "At this point you'll want to clone your projects to this droplet."
echo "Just cd into '/var/www', '/opt', '/srv', or really anywhere you like, and pull them down."
echo "Then, of course, you'll need to run 'npm i' to get their dependencies."
echo "I advise using forever to start your apps instead of nodemon."
echo "Just do something like:"
echo "'nohup forever myscript.js &'"
echo "And then you can use 'forever list' to see what's running."
echo
echo "Please edit the boilerplate at /etc/nginx/sites-enabled/default to suit yourself."
echo "And then just run 'service nginx start' to proxy requests to your apps!"
echo
echo "You may want to use your own dotfiles. Just 'cd', the clone them down into \$HOME."
echo
echo "You're done! Goodbye."

