#!/usr/bin/env bash

nix --extra-experimental-features "nix-command flakes" \
  build .#darwinConfigurations.Eriks-MacBook-Pro.system

echo "First install tends to abort with error that includes manual remediation steps"
./result/sw/bin/darwin-rebuild switch --flake .

