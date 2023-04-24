#!/usr/bin/env bash
# This script installs 1password CLI and unlocks the vault
# Currently only for Debian/Ubuntu systems (but it doesn't check for that currently).
set -eu

#vars
arch="$(uname -m)"
if [ "$arch" == "x86_64" ]
then
  arch="amd64"
fi
op_version="v2.17.0-beta.01"
op_url="https://cache.agilebits.com/dist/1P/op2/pkg/${op_version}/op_linux_${arch}_${op_version}.zip"
req_pkgs="wget curl git gzip unzip"
#prefix applies to the chezmoi install script too
export BINDIR=${BINDIR:-"$HOME/.local/bin"}
if ! echo "$PATH" | grep -Eq "(^|:)${BINDIR}($|:)"
then
  export PATH="${BINDIR}:${PATH}"
fi

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

echo "Checking whether op (1password CLI) is installed..."
if ! command -v op >/dev/null 2>&1
then
  if [ "$arch" == "amd64" ]
  then
    mkdir -p "${BINDIR}"
    if [ ! -s "${BINDIR}/op" ]
    then
      echo "op (1password CLI) is not installed or available in \$PATH, installing version ${op_version} into ${BINDIR}..."
      tmpfile=$(mktemp)
      wget -q "$op_url" -O "$tmpfile"
      unzip -o "$tmpfile" op -d "${BINDIR}"
      #gpg --receive-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22
      #unzip -o -p "$tmpfile" op.sig | gpg --verify - "${BINDIR}/op"
      rm -f "$tmpfile"
      chmod +x "${BINDIR}/op"
    fi
  else
    echo "Can't install op (1password CLI). Unsupported architecture \"${arch}\", only x86_64 (amd64) is supported at the moment."
    exit 1
  fi
fi
