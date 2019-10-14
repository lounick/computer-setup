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

# setup latex
bash $APPCONFIG_PATH/latex/install.sh $subinstall_params

# setup pdftk
bash $APPCONFIG_PATH/pdftk/install.sh $subinstall_params

# setup pandoc
bash $APPCONFIG_PATH/pandoc/install.sh $subinstall_params

# setup ranger
bash $APPCONFIG_PATH/ranger/install.sh $subinstall_params

# install the silver searcher
bash $APPCONFIG_PATH/silver_searcher/install.sh $subinstall_params

# install playerctl
bash $APPCONFIG_PATH/playerctl/install.sh $subinstall_params

#############################################
# remove the interactivity check from bashrc
#############################################

if [ -x "$(whereis nvim | awk '{print $2}')" ]; then
  VIM_BIN="$(whereis nvim | awk '{print $2}')"
  HEADLESS="--headless"
elif [ -x "$(whereis vim | awk '{print $2}')" ]; then
  VIM_BIN="$(whereis vim | awk '{print $2}')"
  HEADLESS=""
fi

$VIM_BIN $HEADLESS -E -s -c "%g/running interactively/norm dap" -c "wqa" -- ~/.bashrc

#############################################
# adding GIT_PATH variable to .bashrc
#############################################

# add variable for path to the git repository
num=`cat ~/.bashrc | grep "GIT_PATH" | wc -l`
if [ "$num" -lt "1" ]; then

  TEMP=`( cd "$MY_PATH/../" && pwd )`

  echo "Adding GIT_PATH variable to .bashrc"
  # set bashrc
  echo "
# path to the git root
export GIT_PATH=$TEMP" >> ~/.bashrc
fi

#############################################
# add tmux sourcing of dotbashrd to .bashrc
#############################################

num=`cat ~/.bashrc | grep "RUN_TMUX" | wc -l`
if [ "$num" -lt "1" ]; then

  default=y
  while true; do
    if [[ "$unattended" == "1" ]]
    then
      resp=$default
    else
      [[ -t 0 ]] && { read -t 10 -n 2 -p $'\e[1;32mDo you want to run TMUX automatically with every terminal? [y/n] (default: '"$default"$')\e[0m\n' resp || resp=$default ; }
    fi
    response=`echo $resp | sed -r 's/(.*)$/\1=/'`

    if [[ $response =~ ^(y|Y)=$ ]]
    then

      echo "
# want to run tmux automatically with new terminal?
export RUN_TMUX=true" >> ~/.bashrc

      echo "Setting variable RUN_TMUX to true"

      break
    elif [[ $response =~ ^(n|N)=$ ]]
    then

      echo "
# want to run tmux automatically with new terminal?
export RUN_TMUX=false" >> ~/.bashrc

      echo "Setting variable RUN_TMUX to false"

      break
    else
      echo " What? \"$resp\" is not a correct answer. Try y+Enter."
    fi
  done
fi

#############################################
# link the scripts folder
#############################################

if [ ! -e ~/.scripts ]; then
  ln -sf $MY_PATH/scripts ~/.scripts
fi

#############################################
# add sourcing of dotbashrd to .bashrc
#############################################
num=`cat ~/.bashrc | grep "dotbashrc" | wc -l`
if [ "$num" -lt "1" ]; then

  echo "Adding source to .bashrc"
  # set bashrc
  echo "
# source Tomas's Linux Setup
source $APPCONFIG_PATH/bash/dotbashrc" >> ~/.bashrc

fi

# finally source the correct rc file
toilet All Done

# say some tips to the new user
echo "Huray, the 'Linux Setup' should be ready, try opening new terminal."
