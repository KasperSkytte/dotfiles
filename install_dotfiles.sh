#!/usr/bin/env bash
# This script installs chezmoi and applies dotfiles
# Currently only for Debian/Ubuntu systems (but it doesn't check for that currently).
set -eu

#vars
req_pkgs="wget curl git gzip unzip"
#prefix applies to the chezmoi install script too
export BINDIR=${BINDIR:-"$HOME/.local/bin"}

#functions
user_can_sudo() {
  command -v sudo >/dev/null 2>&1 || return 1
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

#function to check if executable(s) are available in $PATH
#example usage: checkCommand git curl wget somethirdprogram
checkCommand() {
  argsA=( "$@" )
  local exit=false
  for arg in "${argsA[@]}"
  do
    if ! command -v "$arg" >/dev/null 2>&1
    then
      echo "${arg}: command not found"
      exit=true
    fi
  done

  if $exit
  then
    echo
    echo "Please make sure the above command(s) are installed, \
executable, and available somewhere in the \$PATH variable."
    exit 1
  fi
}

#check for some required system tools first
if command -v dpkg >/dev/null 2>&1
then
  checkCommand $req_pkgs
else
  echo "dpkg not found. Are we on Debian/Ubuntu?"
  exit 1
fi

echo "Checking whether chezmoi is installed..."
if ! command -v chezmoi >/dev/null 2>&1
then
  if grep -q 'Pop!_OS' /etc/os-release
  then
    echo "Looks like we are on Pop!_OS, and polkit doesn't work well with 1password CLI when \"Connect with 1Password CLI\" is enabled in the 1Password app, see https://github.com/twpayne/chezmoi/issues/2687. The current fix is to install chezmoi system-wide, which we'll attempt to do now..."
    if user_can_sudo
    then
      #expecting /usr/local/bin to be in $PATH, not checking for that
      sudo sh -c "$(curl -fsLSk https://github.com/KasperSkytte/chezmoi/raw/master/assets/scripts/install.sh)" -- -b "/usr/local/bin/"
    else
      echo "User can't sudo, aborting..."
      exit 1
    fi
  else
    sh -c "$(curl -fsLSk https://github.com/KasperSkytte/chezmoi/raw/master/assets/scripts/install.sh)"
  fi
fi

echo "(Re)applying dotfiles..."
chezmoi init --apply kasperskytte
