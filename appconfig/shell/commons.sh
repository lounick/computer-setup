# reload X configuration
xrdb ~/.Xresources

# set keyboard repeat rate
xset r rate 350 55

export TERM=rxvt-unicode-256color

## --------------------------------------------------------------
## |                general aliases and functions               |
## --------------------------------------------------------------

alias :q=exit
alias octave="octave --no-gui $@"
alias indie="export PYTHONHTTPSVERIFY=0; python $GIT_PATH/linux-setup/scripts/indie.py"
alias demangle="c++filt"

# #{ git()

# upgrades the "git pull" to allow dotfiles profiling on linux-setup
# Other "git" features should not be changed
git() {

  case $* in pull*|checkout*|"reset --hard")

    # give me the path to root of the repo we are in
    ROOT_DIR=`git rev-parse --show-toplevel` 2> /dev/null

    if [[ "$?" == "0" ]]; then

      # if we are in the 'linux-setup' repo, use the Profile manager
      if [[ "$ROOT_DIR" == "$GIT_PATH/linux-setup" ]]; then

        PROFILE_MANAGER="$GIT_PATH/linux-setup/submodules/profile_manager/profile_manager.sh"

        bash -c "$PROFILE_MANAGER backup $GIT_PATH/linux-setup/appconfig/profile_manager/file_list.txt"

        command git "$@"

        if [[ "$?" == "0" ]]; then
          case $* in pull*|checkout*) # TODO: should only work for checkout of a branch
            echo "Syncing git submodules"
            command git submodule sync
            echo "Updating git submodules"
            command git submodule update --init --recursive

            if [ -e .gitman.yml ]; then
              if [[ ! $(git status .gitman.yml --porcelain) ]]; then # if .gitman.yml is unchanged
                echo "Updating gitman sub-repos"
                gitman install
              else
                echo -e "\e[31m.gitman.yml modified, not updating sub-repos\e[0m"
              fi
            fi
          esac
        fi

        if [[ "$?" == "0" ]]; then
          bash -c "$PROFILE_MANAGER deploy $GIT_PATH/linux-setup/appconfig/profile_manager/file_list.txt"
        fi

      else

        command git "$@"

        if [[ "$?" == "0" ]]; then
          case $* in pull*|checkout*) # TODO: should only work for checkout of a branch
            echo "Syncing git submodules"
            command git submodule sync
            echo "Updating git submodules"
            command git submodule update --init --recursive

            if [ -e .gitman.yml ]; then
              if [[ ! $(git status .gitman.yml --porcelain) ]]; then # if .gitman.yml is unchanged
                echo "Updating gitman sub-repos"
                gitman install
              else
                echo -e "\e[31m.gitman.yml modified, not updating sub-repos\e[0m"
              fi
            fi
          esac
        fi

      fi

    else

      command git "$@"

      if [[ "$?" == "0" ]]; then
        case $* in pull*|checkout*) # TODO: should only work for checkout of a branch
          echo "Syncing git submodules"
          command git submodule sync
          echo "Updating git submodules"
          command git submodule update --init --recursive

          if [ -e .gitman.yml ]; then
            if [[ ! $(git status .gitman.yml --porcelain) ]]; then # if .gitman.yml is unchanged
              echo "Updating gitman sub-repos"
              gitman install
            else
              echo -e "\e[31m.gitman.yml modified, not updating sub-repos\e[0m"
            fi
          fi
        esac
      fi
    fi
    ;;
  *)
    command git "$@"
    ;;

  esac
}

# #}

# #{ ranger()

ranger () {
  command ranger --choosedir="/tmp/lastrangerdir"
  LASTDIR=`cat "/tmp/lastrangerdir"`
  cd "$LASTDIR"
}

# #}
alias ra=ranger

# #{ killp()

