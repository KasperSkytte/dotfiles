#!/usr/bin/env bash
#when running chezmoi commands, especially apply, unlocking the Bitwarden vault
#doesn't pass on the BW_SESSION var, so it's best done beforehand to avoid
#unlocking it every single time bw is used
if command -v bw >/dev/null 2>&1
then
  bw_status="$(bw status 2> /dev/null | grep -io '\"status\":.*[^}]')"
  if echo "$bw_status" | grep -q '\"unauthenticated\"'
  then
    echo "Not authenticated with Bitwarden. Run bw-login before using chezmoi. Exiting..."
    exit 1
  elif echo "$bw_status" | grep -q '\"locked\"'
  then
    echo "Bitwarden vault is locked. Run bw-unlock before using chezmoi. Exiting..."
    exit 1
  elif echo "$bw_status" | grep -q '\"unlocked\"'
  then
    echo "Bitwarden vault is unlocked. Syncing vault..."
    bw sync
  fi
elif ! command -v bw >/dev/null 2>&1
then
  echo "bw (Bitwarden CLI) is not installed or available in \$PATH. Please install."
  exit 1
fi
