{ inputs, nixpkgs, unstable, darwin, home-manager, envim, ... }:
let
  darwinFixesOverlay = final: prev: {
    # Fixed following error: 
    # "unable to find dynamic system library 'ncursesw' using strategy 'paths_first'. searched paths: none"
    ncdu = prev.ncdu.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
        final.pkg-config
      ];
    });
  };
  mkHost = { system, user, traits, modules ? [ ] }: (darwin.lib.darwinSystem) {
    inherit system;
    modules = modules ++ [
      {
        nixpkgs.overlays = [ darwinFixesOverlay ];
      }
      home-manager.darwinModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            envim = envim.packages.${system}.default;
            claude-code = inputs.claude-code.packages.${system}.default;
            unstable_pkgs = import unstable {
              inherit system;
              overlays = [ darwinFixesOverlay ];
              config.allowUnfree = true;
            };
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
    user = "ekrieg";
    traits = [ "devbox" "guibox" ];
    modules = [ ./ek_pro ];
  };
}
