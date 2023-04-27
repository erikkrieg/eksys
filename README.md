# eksys - System and User Configuration
Nix configuration of my system and user spaces for my MacOS dev machines.

## Install

1. Install Nix package manager: https://nixos.org/download.html#nix-install-macos
2. Clone or download the flake source from GitHub.
3. Run `./bootstrap.sh` to build and apply the system configuration.

The bootstrap command builds a derviation and then activates it with nix-darwin. The bootstrap command likely won't succeed on the first run, but if it fails, there should be instructions for manual remediation. Once those are performed, you can re-run `./bootstrap.sh` (there might be a few cycles of this).

I was having issues with the `SHELL` environment variable and ended up performing
some [manual interventions](https://github.com/erikkrieg/.dotfiles/blob/31cfd983ae55ee00a11cba23d431319736a62fbe/install.sh#L66-L70).

```sh
# Set zsh as the default shell
ZSH="$(which zsh)"
if [ "${SHELL}" != "${ZSH}" ]; then
  command -v zsh | sudo tee -a /etc/shell   # Use zsh as login shell
  sudo chsh -s "${ZSH}" "${USER}"           # Use zsh (installed by nix) as default shell
fi
```

This problem manifested in two ways, depending on the terminal emulator I was using:
- Alacritty: `echo $SHELL # /zsh`, which caused errors because there was no zsh binary at that path
- Terminal (MacOS default): `echo $SHELL # /bin/zsh`, which means the default MacOS zsh package was used

I was surprised by this, expecting nix-darwin to setup `zsh` completely. While it is certainly
possible that created an odd state in my system previously, my expectation was that
nix-darwin would modify the `/etc` files or at least warn me that they were out of sync.

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
