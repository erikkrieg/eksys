# ISO

Build custom NixOS installation LiveCD.

Reference: https://nixos.wiki/wiki/Creating_a_NixOS_live_CD

## Minimal

The minimal LiveCD with the inclusion of SSH authorization keys, which can simplify `nixos-anywhere` installs.

### Build

```
nix build .#nixosConfigurations.minimal.config.system.build.isoImage
```
