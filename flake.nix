{
  description = "Configure system and user spaces.";
  inputs = {
    # Try going back to unstable or taking both pinned and unstable.
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Configure system level software and settings.
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Manage deployments to NixOS servers.
    deploy-rs.url = "github:serokell/deploy-rs";

    # Used to partition and format disks on NixOS
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Configure software in home directory.
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # My nvim flake.
    envim.url = "github:erikkrieg/envim/main";
    envim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, unstable, darwin, deploy-rs, disko, home-manager, envim, ... }: {
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

    # Servers that can be deployed with deploy-rs.
    deploy = {
      nodes = {
        june = rec {
          hostname = "june";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${hostname};
          };
        };
        chips = rec {
          hostname = "chips";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${hostname};
          };
        };
        icecream = rec {
          hostname = "icecream";
          profiles.system = {
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${hostname};
          };
        };
      };
      user = "root";
      remoteBuild = true;
      activationTimeout = 600;
      confirmTimeout = 60;
    };

    # Deploy checks for all servers.
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
