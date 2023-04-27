# eksys - System and User Configuration
Nix configuration of my system and user spaces for my MacOS dev machines.

## Install

1. Install Nix package manager: https://nixos.org/download.html#nix-install-macos
2. Clone or download the flake source from GitHub.
3. Run `./bootstrap.sh` to build and apply the system configuration.

The bootstrap command builds a derviation and then activates it with nix-darwin. The bootstrap command likely won't succeed on the first run, but if it fails, there should be instructions for manual remediation. Once those are performed, you can re-run `./bootstrap.sh` (there might be a few cycles of this).

## Update
Update path according to the location of the system flake:
```sh
darwin-rebuild switch --flake .#
```

Alternatively, you can use the alias `nixswitch`. 

To update packages and the `flake.lock` file, run:
```sh
nix flake update && nixswitch
```
