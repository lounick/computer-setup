#!/bin/bash

# get the path to this script
MY_PATH=`dirname "$0"`
MY_PATH=`( cd "$MY_PATH" && pwd )`

# define paths
APPCONFIG_PATH=$MY_PATH/appconfig

cd $MY_PATH
git pull
git submodule update --init --recursive

# install packages
sudo apt update

subinstall_params=""
unattended=0
for param in "$@"
do
  echo $param
  if [ $param="--unattended" ]; then
    echo "installing in unattended mode"
    unattended=1
    subinstall_params="--unattended"
  fi
done

autoyes = ""
if [ "$unattended" == "1" ] then
  autoyes = "-y"
fi

sudo apt $autoyes install cmake cmake-curses-gui ruby sl htop \
			  indicator-multiload figlet toilet gem ruby \
                          build-essential tree exuberant-ctags libtool automake \
                          autoconf autogen libncurses5-dev python2.7-dev \
                          python3-dev libc++-dev openssh-server xclip xsel \
                          python-git vlc pkg-config python-setuptools \
                          python3-setuptools ffmpeg sketch shutter \
                          silversearcher-ag exfat-fuse exfat-utils python3-pip \
                          gimp autossh jq dvipng xvfb gparted net-tools espeak

if [ "$unattended" == "0" ]
then
  if [ "$?" != "0" ]; then echo "Press Enter to continue.."; read; fi
fi

# download, compile and install tmux
bash $APPCONFIG_PATH/tmux/install.sh $subinstall_params

# compile and install tmuxinator
bash $APPCONFIG_PATH/tmuxinator/install.sh $subinstall_params

# copy vim settings
bash $APPCONFIG_PATH/vim/install.sh $subinstall_params

# install neovim
bash $APPCONFIG_PATH/nvim/install.sh $subinstall_params

# install urxvt
bash $APPCONFIG_PATH/urxvt/install.sh $subinstall_params
