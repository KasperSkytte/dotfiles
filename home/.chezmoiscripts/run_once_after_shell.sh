#!/usr/bin/env bash
set -eu
BINDIR=${BINDIR:-"$HOME/.local/bin"}

#install starship prompt
echo "(Re)installing starship prompt..."
sh -c "$(curl -fsLS https://starship.rs/install.sh)" -- -y --bin-dir "${BINDIR}" 1> /dev/null
#if it fails check https://starship.rs/faq/#how-do-i-run-starship-on-linux-distributions-with-older-versions-of-glibc

#various autocompletions (only for zsh, bash goes to ~/.bash_completion)
#Completions might need to be updated with
#newer versions of things to stay compatible
mkdir -p "$HOME/.oh-my-zsh/completions/"
if [ -s "${HOME}/.oh-my-zsh/completions/_starship" ]
then
  "${BINDIR}"/starship completions zsh > "${HOME}/.oh-my-zsh/completions/_starship"
fi
if [ -s "${HOME}/.oh-my-zsh/completions/_op" ]
then
  op completion zsh > "${HOME}/.oh-my-zsh/completions/_op"
fi
if [ -s "${HOME}/.oh-my-zsh/completions/_chezmoi" ]
then
  chezmoi completion zsh > "${HOME}/.oh-my-zsh/completions/_chezmoi"
fi

default_shell=$(getent passwd "$USER" | awk -F/ '{print $NF}')
if [ ! "$default_shell" == "zsh" ]
then
  echo "The default shell for the current user is not zsh. Manually run 'chsh -s $(command -v zsh)' to set zsh the default shell (if/when installed)."
fi