# allows killing process with all its children
killp() {

  if [ $# -eq 0 ]; then
    echo "The command killp() needs an argument, but none was provided!"
    return
  else
    pes=$1
  fi

  for child in $(ps -o pid,ppid -ax | \
    awk "{ if ( \$2 == $pes ) { print \$1 }}")
    do
      # echo "Killing child process $child because ppid = $pes"
      killp $child
    done

# echo "killing $1"
kill -9 "$1" > /dev/null 2> /dev/null
}

# #}

# #{ getVideoThumbnail()

getVideoThumbnail() {

  if [ $# -eq 0 ]; then
    echo "did not get input"
    exit 1
  elif [ $# -eq 1 ]; then
    echo "gettin the first frame"
    file="$1"
    frame="00:00:01"
  elif [ $# -eq 2 ]; then
    file="$1"
    frame="$2"
  fi

  output="${file%.*}_thumbnail.jpg"
  ffmpeg -i "$file" -ss "$frame" -vframes 1 "$output"
}

# #}

# #{ sourceShellDotfile()

getRcFile() {

  case "$SHELL" in
    *bash*)
      RCFILE="$HOME/.bashrc"
      ;;
    *zsh*)
      RCFILE="$HOME/.zshrc"
      ;;
  esac

  echo "$RCFILE"
}

sourceShellDotfile() {

  RCFILE=$( getRcFile )

  source "$RCFILE"
}

# #}
alias sb="sourceShellDotfile"

# #{ slack()

slack() {

  SLACK_BIN=`which slack-term`

  if [ -z $1 ]
  then
    SLACK_NAME=$(echo "mrs
    eagle" | rofi -i -dmenu -no-custom -p "Select slack")
  else
    SLACK_NAME=${1}
  fi

  mkdir -p ~/git/notes/slack

  case ${SLACK_NAME} in
    mrs)
      SLACK_CFG=~/git/notes/slack/mrsworkspace
      ;;
    eagle)
      SLACK_CFG=~/git/notes/slack/drone-eagleone
      ;;
  esac

  $SLACK_BIN -config $SLACK_CFG
}

# #}

## --------------------------------------------------------------
## |                         git aliases                        |
## --------------------------------------------------------------

# #{ gitPullPush()

gitPullPush() {

  branch=`git branch | grep \* | sed 's/\* \([a-Z]*\)/\1/'`

  if [ $# -eq 0 ]; then
    git pull origin "$branch"
    git push origin "$branch"
  else
    git pull "$1" "$branch"
    git push "$1" "$branch"
  fi
}

# #}
alias gppl="gitPullPush local"
alias gppo="gitPullPush origin"

# #{ gitSubmoduleRecursive()

gitSubmoduleRecursive() {

  command git submodule foreach git "$@"
}

# #}
alias gr="gitSubmoduleRecursive"

alias gs="git status"
alias gcmp="git checkout master; git pull"
alias flog="~/.scripts/git-forest.sh --all --date=relative --abbrev-commit --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --style=15"
alias glog="git log --graph --abbrev-commit --date=relative --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"

## --------------------------------------------------------------
## |                        tmux aliases                        |
## --------------------------------------------------------------

# #{ forceKillTmuxSession()

forceKillTmuxSession() {

  num=`$TMUX_BIN ls 2> /dev/null | grep "$1" | wc -l`
  if [ "$num" -gt "0" ]; then

    pids=`tmux list-panes -s -t "$1" -F "#{pane_pid} #{pane_current_command}" | grep -v tmux | awk '{print $1}'`

    for pid in "$pids"; do
      killp "$pid"
    done

    $TMUX_BIN kill-session -t "$1"

  fi
}

# #}

# #{ quitTmuxSession()

quitTmuxSession() {

  if [ ! -z "$TMUX" ]; then

    echo "killing session"
    pids=`tmux list-panes -s -F "#{pane_pid} #{pane_current_command}" | grep -v tmux | awk {'print $1'}`

    for pid in $pids; do
      killp "$pid" &
    done

    SESSION_NAME=`tmux display-message -p '#S'`
    tmux kill-session -t "$SESSION_NAME"

  else

    exit

  fi
}

# #}
alias :qa="quitTmuxSession"

# #{ catkin()

catkin() {

  case $* in

    init*)

      # give me the path to root of the repo we are in
      ROOT_DIR=`git rev-parse --show-toplevel` 2> /dev/null

      command catkin "$@"
      command catkin config --profile debug --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-std=c++17 -march=native'  -DCMAKE_C_FLAGS='-march=native'
      command catkin config --profile release --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-std=c++17 -march=native'  -DCMAKE_C_FLAGS='-march=native'
      command catkin config --profile reldeb --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-std=c++17 -march=native' -DCMAKE_C_FLAGS='-march=native'

      command catkin profile set reldeb
      ;;

    build*|b|bt)

      PACKAGES=$(catkin list)
      if [ -z "$PACKAGES" ]; then
        echo "Cannot compile, not in a workspace"
      else


        command catkin "$@"


      fi

      ;;

    *)
      command catkin $@
      ;;

    esac
  }

# #}
alias cb="catkin build"
