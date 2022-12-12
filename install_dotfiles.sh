#!/usr/bin/env bash
#this script installs bitwarden and unlocks the vault
#then installs chezmoi and applies the dotfiles

set -eu
bw_url="https://vault.bitwarden.com/download/?app=cli&platform=linux"
arch=$(uname -m)

#prefix applies to the chezmoi install script too
export BINDIR=${BINDIR:-"$HOME/.local/bin"}

echo "Checking whether bw (Bitwarden CLI) is installed..."
if ! command -v bw &> /dev/null
then
  if [ "$arch" == "x86_64" ]
  then
    mkdir -p "${BINDIR}"
    if [ ! -s "${BINDIR}/bw" ]
    then
      echo "bw (Bitwarden CLI) is not installed or available in \$PATH, installing into ${BINDIR}..."
      tmpfile=$(mktemp)
      wget "$bw_url" -O "$tmpfile"
      zcat "$tmpfile" -d > "${BINDIR}/bw"
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

if command -v bw 1> /dev/null
then
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
elif ! command -v bw 1> /dev/null
then
  echo "bw (Bitwarden CLI) is not installed or available in \$PATH"
fi

echo "Installing chezmoi and applying dotfiles..."
sh -c "$(curl -fsLSk https://github.com/KasperSkytte/chezmoi/raw/master/assets/scripts/install.sh)" -- init --apply kasperskytte
