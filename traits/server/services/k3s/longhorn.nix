# Configure a host so that it can run Longhorn for block storage:
# - https://longhorn.io/docs/1.4.2/deploy/install/#installation-requirements
{ pkgs, ... }: with pkgs; {
  environment.systemPackages = [
    openiscsi
    bash
    curl
    gawk # awk
    gnugrep # grep
    util-linux # blkid findmnt lsblk
  ];

  # Not sure but might need to enable NFS client. Check if it is on the kernel by running:
  # `cat /boot/config-`uname -r`| grep CONFIG_NFS_V4_1`
  # For more info:
  # https://longhorn.io/docs/1.4.2/deploy/install/#installing-nfsv4-client
  #
  # services.nfs.server.enable = true;

  # Requires supported filesystems: EXT4 and XFS. I believe that these are already
  # supported, but I could check into how this option works: 
  # https://search.nixos.org/options?channel=unstable&show=boot.supportedFilesystems
  boot.supportedFilesystems = [ "ext4" "xfs" ];

  # Link nix installed binaries to a path expected by longhorn.
  # https://github.com/longhorn/longhorn/issues/2166
  system.activationScripts.text = ''
    if [[ ! -h "/usr/local/bin" ]]; then
      ln -s "/usr/local/bin" "/run/current-system/sw/bin"
    fi
  '';
}