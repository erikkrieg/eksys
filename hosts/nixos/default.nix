{ nixpkgs, home-manager, envim, ... }:
let
  mkHost = { system, user, traits, modules ? [ ] }: (nixpkgs.lib.nixosSystem) {
    pkgs = import nixpkgs { inherit system; };
    modules = modules ++ [
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            envim = envim.packages.${system}.default;
          };
          users.${user}.imports = map (trait: ../../traits/${trait}/nixos-user.nix) traits;
        };
      }
    ] ++ map (trait: ../../traits/${trait}/nixos-host.nix) traits;
  };
in
{
  noosh = mkHost {
    system = "x86_64-linux";
    user = "ek";
    traits = [ "devbox" "server" ];
  };
}
