#!/usr/bin/env bash
#when running chezmoi commands, especially apply, unlocking the Bitwarden vault
#doesn't pass on the BW_SESSION var, so it's best done beforehand to avoid
#unlocking it every single time bw is used
# if command -v op >/dev/null 2>&1
# then
#   if [ "$(op account list)" == "" ]
#   then
#     echo "No 1password accounts, please add one (use address: my.1password.com)..."
#     eval $(op account add --signin)
#   elif ! op whoami 2> /dev/null
#   then
#     echo "1password is not signed in, please sign in..."
#     eval $(op signin)
#   fi
# elif ! command -v op >/dev/null 2>&1
# then
#   echo "op (1password CLI) is not installed or available in \$PATH. Please install!"
# fi
