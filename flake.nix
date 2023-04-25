{
  description = "Manage system and user space";
  inputs = {
    # Use package repository with the latest versions. Can include breaking changes.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Configure software in home directory.
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Configure system level software and settings.
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Instead of `inputs:` I often see things like `{self, nixpkgs, darwin}`.
  # Need to learn a bit more about the difference then pick a convention.
  output = inputs: {
    darwinConfiguration.eksys = inputs.darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import inputs.nixpkgs { system = "aarch64-darwin"; };
    };
    # Input to darwin system where we input all our parameters.
    # Darwin preferences and configuration go here.
    modules = [
      # Not sure that `with pkgs;` will work.
      ({ pkgs, ... }: with pkgs; {
        # Configure shells
        programs.zsh.enable = true;
        environment.shells = [ dash bash zsh ];
        environment.loginShell = zsh;

        # Configure nix
        # Essentially contents of ~/.config/nix/nix.conf
        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';
        services.nix-daemon.enable = true; # Allow nix-darwin to manages/updates the daemon

        # Install system packages
        systemPackages = [ coreutils ];

        # Configure keyboard
        system.keyboard.enableKeyMapping = true;
        system.keyboard.remapCapsLockToEscape = true;

        # Configure fonts
        fonts.fontsDir.enable = false; # Danger: `true` mean fonts can get removed.
        fonts.fonts = [ (nerdfonts.override { fonts = ["Meslo"]; }) ];

        # Configure Finder 
        system.defaults.finder.AppleShowAllExtensions = true;
        system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
      })
    ];
  };
}
