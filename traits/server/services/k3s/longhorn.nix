# Configure a host so that it can run Longhorn for block storage:
# - https://longhorn.io/docs/1.4.2/deploy/install/#installation-requirements
{ config, pkgs, ... }: with pkgs; {
  environment.systemPackages = [
    openiscsi
    nfs-utils
    bash
    curl
    gawk # awk
    gnugrep # grep
    util-linux # blkid findmnt lsblk
  ];

  # The iscsid daemon is required on all the nodes because Longhorn relies on 
  # iscsiadm on the host to provide persistent volumes.
  services.openiscsi = {
    enable = true;
    # name = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
    name = "iqn.2016-04.com.open-iscsi:june";
  };

  # Requires supported filesystems: EXT4 and XFS. I believe that these are already
  # supported, but I could check into how this option works: 
  # https://search.nixos.org/options?channel=unstable&show=boot.supportedFilesystems
  boot.supportedFilesystems = [ "ext4" "xfs" ];

  # Link nix installed binaries to a path expected by longhorn.
  # https://github.com/longhorn/longhorn/issues/2166
  system.activationScripts.linkBinaries.text = ''
    mkdir -p /usr/local
    if [[ ! -h "/usr/local/bin" ]]; then
      ln -s /run/current-system/sw/bin /usr/local
    fi
  '';
}
