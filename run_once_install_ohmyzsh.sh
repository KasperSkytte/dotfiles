#!/usr/bin/env bash
set -eu
if command -v zsh >/dev/null 2>&1
then
  if [ ! -d "${HOME}/.oh-my-zsh" ]
  then
    export KEEP_ZSHRC="yes"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  default_shell=$(getent passwd "$USER" | awk -F/ '{print $NF}')
  if [ ! "$default_shell" == "zsh" ]
  then
    echo "The default shell for the current user is not zsh. Manually run 'chsh -s $(command -v zsh)' to set zsh the default shell."
  fi
else
  echo "zsh is not installed, not installing oh-my-zsh..."
fi
