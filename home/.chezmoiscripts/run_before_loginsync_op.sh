#!/usr/bin/env bash
#unlocks op before chezmoi apply
#may need to check for this: https://developer.1password.com/docs/cli/app-integration#turn-on-the-app-integration-and-sign-in-to-your-account
if command -v op >/dev/null 2>&1
then
  # if getent group onepassword-cli
  # then
  #   sudo chgrp onepassword-cli "${BINDIR}/op"
  #   chmod g+s "${BINDIR}/op"
  # fi
  op update
  if [ "$(op account list)" == "" ]
  then
    echo "No 1password accounts, please add one (using address: my.1password.com)..."
    eval $(op account add --address my.1password.com --signin)
  elif ! op whoami >/dev/null 2>&1
  then
    echo "1password is not signed in, please sign in..."
    eval $(op signin)
  fi
elif ! command -v op >/dev/null 2>&1
then
  echo "op (1password CLI) is not installed or available in \$PATH"
fi
