{ pkgs, ... }: {
  imports = [
    # ./hardware-configuration.nix
    (import ../disks.nix { disks = [ "/dev/sda" ]; })
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "chips";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  nix.extraOptions = ''experimental-features = nix-command flakes'';

  users.users.ek = {
    isNormalUser = true;
    description = "Erik Krieg";
    extraGroups = [ "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjh1wU4Pqef3+Buo/nFgsdQlbLaRAiz7L6tX+n3fJ74 ek@eksys"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBsRWOV6NTXPK6DSDM2gAxt2clCfDNxU9683nnxpodqc erik.krieg@eksys_pro"
    ];
    shell = pkgs.zsh;
  };

  # June is managing other nixos hosts
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxcsEfj6Tnq8qJt3WFLYM4EwBYWwL4mr458vNVqDn1W ek@june"
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
