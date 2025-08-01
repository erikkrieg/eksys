{
  description = "Configure system and user spaces.";
  inputs = {
    # Try going back to unstable or taking both pinned and unstable.
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Used to partition and format disks on NixOS
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Configure software in home directory.
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Configure system level software and settings.
    darwin.url = "github:lnl7/nix-darwin/nix-darwin-24.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # My nvim flake.
    envim.url = "github:erikkrieg/envim/main";
    envim.inputs.nixpkgs.follows = "nixpkgs";

    claude-code.url = "github:erikkrieg/claude-code-flake/main";
    claude-code.inputs.nixpkgs.follows = "unstable";
  };

  outputs = inputs@{ nixpkgs, unstable, darwin, disko, home-manager, envim, ... }: {
    # Imports configurations for all MacOS hosts.
    darwinConfigurations = (
      import ./hosts/darwin {
        inherit inputs nixpkgs unstable darwin home-manager envim;
      }
    );

    # Imports configurations for all NixOS hosts.
    nixosConfigurations = (
      import ./hosts/nixos {
        inherit inputs nixpkgs unstable disko home-manager envim;
      }
    );

    # Imports configurations for Linux hosts using home-manager
    homeConfigurations = (
      import ./hosts/linux {
        inherit inputs nixpkgs unstable home-manager envim;
      }
    );
  };
}
