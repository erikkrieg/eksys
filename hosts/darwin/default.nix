{ inputs, nixpkgs, unstable, darwin, home-manager, envim, llm-agents, lpu-pkgs, ... }:
let
  darwinFixesOverlay = final: prev: {
    # Fixed following error: 
    # "unable to find dynamic system library 'ncursesw' using strategy 'paths_first'. searched paths: none"
    ncdu = prev.ncdu.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
        final.pkg-config
      ];
    });
    tailscale = (unstable.legacyPackages.${final.system}.tailscale).overrideAttrs (oldAttrs: {
      # These run integration tests that were not reliable.
      doCheck = false;
    });
  };
  mkHost = { system, user, traits, modules ? [ ], gids ? 350 }: (darwin.lib.darwinSystem) {
    inherit system;
    modules = modules ++ [
      inputs.determinate.darwinModules.default
      {
        determinateNix.enable = true;
        determinateNix.customSettings = import ../nix-cache-settings.nix;
      }
      {
        # GID change from 30000 to 350 was made by the Nix project to improve
        # compatibility and avoid conflicts on macOS systems.
        ids.gids.nixbld = gids;
        nixpkgs.overlays = [ darwinFixesOverlay ];
        nixpkgs.config.allowUnfree = true;
      }
      home-manager.darwinModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            envim = envim.packages.${system}.default;
            llm_agents = llm-agents.packages.${system};
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
    modules = [
      ./ek_pro
      { environment.systemPackages = [ lpu-pkgs.packages.aarch64-darwin.internal ]; }
    ];
  };
}
