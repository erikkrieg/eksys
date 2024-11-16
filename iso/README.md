# ISO

Build custom NixOS installation LiveCD.

Reference: https://nixos.wiki/wiki/Creating_a_NixOS_live_CD

## Minimal

The minimal LiveCD with the inclusion of SSH authorization keys, which can simplify `nixos-anywhere` installs.

### Build

Run the following command from the project root to build the minimal ISO:

```
nix build ./iso#nixosConfigurations.minimal.config.system.build.isoImage
```

The resulting image with be in the `./result/iso` folder.

### Flash ISO to a Drive

This example assumes `/dev/sdc` is a device you wish to override with the ISO. Use the appropriate device, because `dd` will replace existing data at the target output.

```
sudo dd if=result/iso/nixos-*.iso of=/dev/sdc bs=4M status=progress conv=fsync
```
