{ nixpkgs, unstable, darwin, home-manager, envim, ... }:
let
  mkHost = { system, user, traits, modules ? [ ] }: (darwin.lib.darwinSystem) {
    inherit system;
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
        users.users.${user}.home = "/Users/${user}";
      }
    ] ++ [
      {
        system.activationScripts.preActivation.text = ''
          shells="/etc/shells"
          if [ -f "$shells" ] && [ ! -L "$shells" ]; then
              echo "$shells exists and is not a symbolic link: backing up as $shells.before-nix-darwin"
              mv "$shells" "$shells.before-nix-darwin" 
          fi
        '';
      }
    ] ++ map (trait: ../../traits/${trait}/darwin-host.nix) traits;
  };
in
{
  eksys = mkHost {
    system = "aarch64-darwin";
    user = "ek";
    traits = [ "devbox" "guibox" "vpn-peer" ];
    modules = [ ./eksys ];
  };

  ek_pro = mkHost {
    system = "aarch64-darwin";
    user = "erik.krieg";
    traits = [ "devbox" "guibox" ];
    modules = [ ./ek_pro ];
  };
}
