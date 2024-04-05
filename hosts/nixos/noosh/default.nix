{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking = {
    hostName = "noosh"; # Name courtesy of a 2 year old.
    networkmanager.enable = true;

    # Below are attempts to wake host but I wasn't able to get it working yet. 
    networkmanager = {
      connectionConfig = {
        "802-3-ethernet.wake-on-lan" = "magic";
        "ethernet.wake-on-lan" = "magic";
      };
      extraConfig = ''
        [connection]
        ethernet.wake-on-lan = magic
      '';
    };
    interfaces.eno1.wakeOnLan.enable = true;
  };

  # Enable secure shell access
  services.openssh.enable = true;

  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  services.xserver = {
    enable = true;
    layout = "us"; # Keyboard
    xkbVariant = "";

    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.autoSuspend = false; # Trying not to break SSH connections
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.ek = {
    isNormalUser = true;
    description = "Erik Krieg";
    extraGroups = [ "networkmanager" "wheel" ];
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
    vim
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
