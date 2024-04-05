{ pkgs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "june";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.autoSuspend = false;
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  nix.extraOptions = ''experimental-features = nix-command flakes'';

  fileSystems = {
    "/nix".options = [ "defaults" "noatime" ];
  };

  users.users.ek = {
    isNormalUser = true;
    description = "Erik Krieg";
    extraGroups = [ "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjh1wU4Pqef3+Buo/nFgsdQlbLaRAiz7L6tX+n3fJ74 ek@eksys"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBsRWOV6NTXPK6DSDM2gAxt2clCfDNxU9683nnxpodqc erik.krieg@eksys_pro"
    ];
    packages = with pkgs; [
      firefox
    ];
    shell = pkgs.zsh;
  };

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

  services.k3s = {
    clusterInit = lib.mkForce false;
    # serverAddr = "https://chips.eksys.dev:6443";
    serverAddr = "https://192.168.1.17:6443";
    tokenFile = /var/lib/rancher/k3s/server/token;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
