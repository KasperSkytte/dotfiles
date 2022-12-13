#!/usr/bin/env bash
set -eu
BINDIR=${BINDIR:-"$HOME/.local/bin"}

#install starship prompt
echo "(Re)installing starship prompt..."
sh -c "$(curl -fsLS https://starship.rs/install.sh)" -- -y --bin-dir "${BINDIR}" 1> /dev/null
#if it fails check https://starship.rs/faq/#how-do-i-run-starship-on-linux-distributions-with-older-versions-of-glibc

if [ ! -d "${HOME}/.oh-my-zsh" ]
then
  echo "Installing oh-my-zsh alongside plugins and themes..."
  export KEEP_ZSHRC="yes"
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone \
    --depth=1 \
    https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  git clone \
    --depth 1 \
    https://github.com/zsh-users/zsh-autosuggestions \
    "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

#the ohmyzsh install script might not succeed in setting the default shell
default_shell=$(getent passwd "$USER" | awk -F/ '{print $NF}')
if [ ! "$default_shell" == "zsh" ]
then
  echo "The default shell for the current user is not zsh. Manually run 'chsh -s $(command -v zsh)' to set zsh the default shell."
fi

#various autocompletions (only for zsh, bash goes to ~/.bash_completion)
#assumes oh-my-zsh is installed. Completions might need to be updated with
#newer versions of things to stay compatible
mkdir -p "$HOME/.oh-my-zsh/completions/"
if [ -s "${HOME}/.oh-my-zsh/completions/_starship" ]
then
  "${BINDIR}"/starship completions zsh > "${HOME}/.oh-my-zsh/completions/_starship"
fi
if [ -s "${HOME}/.oh-my-zsh/completions/_bw" ]
then
  bw completion --shell zsh > "${HOME}/.oh-my-zsh/completions/_bw"
fi
