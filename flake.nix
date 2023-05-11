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

    envim.url = "github:erikkrieg/envim/main";
  };

  outputs = { self, nixpkgs, darwin, home-manager, envim, ... }:
    let
      mkDarwin = { system, ... }: (darwin.lib.darwinSystem) {
        pkgs = import nixpkgs { inherit system; };
        modules = [
          # Configure Darwin system space.
          ./modules/system

          # Configure user spaces.
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                envim = envim.packages.${system}.default;
              };
              users.ek.imports = [
                ./modules/users
              ];
            };
          }
        ];
      };
    in
    {
      darwinConfigurations."eksys" = mkDarwin { system = "aarch64-darwin"; };
      darwinConfigurations."eksys.pro" = mkDarwin { system = "x86_64-darwin"; };
    };
}
