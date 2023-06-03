# Host: June

Lenovo ThinkCentre running NixOs.

## Manual Install

### Partitions

Two partitions created with sda2 being subdivided into volumes with LVM.

```
NAME          MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda             8:0    0 476.9G  0 disk
├─sda1          8:1    0   511M  0 part /boot
└─sda2          8:2    0 476.4G  0 part
  ├─main-nix  254:0    0    40G  0 lvm  /nix/store
  │                                     /nix
  ├─main-root 254:1    0    20G  0 lvm  /
  ├─main-swap 254:2    0  15.5G  0 lvm  [SWAP]
  └─main-home 254:3    0 240.5G  0 lvm  /home
```

### File Systems
EXT4 journal feature has been disabled to reduce I/O operations.
