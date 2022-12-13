#!/usr/bin/env bash
set -eu
set -o pipefail
if command -v gnome-terminal &> /dev/null
then
  if command -v gsettings &> /dev/null
  then
    echo "Adjusting GNOME Terminal settings"
    GNOME_TERMINAL_PROFILE="$(gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}')"
    gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${GNOME_TERMINAL_PROFILE}/" font 'MesloLGS NF 12'
    if command -v zsh &> /dev/null
    then
      gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${GNOME_TERMINAL_PROFILE}/" use-custom-command true
      gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${GNOME_TERMINAL_PROFILE}/" custom-command '/usr/bin/zsh'
    fi
  fi
fi
