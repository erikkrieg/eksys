#!/usr/bin/env bash

echo "Installing Nix..."
if ! command -v nix &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
else
  echo "Nix already installed."
fi

echo "Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found, installing Homebrew."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Hombrew already installed."
fi

nix --extra-experimental-features "nix-command flakes" \
  build ".#darwinConfigurations.$(hostname -s).system"

echo "First install tends to abort with error that includes manual remediation steps"
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#$(hostname -s)"
