# eksys - System and User Configuration
Nix configuration of my system and user spaces for my MacOS dev machines.

## Install

Bootstrap by running command to build derviation and then activate with
nix-darwin.
```sh
./bootstrap.sh
```

## Update
Update path according to the location of the system flake:
```sh
darwin-rebuild switch --flake .#
```
