{
  description = "Configure system and user spaces.";
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
  outputs = inputs@{ nixpkgs, darwin, home-manager, ... }: {
    darwinConfigurations."Eriks-MacBook-Pro" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
      modules = [
        # Configure Darwin system space.
        ./modules/system       

        # Configure user spaces.
        home-manager.darwinModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.ek.imports = [
              ./modules/users 
            ];
          };
        }
      ];
    };
  };
}
