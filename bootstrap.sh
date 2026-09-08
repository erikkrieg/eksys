#!/usr/bin/env bash

set -eo pipefail

HOSTNAME="$(hostname -s)"
TARGET="${1:-$HOSTNAME}"
echo "$TARGET"

echo "Installing Nix..."
if ! command -v nix &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | /bin/bash -s -- install --determinate
  # shellcheck disable=SC1091
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  echo "Nix already installed."
fi

echo "Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found, installing Homebrew."
  homebrew_installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  /bin/bash -c "$homebrew_installer"
else
  echo "Homebrew already installed."
fi

nix --extra-experimental-features "nix-command flakes" \
  build ".#darwinConfigurations.${TARGET}.system"

echo "First install tends to abort with error that includes manual remediation steps"
sudo ./result/sw/bin/darwin-rebuild switch --flake ".#${TARGET}"
