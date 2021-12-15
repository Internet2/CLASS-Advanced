#!/bin/bash

# Designed to setup a basic user on a Raspberry PI or cloud systems.
echo "=== setup-user.sh $(hostname) $(date)"

# install packages on deb based systems
if [ -x /usr/bin/apt-get -a -x /usr/bin/sudo ] ; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git python3 ca-certificates procps wget curl unzip jq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y bash-completion rsync
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends emacs-nox aspell-en
fi

# install packages on rpm based systems.
if [ -x /usr/bin/yum ] ; then
    sudo yum install -y git python3 ca-certificates procps wget curl unzip jq
    sudo yum install -y bash-completion rsync
    sudo yum install -y emacs-nox hunspell-en
fi

# directories
install -dv ~/projects
install -dv -m 700 ~/tmp

# ssh keys
install -v -d -m 700 ~/.ssh
if [ ! -r ~/.ssh/authorized_keys ] ; then
    ( umask 0077 ; ssh-add -L > ~/.ssh/authorized_keys )
fi

# bash local configuration
if ! grep -q "^# local configuration" ~/.bashrc ; then
  echo -e "\n# local configuration" >> ~/.bashrc
  echo "shopt -s globstar dotglob" >> ~/.bashrc
  echo "export LESS=-icMR" >> ~/.bashrc
fi

# local configuration
echo -e "(setq make-backup-files nil)\n(menu-bar-mode -1)" > ~/.emacs
echo "PERL_HOMEDIR=0" > ~/.perl-homedir
echo "R_LIBS_USER=~/.local/share/R" > ~/.Renviron

# git
git config --global color.ui auto
git config --global push.default simple
git config --global pull.ff only
if [ -x /usr/bin/emacs ] ; then
    git config --global core.editor 'emacs -nw' # overidden by GIT_EDITOR
fi
