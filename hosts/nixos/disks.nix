{ disks ? [ "/dev/sda" ], ... }:
let
  part_boot = "512M";
  part_primary = "100%";
  lv_root = "40G";
  lv_swap = "32G";
  lv_nix = "40G";
  lv_home = "100%FREE";
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "boot";
              start = "0";
              end = part_boot;
              fs-type = "fat32";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "primary";
              start = part_boot;
              end = part_primary;
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            }
          ];
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = lv_root;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
          swap = {
            size = lv_swap;
            content = {
              type = "swap";
              randomEncryption = true;
              resumeDevice = true;
            };
          };
          nix = {
            size = lv_nix;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
              mountOptions = [
                "defaults"
                "noatime"
              ];
            };
          };
          home = {
            size = lv_home;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
            };
          };
        };
      };
    };
  };
}
