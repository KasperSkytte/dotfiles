#!/usr/bin/env bash
# This script installs bitwarden and unlocks the vault
# then installs chezmoi and applies the dotfiles.
# Currently only for Debian/Ubuntu systems (but it doesn't check for that currently).
set -eu

#vars
bw_url="https://github.com/bitwarden/clients/releases/download/cli-v2022.11.0/bw-linux-2022.11.0.zip"
arch=$(uname -m)
req_pkgs="wget curl git gzip unzip"

#functions
user_can_sudo() {
  command -v sudo >/dev/null 2>&1 || return 1
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

#function to check if executable(s) are available in $PATH
#example usage: checkCommand minimap2 parallel somethirdprogram
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

#prefix applies to the chezmoi install script too
export BINDIR=${BINDIR:-"$HOME/.local/bin"}

echo "Checking whether bw (Bitwarden CLI) is installed..."
if ! command -v bw >/dev/null 2>&1
then
  if [ "$arch" == "x86_64" ]
  then
    mkdir -p "${BINDIR}"
    if [ ! -s "${BINDIR}/bw" ]
    then
      echo "bw (Bitwarden CLI) is not installed or available in \$PATH, installing into ${BINDIR}..."
      bwdatapath="${HOME}/.config/Bitwarden CLI/data.json"
      if [ -s "${bwdatapath}" ]
      then
        echo "${bwdatapath} already exists. Installing Bitwarden CLI using the configuration from a previous installation is asking for trouble. Please resolve manually. Exiting..."
        exit 1
      fi
      tmpfile=$(mktemp)
      wget "$bw_url" -q -O "$tmpfile"
      unzip "$tmpfile" bw -d "${BINDIR}"
      rm -f "$tmpfile"
      chmod +x "${BINDIR}/bw"
    fi
    if ! echo "$PATH" | grep -Eq "(^|:)${BINDIR}($|:)"
    then
      export PATH="${BINDIR}:${PATH}"
    fi
  else
    echo "Can't install bw (Bitwarden CLI). Unsupported architecture \"${arch}\", only x86_64 is supported."
    exit 1
  fi
fi

if command -v bw >/dev/null 2>&1
then
  bw update
  bw_status="$(bw status 2> /dev/null | grep -io '\"status\":.*[^}]')"
  if echo "$bw_status" | grep -q '\"unauthenticated\"'
  then
    echo "Not authenticated with Bitwarden..."
    export BW_SESSION=$(bw login --raw)
  elif echo "$bw_status" | grep -q '\"locked\"'
  then
    echo "Bitwarden vault is locked..."
    export BW_SESSION=$(bw unlock --raw)
  fi
elif ! command -v bw >/dev/null 2>&1
then
  echo "bw (Bitwarden CLI) is not installed or available in \$PATH"
fi

echo "Installing chezmoi and applying dotfiles..."
sh -c "$(curl -fsLSk https://github.com/KasperSkytte/chezmoi/raw/master/assets/scripts/install.sh)" -- init --apply kasperskytte
