#!/usr/bin/env bash

set -eo pipefail

if [ "$(uname -s)" != Darwin ]; then
  echo "bootstrap.sh installs macOS prerequisites; use just rebuild-target for an existing Linux Nix installation." >&2
  exit 1
fi

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
[ "$#" -le 1 ] || { echo "Usage: $0 [TARGET]" >&2; exit 1; }

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

echo "First install tends to abort with error that includes manual remediation steps"
exec bash "$REPO/scripts/nix.sh" rebuild "${1:-}"
