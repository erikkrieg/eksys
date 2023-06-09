# NixOS Hosts

## Installing NixOS to a new host

Replace some steps described in the [NixOS install manual](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual) with the following alternatives:

- [Partitioning and formatting with Disko](#partitioning-and-formatting-with-disko)
- [Generate NixOS config](#generate-nixos-config)

These steps simplify configuring disk(s) and allow for a declarative approach instead of imperative terminal commands for creating partitions, logical volumes and file systems.

### Partitioning and formatting with Disko

Instead of using `parted`, like described [in the manual](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual-partitioning), use [disko](https://github.com/nix-community/disko) for creating partitions.

Using disko configuration:

```sh
cd /tmp
curl https://raw.githubusercontent.com/erikkrieg/eksys/main/hosts/nixos/disks.nix -o disks.nix
sudo nix run github:nix-community/disko -- --mode disko disks.nix --arg disks '[ "/dev/sda" ]'
```

Verify file system was formatted and mounted properly:

```sh
mount | grep /mnt
```

Verify logical volumes were created:

```sh
lvdisplay
```

### Generate NixOS config

Creating the file systems with Disko changes how the NixOS configurations are generated. [Read Disko guide for more details](https://github.com/nix-community/disko/blob/master/docs/quickstart.md#step-6-complete-the--nixos-installation).

```sh
nixos-generate-config --no-filesystems --root /mnt
mv /tmp/disks.nix /mnt/etc/nixos
```

Import `disks.nix` into `/mnt/etc/nixos/configurations.nix` like so:

```nix
imports =
 [ # Include the results of the hardware scan.
   ./hardware-configuration.nix
   "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
 ];
 disko.devices = pkgs.callPackage ./disks.nix {
   disks = [ "/dev/<disk-name>" ]; # replace this with your disk name i.e. /dev/nvme0n1
 };
```

### Complete install

```sh
nixos-install
reboot
```

## Remote NixOS installs

Simplify the manual install by doing it remotely with [nixos-anywhere](https://github.com/numtide/nixos-anywhere).

1. Boot from LiveCD
2. Change to root: `sudo -i`
3. Set `passwd` for root user (required for SSH)
4. Perform the following steps from an existing Intel NixOS host

Then install nixos over SSH with nixos-anywhere:

```sh
nix run github:numtide/nixos-anywhere -- \
  root@x.x.x.x \
  --flake .#new_host \
  --debug
```

Update `new_host` output to use `mkHost` and use desired traits. Once configs are changed, changes can be applied from build machine like so:

```sh
nixos-rebuild switch --flake .#new_host --target-host root@x.x.x.x
```
