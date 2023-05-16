# eksys - System and User Configuration
Nix configuration of my system and user spaces for my MacOS dev machines.

## Install

1. Install Nix package manager: https://nixos.org/download.html#nix-install-macos
2. Clone or download the flake source from GitHub.
3. Run `./bootstrap.sh` to build and apply the system configuration.

The bootstrap command builds a derviation and then activates it with nix-darwin. The bootstrap command likely won't succeed on the first run, but if it fails, there should be instructions for manual remediation. Once those are performed, you can re-run `./bootstrap.sh` (there might be a few cycles of this).

## Update

Rebuild and apply: `nixswitch`

This is an alias for building and activating the system configuration flake,
which is effectively the same as:
```sh
darwin-rebuild switch --flake .#
```

To get latest packages, go into the flake source directory and run:
```sh
nix flake update
```
_In order to apply the update, use `nixswitch` after._

To update inputs and apply the change run `nixup`.

To update a specific input (using `envim` as an example): `nix flake lock --update-input envim`

