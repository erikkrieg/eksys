#!/usr/bin/env bash

echo "Checking for Homebrew..."
if ! command -v homebrew &> /dev/null; then
  echo "Homebrew not found, installing Homebrew."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Hombrew already installed."
fi

nix --extra-experimental-features "nix-command flakes" \
  build ".#darwinConfigurations.$(hostname -s).system"

echo "First install tends to abort with error that includes manual remediation steps"
./result/sw/bin/darwin-rebuild switch --flake .

