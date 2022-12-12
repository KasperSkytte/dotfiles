#!/usr/bin/env bash
set -eu
bw_url="https://vault.bitwarden.com/download/?app=cli&platform=linux"
arch=$(uname -m)

if ! command -v bw &> /dev/null
then
  if [ "$arch" == "x86_64" ]
  then
    mkdir -p "${HOME}/.local/bin"
    if [ ! -s "${HOME}/.local/bin/bw" ]
    then
      tmpfile=$(mktemp)
      wget "$bw_url" -O "$tmpfile"
      zcat "$tmpfile" -d > "${HOME}/.local/bin/bw"
      rm -f "$tmpfile"
      chmod +x "${HOME}/.local/bin/bw"
    fi
  else
    echo "Unsupported architecture \"${arch}\". Only x86_64 is supported."
  fi
fi
