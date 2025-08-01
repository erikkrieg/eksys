{ nixpkgs, unstable, home-manager, envim, ... }:
let
  mkHost = { system, user, traits, modules ? [ ] }: (home-manager.lib.homeManagerConfiguration) {
    pkgs = import nixpkgs {
      inherit system;
    };
    extraSpecialArgs = {
      envim = envim.packages.${system}.default;
      unstable_pkgs = import unstable {
        inherit system;
      };
    };
    modules = modules ++ [
      {
        home = {
          username = user;
          homeDirectory = "/home/${user}";
        };
      }
    ] ++ map (trait: ../../traits/${trait}/linux-user.nix) traits;
  };
in
{
  dev_vm = mkHost {
    system = "x86_64-linux";
    user = "ekrieg";
    traits = [ "devbox" ];
    modules = [ ];
  };
}
