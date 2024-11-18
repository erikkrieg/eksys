{ config, pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    # Basic utilities
    git
    curl
    wget

    # Disk utilities
    gparted
    parted
    ntfs3g

    # System recovery tools
    testdisk
    ddrescue

    # Networking tools
    inetutils
    nettools

    # Hardware inspection
    pciutils
    usbutils
    lshw

    # Text editors
    neovim

    # File system tools
    dosfstools
    e2fsprogs
  ];

  # SSH configuration
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes"; # For recovery purposes
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjh1wU4Pqef3+Buo/nFgsdQlbLaRAiz7L6tX+n3fJ74 ek@eksys"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxcsEfj6Tnq8qJt3WFLYM4EwBYWwL953mr458vNVqDn1W ek@june"
  ];

  boot.supportedFilesystems = [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
}
