{
  description = "Minimal NixOS installation media";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      minimal = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./minimal.nix
        ];
      };
    };
  };
}
