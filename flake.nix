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

    # My nvim flake.
    envim.url = "github:erikkrieg/envim/main";
    envim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, darwin, home-manager, envim, ... }: {
    # Imports configurations for all MacOS hosts.
    darwinConfigurations = (
      import ./hosts/darwin {
        inherit inputs nixpkgs darwin home-manager envim;
      }
    );

    # Imports configurations for all NixOS hosts.
    nixosConfigurations = (
      import ./hosts/nixos {
        inherit inputs nixpkgs home-manager envim;
      }
    );
  };
}
