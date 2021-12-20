#!/bin/bash

# Designed to setup a basic user on a Raspberry PI or cloud systems.
echo "=== setup-user.sh $(hostname) $(date)"

# install packages on deb based systems
if [ -x /usr/bin/apt-get -a -x /usr/bin/sudo ] ; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git python3 ca-certificates procps wget curl unzip jq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y vim bash-completion rsync
fi

# install packages on rpm based systems.
if [ -x /usr/bin/yum ] ; then
    sudo yum install -y git python3 ca-certificates procps wget curl unzip jq
    sudo yum install -y vim bash-completion rsync
fi

# directories
install -dv ~/projects
install -dv -m 700 ~/tmp

# bash local configuration
if ! grep -q "^# local configuration" ~/.bashrc ; then
  echo -e "\n# local configuration" >> ~/.bashrc
  echo "shopt -s globstar dotglob" >> ~/.bashrc
  echo "export LESS=-icMR" >> ~/.bashrc
fi

# local configuration
install -dpv ~/.local/share/R
echo "R_LIBS_USER=~/.local/share/R" > ~/.Renviron
echo "PERL_HOMEDIR=0" > ~/.perl-homedir

# git
git config --global color.ui auto
git config --global push.default simple
git config --global pull.ff only
git config --global init.defaultBranch main
