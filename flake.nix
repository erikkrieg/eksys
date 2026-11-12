{
  description = "Configure system and user spaces.";
  inputs = {
    # Try going back to unstable or taking both pinned and unstable.
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
    unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Used to partition and format disks on NixOS
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Configure software in home directory.
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Configure system level software and settings.
    darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Configure Determinate's independently installed Nix daemon on Darwin.
    determinate.url = "github:DeterminateSystems/determinate";

    # My nvim flake.
    envim.url = "github:erikkrieg/envim/main";
    envim.inputs.nixpkgs.follows = "nixpkgs";

    # LLM CLI tools (droid, codex, gemini-cli, etc.)
    llm-agents.url = "github:numtide/llm-agents.nix";
    # Keep upstream's nixpkgs pin so package outputs match Numtide's binary cache.

    # Shared developer toolbox for LPU engineers (only used by ek_pro)
    lpu-pkgs.url = "github:nvidia-lpu/lpu-pkgs";

  };

  outputs = inputs@{ nixpkgs, unstable, darwin, disko, home-manager, envim, llm-agents, lpu-pkgs, ... }: {
    # Export the locked standalone home-manager CLI for the single x86_64-linux host.
    packages.x86_64-linux.home-manager = home-manager.packages.x86_64-linux.home-manager;

    # Imports configurations for all MacOS hosts.
    darwinConfigurations = (
      import ./hosts/darwin {
        inherit inputs nixpkgs unstable darwin home-manager envim llm-agents lpu-pkgs;
      }
    );

    # Imports configurations for all NixOS hosts.
    nixosConfigurations = (
      import ./hosts/nixos {
        inherit inputs nixpkgs unstable disko home-manager envim llm-agents;
      }
    );

    # Imports configurations for Linux hosts using home-manager
    homeConfigurations = (
      import ./hosts/linux {
        inherit inputs nixpkgs unstable home-manager envim llm-agents;
      }
    );
  };
}
