{ nixpkgs, unstable, darwin, home-manager, envim, ... }:
let
  mkHost = { system, user, traits, modules ? [ ] }: (darwin.lib.darwinSystem) {
    pkgs = import nixpkgs { inherit system; };
    modules = modules ++ [
      home-manager.darwinModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            envim = envim.packages.${system}.default;
            unstable_pkgs = import unstable { inherit system; };
          };
          users.${user}.imports = map (trait: ../../traits/${trait}/darwin-user.nix) traits;
        };
      }
    ] ++ map (trait: ../../traits/${trait}/darwin-host.nix) traits;
  };
in
{
  eksys = mkHost {
    system = "aarch64-darwin";
    user = "ek";
    traits = [ "devbox" "vpn-peer" ];
    modules = [ ./eksys ];
  };

  eksys_pro = mkHost {
    system = "x86_64-darwin";
    user = "erik.krieg";
    traits = [ "devbox" ];
    modules = [ ./eksys_pro ];
  };
}
