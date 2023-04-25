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
  outputs = inputs: {
    darwinConfigurations.eksys = inputs.darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import inputs.nixpkgs { system = "aarch64-darwin"; };
      modules = [
        # Configure Darwin system space.
        # https://daiderd.com/nix-darwin/manual/index.html#sec-options
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

          # Install system packages (available to all users)
          environment.systemPackages = [ coreutils ];

          # Configure keyboard
          system.keyboard.enableKeyMapping = true;
          system.keyboard.remapCapsLockToEscape = true;

          # Configure fonts
          fonts.fontDir.enable = false; # Danger: `true` mean fonts can get removed.
          fonts.fonts = [ (nerdfonts.override { fonts = ["Meslo"]; }) ];

          # Configure Finder 
          system.defaults.finder.AppleShowAllExtensions = true;
          system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;

          # Backwards compatibility. Don't change.
          system.stateVersion = 4;
        })

        # Configure user spaces.
        # https://nix-community.github.io/home-manager/options.html
        inputs.home-manager.darwinModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.ek.imports = [
              ({pkgs, ...}: with pkgs; {
                # Backwards compatibility. Don't change.
                home.stateVersion = "22.11";

                # Install user-specific packages
                home.packages = [
                  btop
                  pipenv
                ];

                # Allows for exporting shell vars, i.e. EDITOR=nvim
                # Not sure if I'd rather use this or just have a .zshrc file
                # home.sessionVariables = {};

                # Configure select packages that have direct home-manager options.
                programs.fzf.enable = true;
                programs.fzf.enableZshIntegration = true;
                programs.exa.enable = true;
                programs.git.enable = true;

                # Configure zsh shell
                programs.zsh.enable = true;
                programs.zsh.enableCompletion = true;
                programs.zsh.enableAutosuggestions = true;
                programs.zsh.enableSyntaxHighlighting = true;
                programs.zsh.shellAliases = { ls = "exa --group-directories-first"; };

                # Configure terminal emulator.
                # Not sure I want to configure it like this. I think I'd rather
                # have alacritty as a home package with a config file symlinked
                # to .config/alacritty/
                # programs.alacritty = { enable = true; settings.font.size = 16; };
              })
            ];
          };
        }
      ];
    };
  };
}
